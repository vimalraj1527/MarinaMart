import { Controller, Get, Post, Body, Param, Delete, Query, UseInterceptors, ClassSerializerInterceptor, UploadedFile } from '@nestjs/common';
import { FileInterceptor } from '@nestjs/platform-express';
import { diskStorage } from 'multer';
import { extname } from 'path';
import { ProductsService } from './products.service';

@Controller('products')
@UseInterceptors(ClassSerializerInterceptor)
export class ProductsController {
  constructor(private readonly productsService: ProductsService) {}

  @Get()
  async findAll(
    @Query('category') category?: string,
    @Query('search') search?: string,
    @Query('trending') trending?: string,
  ) {
    return await this.productsService.findAll(category, search, trending === 'true');
  }

  @Get(':id')
  async findOne(@Param('id') id: string) {
    return await this.productsService.findOne(id);
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
    const baseUrl = process.env.URL || 'http://localhost:5001';
    return {
      url: `${baseUrl}/uploads/${file.filename}`,
    };
  }

  @Post()
  async create(@Body() createProductDto: any) {
    return await this.productsService.create(createProductDto);
  }

  @Delete(':id')
  async remove(@Param('id') id: string) {
    return await this.productsService.remove(id);
  }
}
