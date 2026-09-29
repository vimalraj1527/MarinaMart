import { Controller, Post, Body, Get, UseGuards, Request, UnauthorizedException } from '@nestjs/common';
import { AuthService } from './auth.service';
import { ApiTags, ApiOperation } from '@nestjs/swagger';

@ApiTags('Authentication')
@Controller('auth')
export class AuthController {
  constructor(private readonly authService: AuthService) {}

  @Post('login')
  @ApiOperation({ summary: 'Login for Users & Admins' })
  async login(@Body() loginDto: any) {
    const identifier = loginDto.email || loginDto.username || loginDto.phone;
    const user = await this.authService.validateUser(identifier, loginDto.password);
    if (!user) {
      throw new UnauthorizedException('Invalid Email/Phone or Password');
    }
    return this.authService.login(user);
  }

  @Post('register')
  @ApiOperation({ summary: 'Register a new customer' })
  async register(@Body() registerDto: any) {
    return this.authService.register(registerDto);
  }

  @Post('send-otp')
  @ApiOperation({ summary: 'Send SMS OTP for Login / Signup' })
  async sendOtp(@Body() body: { phone: string; appName?: string }) {
    return this.authService.sendOtp(body.phone, body.appName);
  }

  @Post('verify-otp')
  @ApiOperation({ summary: 'Verify SMS OTP for Login / Signup' })
  async verifyOtp(@Body() body: { phone: string; otp: string; userData?: any }) {
    return this.authService.verifyOtp(body.phone, body.otp, body.userData);
  }

  @Get('profile')
  @ApiOperation({ summary: 'Get current user profile' })
  getProfile(@Request() req: any) {
    return req.user;
  }
}
