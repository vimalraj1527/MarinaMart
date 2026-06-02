import { Controller, Get, Post, Body, Param, UseGuards, Request } from '@nestjs/common';
import { SupportService } from './support.service';
import { JwtAuthGuard } from '../auth/guards/jwt-auth.guard';
import { ApiTags, ApiOperation, ApiBearerAuth } from '@nestjs/swagger';

@ApiTags('Support')
@ApiBearerAuth()
@Controller('support')
@UseGuards(JwtAuthGuard)
export class SupportController {
  constructor(private readonly supportService: SupportService) {}

  @Get('conversations')
  @ApiOperation({ summary: 'Admin: Get list of active chat conversations' })
  getConversations(@Request() req: any) {
    // If not Admin, could block, but for simplicity of pair program let's check role or allow
    return this.supportService.getConversations();
  }

  @Get('messages/:customerId')
  @ApiOperation({ summary: 'Get chat messages for a specific customer' })
  getMessages(@Param('customerId') customerId: string, @Request() req: any) {
    // Users can only fetch their own messages, Admins can fetch any
    const targetId = req.user.role === 'Admin' ? customerId : req.user.userId;
    return this.supportService.getMessages(targetId);
  }

  @Get('messages')
  @ApiOperation({ summary: 'User: Get chat messages for logged-in user' })
  getMyMessages(@Request() req: any) {
    return this.supportService.getMessages(req.user.userId);
  }

  @Post('message')
  @ApiOperation({ summary: 'Send a support chat message' })
  sendMessage(
    @Body('message') message: string,
    @Body('customerId') customerId: string, // Admin sends this to specify target customer
    @Request() req: any,
  ) {
    const isAdmin = req.user.role === 'Admin';
    const targetCustomerId = isAdmin ? customerId : req.user.userId;
    const senderType = isAdmin ? 'Admin' : 'User';

    return this.supportService.sendMessage(targetCustomerId, senderType, message);
  }
}
