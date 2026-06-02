import { Controller, Get, Post, Body, Param, Delete, HttpStatus, HttpCode } from '@nestjs/common';
import { WalletService } from './wallet.service';
import { ApiTags, ApiOperation } from '@nestjs/swagger';

@ApiTags('Wallet')
@Controller('wallet')
export class WalletController {
  constructor(private readonly walletService: WalletService) {}

  // --- CUSTOMER ENDPOINTS ---

  @Post('request')
  @ApiOperation({ summary: 'Request to add money to wallet (requires admin approval)' })
  createRequest(@Body() body: { customerId: string; amount: number }) {
    return this.walletService.createRequest(body.customerId, body.amount);
  }

  @Get('request/customer/:customerId')
  @ApiOperation({ summary: 'Get all wallet requests for a customer' })
  getRequestsForCustomer(@Param('customerId') customerId: string) {
    return this.walletService.getRequestsForCustomer(customerId);
  }

  @Post('redeem')
  @ApiOperation({ summary: 'Redeem a coupon code to add money directly to wallet' })
  redeemCoupon(@Body() body: { customerId: string; code: string }) {
    return this.walletService.redeemCoupon(body.customerId, body.code);
  }

  // --- ADMIN ENDPOINTS ---

  @Get('request/admin')
  @ApiOperation({ summary: 'Get all wallet requests for admin approval review' })
  getAllRequests() {
    return this.walletService.getAllRequests();
  }

  @Post('request/:id/approve')
  @ApiOperation({ summary: 'Approve wallet request' })
  approveRequest(@Param('id') id: string) {
    return this.walletService.approveRequest(id);
  }

  @Post('request/:id/reject')
  @ApiOperation({ summary: 'Reject wallet request' })
  rejectRequest(@Param('id') id: string, @Body() body: { rejectedBy?: string }) {
    return this.walletService.rejectRequest(id, body.rejectedBy);
  }

  @Post('coupon')
  @ApiOperation({ summary: 'Create a wallet credit coupon code' })
  createCoupon(@Body() body: { code: string; amount: number; targetType: any; targetCustomerId?: string }) {
    return this.walletService.createCoupon(body);
  }

  @Get('coupon')
  @ApiOperation({ summary: 'Get all wallet credit coupons' })
  getAllCoupons() {
    return this.walletService.getAllCoupons();
  }

  @Delete('coupon/:id')
  @HttpCode(HttpStatus.NO_CONTENT)
  @ApiOperation({ summary: 'Delete a wallet coupon' })
  deleteCoupon(@Param('id') id: string) {
    return this.walletService.deleteCoupon(id);
  }
}
