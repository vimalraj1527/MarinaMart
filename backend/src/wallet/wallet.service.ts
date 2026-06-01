import { Injectable, NotFoundException, BadRequestException } from '@nestjs/common';
import { InjectRepository } from '@nestjs/typeorm';
import { Repository } from 'typeorm';
import { WalletRequest, WalletRequestStatus } from './entities/wallet-request.entity';
import { WalletCoupon, CouponTargetType } from './entities/wallet-coupon.entity';
import { WalletCouponUsage } from './entities/wallet-coupon-usage.entity';
import { User } from '../users/entities/user.entity';

@Injectable()
export class WalletService {
  constructor(
    @InjectRepository(WalletRequest)
    private readonly walletRequestRepo: Repository<WalletRequest>,
    @InjectRepository(WalletCoupon)
    private readonly walletCouponRepo: Repository<WalletCoupon>,
    @InjectRepository(WalletCouponUsage)
    private readonly walletCouponUsageRepo: Repository<WalletCouponUsage>,
    @InjectRepository(User)
    private readonly userRepo: Repository<User>,
  ) {}

  // --- WALLET REQUESTS ---

  async createRequest(customerId: string, amount: number): Promise<WalletRequest> {
    const user = await this.userRepo.findOne({ where: { id: customerId } });
    if (!user) {
      throw new NotFoundException('Customer not found');
    }

    if (amount <= 0) {
      throw new BadRequestException('Amount must be greater than zero');
    }

    const request = this.walletRequestRepo.create({
      customerId,
      amount,
      status: WalletRequestStatus.PENDING,
    });

    return await this.walletRequestRepo.save(request);
  }

  async getRequestsForCustomer(customerId: string): Promise<WalletRequest[]> {
    return await this.walletRequestRepo.find({
      where: { customerId },
      order: { createdAt: 'DESC' },
    });
  }

  async getAllRequests(): Promise<WalletRequest[]> {
    return await this.walletRequestRepo.find({
      relations: ['customer'],
      order: { createdAt: 'DESC' },
    });
  }

  async approveRequest(id: string): Promise<WalletRequest> {
    const request = await this.walletRequestRepo.findOne({
      where: { id },
      relations: ['customer'],
    });

    if (!request) {
      throw new NotFoundException('Wallet request not found');
    }

    if (request.status !== WalletRequestStatus.PENDING) {
      throw new BadRequestException(`Request is already ${request.status}`);
    }

    const user = await this.userRepo.findOne({ where: { id: request.customerId } });
    if (!user) {
      throw new NotFoundException('User associated with this request not found');
    }

    // Update user balance. Convert typeorm string decimal to float safely
    const currentBalance = typeof user.walletBalance === 'string' 
      ? parseFloat(user.walletBalance) 
      : Number(user.walletBalance || 0);
    
    const requestAmount = typeof request.amount === 'string'
      ? parseFloat(request.amount as any)
      : Number(request.amount);

    user.walletBalance = currentBalance + requestAmount;
    await this.userRepo.save(user);

    request.status = WalletRequestStatus.APPROVED;
    return await this.walletRequestRepo.save(request);
  }

  async rejectRequest(id: string): Promise<WalletRequest> {
    const request = await this.walletRequestRepo.findOne({ where: { id } });
    if (!request) {
      throw new NotFoundException('Wallet request not found');
    }

    if (request.status !== WalletRequestStatus.PENDING) {
      throw new BadRequestException(`Request is already ${request.status}`);
    }

    request.status = WalletRequestStatus.REJECTED;
    return await this.walletRequestRepo.save(request);
  }

  // --- WALLET COUPONS ---

  async createCoupon(data: {
    code: string;
    amount: number;
    targetType: CouponTargetType;
    targetCustomerId?: string;
  }): Promise<WalletCoupon> {
    // Check if code already exists
    const existing = await this.walletCouponRepo.findOne({ where: { code: data.code.toUpperCase() } });
    if (existing) {
      throw new BadRequestException('Coupon code already exists');
    }

    if (data.targetType === CouponTargetType.SPECIFIC && !data.targetCustomerId) {
      throw new BadRequestException('Target customer ID is required for specific coupons');
    }

    const coupon = this.walletCouponRepo.create({
      code: data.code.toUpperCase(),
      amount: data.amount,
      targetType: data.targetType,
      targetCustomerId: data.targetType === CouponTargetType.SPECIFIC ? data.targetCustomerId : null,
      isActive: true,
    });

    return await this.walletCouponRepo.save(coupon);
  }

  async getAllCoupons(): Promise<WalletCoupon[]> {
    return await this.walletCouponRepo.find({
      relations: ['targetCustomer'],
      order: { createdAt: 'DESC' },
    });
  }

  async deleteCoupon(id: string): Promise<void> {
    const coupon = await this.walletCouponRepo.findOne({ where: { id } });
    if (!coupon) {
      throw new NotFoundException('Coupon not found');
    }
    await this.walletCouponRepo.remove(coupon);
  }

  async redeemCoupon(customerId: string, code: string): Promise<{ success: boolean; message: string; walletBalance: number }> {
    const user = await this.userRepo.findOne({ where: { id: customerId } });
    if (!user) {
      throw new NotFoundException('User not found');
    }

    const coupon = await this.walletCouponRepo.findOne({ where: { code: code.toUpperCase() } });
    if (!coupon) {
      throw new NotFoundException('Coupon code not found');
    }

    if (!coupon.isActive) {
      throw new BadRequestException('Coupon code is not active');
    }

    // Check specific user targeting
    if (coupon.targetType === CouponTargetType.SPECIFIC && coupon.targetCustomerId !== customerId) {
      throw new BadRequestException('This coupon code is not valid for your account');
    }

    // Check if user has already used this coupon
    const usage = await this.walletCouponUsageRepo.findOne({
      where: { couponId: coupon.id, customerId },
    });

    if (usage) {
      throw new BadRequestException('You have already redeemed this coupon code');
    }

    // Update user balance
    const currentBalance = typeof user.walletBalance === 'string' 
      ? parseFloat(user.walletBalance) 
      : Number(user.walletBalance || 0);

    const couponAmount = typeof coupon.amount === 'string'
      ? parseFloat(coupon.amount as any)
      : Number(coupon.amount);

    user.walletBalance = currentBalance + couponAmount;
    await this.userRepo.save(user);

    // Save usage log
    const couponUsage = this.walletCouponUsageRepo.create({
      couponId: coupon.id,
      customerId,
    });
    await this.walletCouponUsageRepo.save(couponUsage);

    return {
      success: true,
      message: `Coupon redeemed successfully! Added ₹${couponAmount} to your wallet.`,
      walletBalance: user.walletBalance,
    };
  }
}
