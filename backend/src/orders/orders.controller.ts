import { Controller, Get, Post, Body, Patch, Param, UseGuards, Request } from '@nestjs/common';
import { OrdersService } from './orders.service';
import { OrderStatus } from './entities/order.entity';
import { ApiTags, ApiOperation, ApiBearerAuth } from '@nestjs/swagger';
import { JwtAuthGuard } from '../auth/guards/jwt-auth.guard';

@ApiTags('Orders')
@ApiBearerAuth()
@Controller('orders')
@UseGuards(JwtAuthGuard)
export class OrdersController {
  constructor(private readonly ordersService: OrdersService) {}

  @Post()
  @ApiOperation({ summary: 'Create a new customer order' })
  create(@Body() createOrderDto: any, @Request() req: any) {
    // Automatically link the order to the logged-in user
    createOrderDto.customerId = req.user.userId;
    return this.ordersService.create(createOrderDto);
  }

  @Get()
  @ApiOperation({ summary: 'Get live orders for the current user' })
  findAll(@Request() req: any) {
    console.log(`[ORDERS_CONTROLLER] req.user: ${JSON.stringify(req.user)}`);
    if (!req.user || !req.user.userId) {
       console.error('[ORDERS_CONTROLLER] Error: userId is missing from token!');
    }
    return this.ordersService.findAll(req.user);
  }

  @Get(':id')
  @ApiOperation({ summary: 'Get detailed order information' })
  findOne(@Param('id') id: string) {
    return this.ordersService.findOne(id);
  }

  @Patch(':id/status')
  @ApiOperation({ summary: 'Update order delivery status' })
  updateStatus(@Param('id') id: string, @Body('status') status: OrderStatus) {
    return this.ordersService.updateStatus(id, status);
  }

  @Patch(':id/approve-payment')
  @ApiOperation({ summary: 'Approve UPI payment for an order' })
  approvePayment(@Param('id') id: string) {
    return this.ordersService.approvePayment(id);
  }

  @Patch(':id/reject-payment')
  @ApiOperation({ summary: 'Reject payment for an order' })
  rejectPayment(@Param('id') id: string) {
    return this.ordersService.rejectPayment(id);
  }

  @Patch(':id/assign/:riderId')
  @ApiOperation({ summary: 'Assign a rider to an order' })
  async assignRider(@Param('id') id: string, @Param('riderId') riderId: string) {
    const order = await (this.ordersService as any).orderRepository.findOne({ where: { id } });
    if (!order) throw new Error('Order not found');
    order.assignedRider = { id: riderId };
    order.status = OrderStatus.PROCESSING;
    return await (this.ordersService as any).orderRepository.save(order);
  }
}
