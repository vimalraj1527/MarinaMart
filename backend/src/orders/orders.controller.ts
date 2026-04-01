import { Controller, Get, Post, Body, Patch, Param } from '@nestjs/common';
import { OrdersService } from './orders.service';
import { OrderStatus } from './entities/order.entity';
import { ApiTags, ApiOperation } from '@nestjs/swagger';

@ApiTags('Orders')
@Controller('orders')
export class OrdersController {
  constructor(private readonly ordersService: OrdersService) {}

  @Post()
  @ApiOperation({ summary: 'Create a new customer order' })
  create(@Body() createOrderDto: any) {
    return this.ordersService.create(createOrderDto);
  }

  @Get()
  @ApiOperation({ summary: 'Get all live orders' })
  findAll() {
    return this.ordersService.findAll();
  }

  @Patch(':id/status')
  @ApiOperation({ summary: 'Update order delivery status' })
  updateStatus(@Param('id') id: string, @Body('status') status: OrderStatus) {
    return this.ordersService.updateStatus(id, status);
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
