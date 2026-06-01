import { Entity, Column, PrimaryGeneratedColumn, CreateDateColumn, ManyToOne, JoinColumn } from 'typeorm';
import { User } from '../../users/entities/user.entity';

export enum CouponTargetType {
  ALL = 'All',
  SPECIFIC = 'Specific',
}

@Entity('wallet_coupons')
export class WalletCoupon {
  @PrimaryGeneratedColumn('uuid')
  id: string;

  @Column({ unique: true })
  code: string;

  @Column('decimal', { precision: 10, scale: 2 })
  amount: number;

  @Column({
    type: 'enum',
    enum: CouponTargetType,
    default: CouponTargetType.ALL,
  })
  targetType: CouponTargetType;

  @Column({ nullable: true })
  targetCustomerId?: string | null;

  @ManyToOne(() => User, { nullable: true, onDelete: 'SET NULL' })
  @JoinColumn({ name: 'targetCustomerId' })
  targetCustomer: User;

  @Column({ default: true })
  isActive: boolean;

  @CreateDateColumn()
  createdAt: Date;
}
