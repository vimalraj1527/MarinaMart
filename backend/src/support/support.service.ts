import { Injectable } from '@nestjs/common';
import { InjectRepository } from '@nestjs/typeorm';
import { Repository } from 'typeorm';
import { SupportMessage } from './entities/support-message.entity';
import { User } from '../users/entities/user.entity';

@Injectable()
export class SupportService {
  constructor(
    @InjectRepository(SupportMessage)
    private readonly supportMessageRepo: Repository<SupportMessage>,
    @InjectRepository(User)
    private readonly userRepo: Repository<User>,
  ) {}

  async sendMessage(customerId: string, senderType: 'User' | 'Admin', message: string): Promise<SupportMessage> {
    const msg = this.supportMessageRepo.create({
      customerId,
      senderType,
      message,
    });
    return this.supportMessageRepo.save(msg);
  }

  async getMessages(customerId: string): Promise<SupportMessage[]> {
    return this.supportMessageRepo.find({
      where: { customerId },
      order: { createdAt: 'ASC' },
    });
  }

  async getConversations(): Promise<any[]> {
    // Run raw TypeORM query or subquery to select conversations grouped by customerId with last message details
    const rawConversations = await this.supportMessageRepo.createQueryBuilder('msg')
      .select('msg.customer_id', 'customerId')
      .addSelect('MAX(msg.createdAt)', 'lastMessageTime')
      .groupBy('msg.customer_id')
      .getRawMany();

    const conversations = [];
    for (const conv of rawConversations) {
      const customer = await this.userRepo.findOne({ where: { id: conv.customerId } });
      const lastMsg = await this.supportMessageRepo.findOne({
        where: { customerId: conv.customerId },
        order: { createdAt: 'DESC' },
      });

      conversations.push({
        customerId: conv.customerId,
        customerName: customer ? customer.name : 'Unknown Customer',
        customerPhone: customer ? customer.phone : 'N/A',
        lastMessage: lastMsg ? lastMsg.message : '',
        lastMessageSender: lastMsg ? lastMsg.senderType : 'User',
        lastMessageTime: conv.lastMessageTime,
      });
    }

    // Sort by last message time descending
    return conversations.sort((a, b) => new Date(b.lastMessageTime).getTime() - new Date(a.lastMessageTime).getTime());
  }
}
