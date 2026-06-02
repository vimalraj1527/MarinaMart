import { Entity, PrimaryGeneratedColumn, Column, CreateDateColumn, ManyToOne } from 'typeorm';
import { User } from '../../users/entities/user.entity';

@Entity('support_messages')
export class SupportMessage {
  @PrimaryGeneratedColumn('uuid')
  id: string;

  @Column({ name: 'customer_id' })
  customerId: string;

  @ManyToOne(() => User, { onDelete: 'CASCADE' })
  customer: User;

  @Column({
    type: 'enum',
    enum: ['User', 'Admin'],
  })
  senderType: 'User' | 'Admin';

  @Column({ type: 'text' })
  message: string;

  @CreateDateColumn({ type: 'timestamp' })
  createdAt: Date;
}
