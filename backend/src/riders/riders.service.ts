import { Injectable, NotFoundException } from '@nestjs/common';
import { InjectRepository } from '@nestjs/typeorm';
import { Repository } from 'typeorm';
import { Rider, RiderStatus } from './entities/rider.entity';

@Injectable()
export class RidersService {
  constructor(
    @InjectRepository(Rider)
    public readonly riderRepository: Repository<Rider>, // Public for seeder access
  ) {}

  async findAll(status?: RiderStatus) {
    const where: any = {};
    if (status) where.status = status;
    return await this.riderRepository.find({ where, order: { rating: 'DESC' } });
  }

  async findOne(id: string) {
    const rider = await this.riderRepository.findOne({ where: { id } });
    if (!rider) throw new NotFoundException('Rider not found');
    return rider;
  }

  async updateStatus(id: string, status: RiderStatus) {
    const rider = await this.findOne(id);
    rider.status = status;
    return await this.riderRepository.save(rider);
  }
}
