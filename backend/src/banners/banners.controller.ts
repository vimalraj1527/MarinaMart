import { Controller, Get, Post, Body, Param, Put, Delete } from '@nestjs/common';
import { BannersService } from './banners.service';
import { Banner } from './entities/banner.entity';

@Controller('banners')
export class BannersController {
  constructor(private readonly bannersService: BannersService) {}

  @Get()
  findAll() {
    return this.bannersService.findAll();
  }

  @Post()
  create(@Body() data: Partial<Banner>) {
    return this.bannersService.create(data);
  }

  @Put(':id')
  update(@Param('id') id: string, @Body() data: Partial<Banner>) {
    return this.bannersService.update(id, data);
  }

  @Delete(':id')
  remove(@Param('id') id: string) {
    return this.bannersService.remove(id);
  }
}
