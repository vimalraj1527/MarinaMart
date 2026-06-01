import { Entity, Column, PrimaryGeneratedColumn, CreateDateColumn, ManyToOne, JoinColumn } from 'typeorm';
import { WalletCoupon } from './wallet-coupon.entity';
import { User } from '../../users/entities/user.entity';

@Entity('wallet_coupon_usages')
export class WalletCouponUsage {
  @PrimaryGeneratedColumn('uuid')
  id: string;

  @Column()
  couponId: string;

  @ManyToOne(() => WalletCoupon, { onDelete: 'CASCADE' })
  @JoinColumn({ name: 'couponId' })
  coupon: WalletCoupon;

  @Column()
  customerId: string;

  @ManyToOne(() => User, { onDelete: 'CASCADE' })
  @JoinColumn({ name: 'customerId' })
  customer: User;

  @CreateDateColumn()
  redeemedAt: Date;
}
