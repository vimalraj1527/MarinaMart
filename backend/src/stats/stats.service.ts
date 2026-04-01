import { Injectable } from '@nestjs/common';
import { InjectRepository } from '@nestjs/typeorm';
import { Repository, Between } from 'typeorm';
import { Order, OrderStatus } from '../orders/entities/order.entity';
import { User, UserRole } from '../users/entities/user.entity';
import { Product } from '../products/entities/product.entity';

@Injectable()
export class StatsService {
  constructor(
    @InjectRepository(Order)
    private readonly orderRepository: Repository<Order>,
    @InjectRepository(User)
    private readonly userRepository: Repository<User>,
    @InjectRepository(Product)
    private readonly productRepository: Repository<Product>,
  ) {}

  async getDashboardData() {
    const today = new Date();
    const lastWeek = new Date(today);
    lastWeek.setDate(today.getDate() - 7);

    // 1. Core KPIs
    const [orders, totalUsers, totalProducts] = await Promise.all([
      this.orderRepository.find({ relations: ['assignedRider'] }),
      this.userRepository.count({ where: { role: UserRole.CUSTOMER, isActive: true } }),
      this.productRepository.count(),
    ]);

    const totalSales = orders
      .filter(o => o.status !== OrderStatus.CANCELLED)
      .reduce((sum, o) => sum + Number(o.totalAmount), 0);
    
    const pendingDeliveries = orders.filter(o => 
      [OrderStatus.PENDING, OrderStatus.PROCESSING, OrderStatus.OUT_FOR_DELIVERY].includes(o.status)
    ).length;

    // 2. Sales Trends (Last 7 Days)
    const days = ['Sun', 'Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat'];
    const salesTrends = [];
    
    for (let i = 6; i >= 0; i--) {
      const date = new Date();
      date.setDate(today.getDate() - i);
      const dayName = days[date.getDay()];
      
      const dayStart = new Date(date.setHours(0, 0, 0, 0));
      const dayEnd = new Date(date.setHours(23, 59, 59, 999));

      const dayOrders = orders.filter(o => 
        new Date(o.createdAt) >= dayStart && new Date(o.createdAt) <= dayEnd
      );

      salesTrends.push({
        name: dayName,
        sales: dayOrders.reduce((sum, o) => sum + Number(o.totalAmount), 0),
        orders: dayOrders.length
      });
    }

    // 3. Live Deliveries (Last 5)
    const liveDeliveries = orders
      .slice(0, 5)
      .map(o => ({
        id: o.orderNumber,
        status: o.status,
        address: o.deliveryAddress,
        rider: o.assignedRider?.name || 'Unassigned'
      }));

    return {
      stats: {
        totalSales,
        totalOrders: orders.length,
        activeUsers: totalUsers,
        pendingDeliveries,
      },
      salesTrends,
      liveDeliveries,
    };
  }
}
