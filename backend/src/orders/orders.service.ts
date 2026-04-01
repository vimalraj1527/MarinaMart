import { Injectable, NotFoundException } from '@nestjs/common';
import { InjectRepository } from '@nestjs/typeorm';
import { Repository } from 'typeorm';
import { Order, OrderStatus } from './entities/order.entity';

@Injectable()
export class OrdersService {
  constructor(
    @InjectRepository(Order)
    private readonly orderRepository: Repository<Order>,
  ) {}

  async create(createOrderDto: any) {
    const orderNum = `ORD-${Math.floor(1000 + Math.random() * 9000)}`;
    
    // Ensure required fields for the database
    const orderData = {
      customerName: 'Bloomarina Customer',
      customerPhone: '+91 9999999999',
      paymentStatus: 'Pending',
      ...createOrderDto,
      orderNumber: orderNum,
    };

    const order = this.orderRepository.create(orderData);
    return await this.orderRepository.save(order);
  }

  async findAll() {
    return await this.orderRepository.find({ 
      relations: ['assignedRider'],
      order: { createdAt: 'DESC' } 
    });
  }

  async updateStatus(id: string, status: OrderStatus) {
    const order = await this.orderRepository.findOne({ where: { id } });
    if (!order) throw new NotFoundException('Order not found');
    order.status = status;
    return await this.orderRepository.save(order);
  }
}
