import { Controller, Get, Post, Body, UseGuards, Request, UnauthorizedException, Param } from '@nestjs/common';
import { ApiTags, ApiOperation, ApiBearerAuth } from '@nestjs/swagger';
import { SettingsService } from './settings.service';
import { JwtAuthGuard } from '../auth/guards/jwt-auth.guard';
import { UserRole } from '../users/entities/user.entity';

@ApiTags('Platform Settings')
@Controller('settings')
export class SettingsController {
  constructor(private readonly settingsService: SettingsService) {}

  @Get()
  @Header('Cache-Control', 'no-store, no-cache, must-revalidate')
  @ApiOperation({ summary: 'Get all platform settings' })
  async getAll() {
    return this.settingsService.getAll();
  }

  @Get(':key')
  @ApiOperation({ summary: 'Get a specific setting by key' })
  async getByKey(@Param('key') key: string) {
    return this.settingsService.findByKey(key);
  }

  @Post()
  @UseGuards(JwtAuthGuard)
  @ApiBearerAuth()
  @ApiOperation({ summary: 'Update platform settings (Admin only)' })
  async update(@Body() data: { key: string, value: any }, @Request() req: any) {
    // Only Admin can update settings
    if (req.user.role !== UserRole.ADMIN && req.user.role !== UserRole.SUPER_ADMIN) {
      throw new UnauthorizedException('Insufficient platform privileges.');
    }
    return this.settingsService.updateByKey(data.key, data.value);
  }

  // Bulk update endpoint for convenience
  @Post('bulk')
  @UseGuards(JwtAuthGuard)
  @ApiBearerAuth()
  @ApiOperation({ summary: 'Update multiple platform settings (Admin only)' })
  async updateBulk(@Body() data: Record<string, any>, @Request() req: any) {
    if (req.user.role !== UserRole.ADMIN && req.user.role !== UserRole.SUPER_ADMIN) {
       throw new UnauthorizedException('Insufficient platform privileges.');
    }
    
    for (const key of Object.keys(data)) {
      await this.settingsService.updateByKey(key, data[key]);
    }
    return { success: true };
  }
}
