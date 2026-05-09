import { Injectable, NotFoundException } from '@nestjs/common';
import { InjectRepository } from '@nestjs/typeorm';
import { Repository } from 'typeorm';
import { Banner } from './entities/banner.entity';

@Injectable()
export class BannersService {
  constructor(
    @InjectRepository(Banner)
    private readonly bannerRepository: Repository<Banner>,
  ) {}

  async findAll() {
    return this.bannerRepository.find({ order: { createdAt: 'DESC' } });
  }

  async create(data: Partial<Banner>) {
    const banner = this.bannerRepository.create(data);
    return this.bannerRepository.save(banner);
  }

  async update(id: string, data: Partial<Banner>) {
    const banner = await this.bannerRepository.findOne({ where: { id } });
    if (!banner) throw new NotFoundException('Banner not found');
    Object.assign(banner, data);
    return this.bannerRepository.save(banner);
  }

  async remove(id: string) {
    const banner = await this.bannerRepository.findOne({ where: { id } });
    if (!banner) throw new NotFoundException('Banner not found');
    return this.bannerRepository.remove(banner);
  }
}
