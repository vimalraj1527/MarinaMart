import { Injectable, NotFoundException } from '@nestjs/common';
import { InjectRepository } from '@nestjs/typeorm';
import { Repository } from 'typeorm';
import { User, UserRole } from './entities/user.entity';
import { Order } from '../orders/entities/order.entity';

@Injectable()
export class UsersService {
  constructor(
    @InjectRepository(User)
    private readonly userRepository: Repository<User>,
    @InjectRepository(Order)
    private readonly orderRepository: Repository<Order>,
  ) {}

  async findByEmail(email: string): Promise<User | null> {
    return this.userRepository.findOne({ where: { email } });
  }

  async create(createUserDto: any) {
    const user = this.userRepository.create(createUserDto);
    return await this.userRepository.save(user);
  }

  async findAll(role?: UserRole) {
    const where: any = {};
    if (role) where.role = role;
    const users = await this.userRepository.find({ where, order: { createdAt: 'DESC' } });
    
    const allOrders = await this.orderRepository.find();

    return users.map(user => {
      const userOrders = allOrders.filter(o => o.customerId === user.id);
      const totalOrderValue = userOrders.reduce((sum, o) => {
        const val = typeof o.totalAmount === 'string' ? parseFloat(o.totalAmount) : Number(o.totalAmount);
        return sum + (isNaN(val) ? 0 : val);
      }, 0);

      return {
        ...user,
        orderCount: userOrders.length,
        totalValue: totalOrderValue,
        orders: userOrders
      };
    });
  }

  async findOne(id: string) {
    const user = await this.userRepository.findOne({ where: { id } });
    if (!user) throw new NotFoundException('User not found');
    
    const userOrders = await this.orderRepository.find({ 
      where: { customerId: id },
      order: { createdAt: 'DESC' }
    });

    const totalOrderValue = userOrders.reduce((sum, o) => {
      const val = typeof o.totalAmount === 'string' ? parseFloat(o.totalAmount) : Number(o.totalAmount);
      return sum + (isNaN(val) ? 0 : val);
    }, 0);
    
    return {
      ...user,
      orderCount: userOrders.length,
      totalValue: totalOrderValue,
      orders: userOrders
    };
  }
}
