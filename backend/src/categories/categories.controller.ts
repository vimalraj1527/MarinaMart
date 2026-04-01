import { Controller, Get, Post, Body, Param, Delete, Patch, UseInterceptors, UploadedFile } from '@nestjs/common';
import { FileInterceptor } from '@nestjs/platform-express';
import { diskStorage } from 'multer';
import { extname } from 'path';
import { CategoriesService } from './categories.service';

@Controller('categories')
export class CategoriesController {
  constructor(private readonly categoriesService: CategoriesService) {}

  @Get()
  async findAll() {
    return await this.categoriesService.findAll();
  }

  @Get(':id')
  async findOne(@Param('id') id: string) {
    return await this.categoriesService.findOne(id);
  }

  @Post('upload')
  @UseInterceptors(
    FileInterceptor('file', {
      storage: diskStorage({
        destination: './uploads',
        filename: (req, file, cb) => {
          const name = file.originalname.split('.')[0];
          const fileExtName = extname(file.originalname);
          const randomName = Array(4)
            .fill(null)
            .map(() => Math.round(Math.random() * 16).toString(16))
            .join('');
          cb(null, `${name}-${randomName}${fileExtName}`);
        },
      }),
    }),
  )
  async uploadFile(@UploadedFile() file: any) {
    // Determine Port for development (default 5001 based on current setup)
    const baseUrl = process.env.URL || 'http://localhost:5001';
    return {
      url: `${baseUrl}/uploads/${file.filename}`,
    };
  }

  @Post()
  async create(@Body() createCategoryDto: any) {
    return await this.categoriesService.create(createCategoryDto);
  }

  @Patch(':id')
  async update(@Param('id') id: string, @Body() updateCategoryDto: any) {
    return await this.categoriesService.update(id, updateCategoryDto);
  }

  @Delete(':id')
  async remove(@Param('id') id: string) {
    return await this.categoriesService.remove(id);
  }
}
