import { Injectable, NotFoundException } from '@nestjs/common';
import { InjectRepository } from '@nestjs/typeorm';
import { Repository } from 'typeorm';
import { Order, OrderStatus } from './entities/order.entity';
import { Product } from '../products/entities/product.entity';
import { In } from 'typeorm';

@Injectable()
export class OrdersService {
  constructor(
    @InjectRepository(Order)
    private readonly orderRepository: Repository<Order>,
    @InjectRepository(Product)
    private readonly productRepository: Repository<Product>,
  ) {}

  async create(createOrderDto: any) {
    const orderNum = `ORD-${Math.floor(1000 + Math.random() * 9000)}`;
    
    // Auto-fill product names for new orders too!
    const productIds = createOrderDto.items.map((i: any) => i.productId);
    const products = await this.productRepository.find({ where: { id: In(productIds) } });
    
    createOrderDto.items = createOrderDto.items.map((item: any) => {
      const prod = products.find(p => p.id === item.productId);
      return { ...item, productName: prod ? prod.name : 'Unknown Product' };
    });

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
    const orders = await this.orderRepository.find({ 
      relations: ['assignedRider'],
      order: { createdAt: 'DESC' } 
    });

    // POPULATE PRODUCT NAMES for existing orders dynamically!
    // 1. Gather all product IDs from all orders
    const allProdIds = [...new Set(orders.flatMap((o: any) => o.items.map((i: any) => i.productId)))];
    
    // 2. Fetch those products
    const products = await this.productRepository.find({ where: { id: In(allProdIds) } });

    // 3. Map names back into items
    return orders.map((order: any) => {
      order.items = order.items.map((item: any) => {
        const prod = products.find(p => p.id === item.productId);
        return {
          ...item,
          productName: item.productName || (prod ? prod.name : 'Product')
        };
      });
      return order;
    });
  }

  async updateStatus(id: string, status: OrderStatus) {
    const order = await this.orderRepository.findOne({ where: { id } });
    if (!order) throw new NotFoundException('Order not found');
    order.status = status;
    return await this.orderRepository.save(order);
  }
}
