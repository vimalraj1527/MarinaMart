import { Injectable, NotFoundException } from '@nestjs/common';
import { InjectRepository } from '@nestjs/typeorm';
import { Repository, ILike, Any } from 'typeorm';
import { Product } from './entities/product.entity';

@Injectable()
export class ProductsService {
  constructor(
    @InjectRepository(Product)
    private readonly productRepository: Repository<Product>,
  ) {}

  async findAll(category?: string, search?: string, trending?: boolean) {
    const where: any = { isAvailable: true };
    
    if (category) {
      const cat = category.toLowerCase();
      // Handle the common "Fruits & Vegetables" grouping vs individual "Fruits" or "Vegetables"
      if (cat.includes("fruit") || cat.includes("veg")) {
         where.category = Any([ILike('%fruit%'), ILike('%veg%')]);
      } else if (cat.includes("dairy") || cat.includes("diary") || cat.includes("milk")) {
         where.category = Any([ILike('%dairy%'), ILike('%diary%'), ILike('%milk%'), ILike('%bread%'), ILike('%egg%')]);
      } else {
         where.category = ILike(`%${category}%`);
      }
    }
    
    if (trending) where.isTrending = true;
    
    if (search) {
      where.name = ILike(`%${search}%`);
    }

    return await this.productRepository.find({
      where,
      order: { createdAt: 'DESC' },
    });
  }

  async findOne(id: string) {
    const product = await this.productRepository.findOne({ where: { id } });
    if (!product) throw new NotFoundException('Product not found');
    return product;
  }

  async create(createProductDto: any) {
    const product = this.productRepository.create({
      ...createProductDto,
      isAvailable: true // Ensure new products are visible by default
    });
    return await this.productRepository.save(product);
  }

  async remove(id: string) {
    const product = await this.findOne(id);
    return await this.productRepository.remove(product);
  }
}
