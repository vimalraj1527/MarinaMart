import { Injectable, UnauthorizedException, BadRequestException } from '@nestjs/common';
import { JwtService } from '@nestjs/jwt';
import { UsersService } from '../users/users.service';
import * as bcrypt from 'bcrypt';
import * as http from 'http';

@Injectable()
export class AuthService {
  constructor(
    private readonly usersService: UsersService,
    private readonly jwtService: JwtService,
  ) {}

  async validateUser(identifier: string, pass: string): Promise<any> {
    console.log(`[AUTH] Attempting login for: ${identifier}`);
    
    const user = await this.usersService.findByIdentifier(identifier);
    
    if (!user) {
      console.log(`[AUTH] Identity not found: ${identifier}`);
      return null;
    }

    const isMatch = await bcrypt.compare(pass, user.password || '');
    console.log(`[AUTH] Verified ${identifier}: ${isMatch}`);

    if (isMatch) {
      const { password, ...result } = user;
      return result;
    }
    return null;
  }

  async login(user: any) {
    const payload = { email: user.email, sub: user.id, role: user.role };
    const isNewUser = !user.name || user.name.startsWith('User ') || !user.email || user.email.includes('@marinamart.com');
    return {
      access_token: this.jwtService.sign(payload),
      isNewUser,
      user: {
        id: user.id,
        name: user.name,
        email: user.email,
        phone: user.phone,
        role: user.role,
        avatar: user.avatar,
        birthday: user.birthday,
        walletBalance: user.walletBalance,
        isNewUser,
      },
    };
  }
  
  async register(registerDto: any) {
    if (registerDto.email) {
      const existingEmail = await this.usersService.findByEmail(registerDto.email);
      if (existingEmail) {
        throw new BadRequestException('User with this email already exists.');
      }
    }

    if (registerDto.phone) {
      const cleanPhone = registerDto.phone.replace(/\D/g, '').slice(-10);
      registerDto.phone = cleanPhone;
      const existingPhone = await this.usersService.findByPhone(cleanPhone);
      if (existingPhone && existingPhone.password && !existingPhone.password.startsWith('Otp@')) {
        throw new BadRequestException('User with this mobile number already exists.');
      }
    }

    const user = await this.usersService.create(registerDto);
    return this.login(user);
  }

  async sendOtp(phone: string, appName: string = 'MaRinaMaRt') {
    const cleanPhone = phone.replace(/\D/g, '').slice(-10);
    if (cleanPhone.length !== 10) {
      throw new BadRequestException('Invalid mobile number. Must be 10 digits.');
    }

    // Generate 6 digit random OTP
    const otp = Math.floor(100000 + Math.random() * 900000).toString();
    const expiresAt = new Date(Date.now() + 30 * 60 * 1000); // Valid for 30 mins

    // Save to user record in DB
    await this.usersService.saveOtp(cleanPhone, otp, expiresAt);

    // Prepare message template
    const apiKey = 'pdtPO9aL4m8RSQTV';
    const senderId = 'MDTDMO';
    const messageTemplate = `Dear ${otp}, Your OTP for login to ${appName}. Valid for 30 minutes. Please do not share this OTP. Regards, My Dreams Technology Team`;
    const encodedMessage = encodeURIComponent(messageTemplate);

    const apiUrl = `http://app.mydreamstechnology.in/vb/apikey.php?apikey=${apiKey}&senderid=${senderId}&number=${cleanPhone}&message=${encodedMessage}`;

    console.log(`[SMS-OTP] Sending OTP ${otp} to +91${cleanPhone}...`);

    try {
      // Execute HTTP request to SMS gateway
      http.get(apiUrl, (res) => {
        let body = '';
        res.on('data', (chunk) => body += chunk);
        res.on('end', () => {
          console.log(`[SMS-OTP] Gateway Response for +91${cleanPhone}: ${body}`);
        });
      }).on('error', (err) => {
        console.error(`[SMS-OTP] Gateway HTTP Error: ${err.message}`);
      });
    } catch (e: any) {
      console.error(`[SMS-OTP] Gateway Exception: ${e.message}`);
    }

    return {
      success: true,
      message: `OTP sent successfully to +91 ${cleanPhone}`,
      otp, // Included for testing / display if needed
    };
  }

  async verifyOtp(phone: string, otp: string, userData?: any) {
    const cleanPhone = phone.replace(/\D/g, '').slice(-10);
    const user = await this.usersService.findByPhone(cleanPhone);

    if (!user || !user.otpCode) {
      throw new BadRequestException('No OTP request found for this phone number. Please request a new OTP.');
    }

    if (user.otpCode !== otp.trim()) {
      throw new BadRequestException('Invalid OTP entered. Please check and try again.');
    }

    if (user.otpExpiresAt && new Date() > new Date(user.otpExpiresAt)) {
      throw new BadRequestException('OTP has expired. Please request a new OTP.');
    }

    // OTP is valid! Clear OTP
    user.otpCode = null as any;
    user.otpExpiresAt = null as any;

    // Update registration details if provided during signup
    if (userData) {
      if (userData.name && userData.name.trim()) user.name = userData.name.trim();
      if (userData.email && userData.email.trim()) {
        const existingEmail = await this.usersService.findByEmail(userData.email.trim());
        if (!existingEmail || existingEmail.id === user.id) {
          user.email = userData.email.trim();
        }
      }
      if (userData.password && userData.password.trim()) {
        user.password = userData.password.trim();
      }
      if (userData.birthday && userData.birthday.trim()) user.birthday = userData.birthday.trim();
    }

    await (this.usersService as any).userRepository.save(user);

    return this.login(user);
  }
}
