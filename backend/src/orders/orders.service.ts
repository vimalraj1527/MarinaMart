import { Injectable, NotFoundException } from '@nestjs/common';
import { InjectRepository } from '@nestjs/typeorm';
import { Repository } from 'typeorm';
import { Order, OrderStatus } from './entities/order.entity';
import { Product } from '../products/entities/product.entity';
import { User, UserRole } from '../users/entities/user.entity';
import { In } from 'typeorm';

@Injectable()
export class OrdersService {
  constructor(
    @InjectRepository(Order)
    private readonly orderRepository: Repository<Order>,
    @InjectRepository(Product)
    private readonly productRepository: Repository<Product>,
    @InjectRepository(User)
    private readonly userRepository: Repository<User>,
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

    const walletAmountUsed = createOrderDto.walletAmountUsed ? Number(createOrderDto.walletAmountUsed) : 0;
    if (walletAmountUsed > 0 && createOrderDto.customerId) {
      const user = await this.userRepository.findOne({ where: { id: createOrderDto.customerId } });
      if (user) {
        const currentBalance = typeof user.walletBalance === 'string'
          ? parseFloat(user.walletBalance)
          : Number(user.walletBalance || 0);

        if (currentBalance < walletAmountUsed) {
          throw new Error('Insufficient wallet balance');
        }

        user.walletBalance = currentBalance - walletAmountUsed;
        await this.userRepository.save(user);
      }
    }

    const orderData = {
      customerName: 'MaRinaMaRt Customer',
      customerPhone: '+91 9999999999',
      paymentStatus: (walletAmountUsed > 0 && walletAmountUsed >= Number(createOrderDto.totalAmount)) ? 'Paid' : 'Pending',
      ...createOrderDto,
      orderNumber: orderNum,
    };

    const order = this.orderRepository.create(orderData);
    return await this.orderRepository.save(order);
  }

  async findAll(user: any) {
    console.log(`[ORDERS] Finding private orders for Account: ${user.userId}`);
    
    const query = this.orderRepository.createQueryBuilder('order')
      .leftJoinAndSelect('order.assignedRider', 'rider')
      .orderBy('order.createdAt', 'DESC');

    // Admins and SuperAdmins see ALL orders. Customers only see their own.
    if (user.role === UserRole.CUSTOMER) {
       console.log(`[ORDERS] Restricting to customer: ${user.userId}`);
       query.where('order.customerId = :userId', { userId: user.userId });
    } else {
       console.log(`[ORDERS] Role: ${user.role} - Showing all platform orders!`);
    }

    const orders = await query.getMany();
    console.log(`[ORDERS] Database found ${orders.length} private orders for this account`);

    // POPULATE PRODUCT NAMES for existing orders dynamically!
    // 1. Gather all product IDs from all orders
    const allProdIds = [...new Set(orders.flatMap((o: any) => o.items.map((i: any) => i.productId)))];
    
    if (allProdIds.length === 0) return orders;

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

  async findOne(id: string) {
    const order = await this.orderRepository.findOne({ 
      where: { id },
      relations: ['assignedRider']
    });
    if (!order) throw new NotFoundException('Order not found');

    const productIds = order.items.map((i: any) => i.productId);
    const products = await this.productRepository.find({ where: { id: In(productIds) } });

    order.items = order.items.map((item: any) => {
      const prod = products.find(p => p.id === item.productId);
      return {
        ...item,
        productName: item.productName || (prod ? prod.name : 'Unknown Product')
      };
    });

    return order;
  }

  async updateStatus(id: string, status: OrderStatus) {
    const order = await this.orderRepository.findOne({ where: { id } });
    if (!order) throw new NotFoundException('Order not found');
    order.status = status;
    return await this.orderRepository.save(order);
  }
}
