import { Controller, Get, UseGuards, UnauthorizedException, Request } from '@nestjs/common';
import { ApiTags, ApiOperation, ApiBearerAuth } from '@nestjs/swagger';
import { StatsService } from './stats.service';
import { JwtAuthGuard } from '../auth/guards/jwt-auth.guard';
import { UserRole } from '../users/entities/user.entity';

@ApiTags('Dashboard Stats')
@ApiBearerAuth()
@Controller('dashboard/stats')
@UseGuards(JwtAuthGuard)
export class StatsController {
  constructor(private readonly statsService: StatsService) {}

  @Get()
  @ApiOperation({ summary: 'Get live dashboard analytics' })
  async getStats(@Request() req: any) {
    // Only Admin or SuperAdmin should see stats
    if (req.user.role !== UserRole.ADMIN && req.user.role !== UserRole.SUPER_ADMIN) {
      throw new UnauthorizedException('Access restricted to platform administrators.');
    }
    return this.statsService.getDashboardData();
  }
}
