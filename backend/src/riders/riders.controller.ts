import { Controller, Get, Post, Body, Patch, Param, Query } from '@nestjs/common';
import { RidersService } from './riders.service';
import { RiderStatus } from './entities/rider.entity';
import { ApiTags, ApiOperation } from '@nestjs/swagger';

@ApiTags('Riders')
@Controller('riders')
export class RidersController {
  constructor(private readonly ridersService: RidersService) {}

  @Post()
  @ApiOperation({ summary: 'Register a new rider' })
  create(@Body() createRiderDto: any) {
    const rider = (this.ridersService as any).riderRepository.create(createRiderDto);
    return (this.ridersService as any).riderRepository.save(rider);
  }

  @Get()
  @ApiOperation({ summary: 'Get all riders fleet' })
  findAll(@Query('status') status?: RiderStatus) {
    return this.ridersService.findAll(status);
  }

  @Get(':id')
  @ApiOperation({ summary: 'Get rider details' })
  findOne(@Param('id') id: string) {
    return this.ridersService.findOne(id);
  }

  @Patch(':id/status')
  @ApiOperation({ summary: 'Update rider status' })
  updateStatus(@Param('id') id: string, @Body('status') status: RiderStatus) {
    return this.ridersService.updateStatus(id, status);
  }
}
