import { Injectable, UnauthorizedException } from '@nestjs/common';
import { JwtService } from '@nestjs/jwt';
import { UsersService } from '../users/users.service';
import * as bcrypt from 'bcrypt';

@Injectable()
export class AuthService {
  constructor(
    private readonly usersService: UsersService,
    private readonly jwtService: JwtService,
  ) {}

  async validateUser(email: string, pass: string): Promise<any> {
    console.log(`[AUTH] Attempting login for: ${email}`);
    const user: any = await (this.usersService as any).userRepository.findOne({ where: { email } });
    
    if (!user) {
      console.log(`[AUTH] User not found: ${email}`);
      return null;
    }

    const isMatch = await bcrypt.compare(pass, user.password || '');
    console.log(`[AUTH] Password Match for ${email}: ${isMatch}`);

    if (isMatch) {
      const { password, ...result } = user;
      return result;
    }
    return null;
  }

  async login(user: any) {
    const payload = { email: user.email, sub: user.id, role: user.role };
    return {
      access_token: this.jwtService.sign(payload),
      user: {
        id: user.id,
        name: user.name,
        email: user.email,
        role: user.role,
        avatar: user.avatar,
      },
    };
  }
  async register(registerDto: any) {
    const existingUser = await (this.usersService as any).userRepository.findOne({ 
      where: { email: registerDto.email } 
    });
    
    if (existingUser) {
      throw new UnauthorizedException('User with this email already exists');
    }

    const user = await this.usersService.create(registerDto);
    return this.login(user);
  }
}
