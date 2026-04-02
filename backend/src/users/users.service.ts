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

  async create(createUserDto: any) {
    const user = this.userRepository.create(createUserDto);
    return await this.userRepository.save(user);
  }

  async findAll(role?: UserRole) {
    const where: any = {};
    if (role) where.role = role;
    const users = await this.userRepository.find({ where, order: { createdAt: 'DESC' } });
    
    // FETCH ALL ORDERS once to avoid N+1 query issue for customer list
    const allOrders = await this.orderRepository.find();

    return users.map(user => {
      // Filter orders belonging to this specific user ID
      const userOrders = allOrders.filter(o => o.customerId === user.id);
      
      // Calculate Total Order Value (Lifetime Value) precisely
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
    
    // Fetch individual user orders for the deep-dive view
    const userOrders = await this.orderRepository.find({ 
      where: { customerId: id },
      order: { createdAt: 'DESC' }
    });

    // Precise aggregation of Lifetime Total Order Value
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
