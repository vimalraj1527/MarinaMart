import { Injectable, NotFoundException } from '@nestjs/common';
import { InjectRepository } from '@nestjs/typeorm';
import { Repository, ILike } from 'typeorm';
import { Product } from './entities/product.entity';

@Injectable()
export class ProductsService {
  constructor(
    @InjectRepository(Product)
    private readonly productRepository: Repository<Product>,
  ) {}

  async findAll(category?: string, search?: string, trending?: boolean, allProducts = false) {
    const baseWhere: any = {};
    if (!allProducts) {
      baseWhere.isAvailable = true;
    }
    if (trending) baseWhere.isTrending = true;
    if (search) baseWhere.name = ILike(`%${search}%`);

    if (category) {
      const cat = category.toLowerCase();
      
      // Handle the common "Fruits & Vegetables" grouping vs individual "Fruits" or "Vegetables"
      if (cat.includes("fruit") || cat.includes("veg")) {
        return await this.productRepository.find({
          where: [
            { ...baseWhere, category: ILike('%fruit%') },
            { ...baseWhere, category: ILike('%veg%') }
          ],
          order: { createdAt: 'DESC' },
        });
      }
      
      // Handle Dairy, Bread & Eggs grouping
      if (cat.includes("dairy") || cat.includes("diary") || cat.includes("milk")) {
        return await this.productRepository.find({
          where: [
            { ...baseWhere, category: ILike('%dairy%') },
            { ...baseWhere, category: ILike('%diary%') },
            { ...baseWhere, category: ILike('%milk%') },
            { ...baseWhere, category: ILike('%bread%') },
            { ...baseWhere, category: ILike('%egg%') }
          ],
          order: { createdAt: 'DESC' },
        });
      }

      // Default single category match
      return await this.productRepository.find({
        where: { ...baseWhere, category: ILike(`%${category}%`) },
        order: { createdAt: 'DESC' },
      });
    }

    return await this.productRepository.find({
      where: baseWhere,
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
      isAvailable: createProductDto.isAvailable !== undefined ? createProductDto.isAvailable : true
    });
    return await this.productRepository.save(product);
  }

  async update(id: string, updateProductDto: any) {
    const product = await this.findOne(id);
    Object.assign(product, updateProductDto);
    return await this.productRepository.save(product);
  }

  async remove(id: string) {
    const product = await this.findOne(id);
    return await this.productRepository.remove(product);
  }
}
