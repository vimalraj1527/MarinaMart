import { Entity, Column, PrimaryGeneratedColumn, CreateDateColumn, UpdateDateColumn, Index, ManyToOne } from 'typeorm';
import { Rider } from '../../riders/entities/rider.entity';

export enum OrderStatus {
  PENDING = 'Pending',
  PROCESSING = 'Processing',
  OUT_FOR_DELIVERY = 'Out for Delivery',
  DELIVERED = 'Delivered',
  CANCELLED = 'Cancelled',
}

import { User } from '../../users/entities/user.entity';

@Entity('orders')
export class Order {
  @PrimaryGeneratedColumn('uuid')
  id: string;

  @Column()
  @Index()
  orderNumber: string; // Readable ID e.g. ORD-1001

  @ManyToOne(() => User, { nullable: true })
  customer: User;

  @Column({ nullable: true })
  customerId: string;

  @Column()
  customerName: string;

  @Column()
  customerPhone: string;

  @Column('text')
  deliveryAddress: string;

  @Column('decimal', { precision: 10, scale: 2 })
  totalAmount: number;

  @Column({
    type: 'enum',
    enum: OrderStatus,
    default: OrderStatus.PENDING,
  })
  status: OrderStatus;

  @Column('jsonb')
  items: any[]; // List of products, quantity, and prices

  @Column({ default: 'Online' })
  paymentMethod: string;

  @Column({ default: 'Paid' })
  paymentStatus: string;

  @ManyToOne(() => Rider, { nullable: true })
  assignedRider: Rider;

  @CreateDateColumn()
  createdAt: Date;

  @UpdateDateColumn()
  updatedAt: Date;
}
