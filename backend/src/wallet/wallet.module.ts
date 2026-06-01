import { Module } from '@nestjs/common';
import { TypeOrmModule } from '@nestjs/typeorm';
import { WalletService } from './wallet.service';
import { WalletController } from './wallet.controller';
import { WalletRequest } from './entities/wallet-request.entity';
import { WalletCoupon } from './entities/wallet-coupon.entity';
import { WalletCouponUsage } from './entities/wallet-coupon-usage.entity';
import { User } from '../users/entities/user.entity';

@Module({
  imports: [
    TypeOrmModule.forFeature([WalletRequest, WalletCoupon, WalletCouponUsage, User]),
  ],
  controllers: [WalletController],
  providers: [WalletService],
  exports: [WalletService],
})
export class WalletModule {}
