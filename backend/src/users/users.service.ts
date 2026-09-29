import { Injectable, NotFoundException, BadRequestException } from '@nestjs/common';
import { InjectRepository } from '@nestjs/typeorm';
import { Repository } from 'typeorm';
import { User, UserRole } from './entities/user.entity';
import { Order } from '../orders/entities/order.entity';

@Injectable()
export class UsersService {
  constructor(
    @InjectRepository(User)
    private readonly userRepository: Repository<User>,
    @InjectRepository(Order)
    private readonly orderRepository: Repository<Order>,
  ) {}

  async findByEmail(email: string): Promise<User | null> {
    if (!email) return null;
    return this.userRepository.findOne({ where: { email: email.trim() } });
  }

  async findByPhone(phone: string): Promise<User | null> {
    if (!phone) return null;
    const cleanPhone = phone.replace(/\D/g, '').slice(-10);
    return this.userRepository.findOne({ where: { phone: cleanPhone } });
  }

  async findByIdentifier(identifier: string): Promise<User | null> {
    if (!identifier) return null;
    const cleanStr = identifier.trim();
    // Try email lookup
    const userByEmail = await this.userRepository.findOne({ where: { email: cleanStr } });
    if (userByEmail) return userByEmail;

    // Try phone lookup
    const cleanPhone = cleanStr.replace(/\D/g, '').slice(-10);
    if (cleanPhone.length === 10) {
      const userByPhone = await this.userRepository.findOne({ where: { phone: cleanPhone } });
      if (userByPhone) return userByPhone;
    }

    return null;
  }

  async saveOtp(phone: string, otp: string, expiresAt: Date): Promise<User | null> {
    let user = await this.findByPhone(phone);
    if (!user) {
      // Auto-register guest / placeholder user for this phone number if needed
      user = this.userRepository.create({
        phone,
        name: `User ${phone.slice(-4)}`,
        email: `user_${phone}@marinamart.com`,
        password: `Otp@${otp}`,
      });
    }
    user.otpCode = otp;
    user.otpExpiresAt = expiresAt;
    return await this.userRepository.save(user);
  }

  async create(createUserDto: any) {
    const user = this.userRepository.create(createUserDto);
    return await this.userRepository.save(user);
  }

  async findAll(role?: UserRole) {
    const where: any = {};
    if (role) where.role = role;
    const users = await this.userRepository.find({ where, order: { createdAt: 'DESC' } });
    
    const allOrders = await this.orderRepository.find();

    return users.map(user => {
      const userOrders = allOrders.filter(o => o.customerId === user.id);
      const totalOrderValue = userOrders.reduce((sum, o) => {
        const val = typeof o.totalAmount === 'string' ? parseFloat(o.totalAmount) : Number(o.totalAmount);
        return sum + (isNaN(val) ? 0 : val);
      }, 0);

      return {
        ...user,
        orderCount: userOrders.length,
        totalValue: totalOrderValue,
        orders: userOrders
      };
    });
  }

  async findOne(id: string) {
    const user = await this.userRepository.findOne({ where: { id } });
    if (!user) throw new NotFoundException('User not found');
    
    const userOrders = await this.orderRepository.find({ 
      where: { customerId: id },
      order: { createdAt: 'DESC' }
    });

    const totalOrderValue = userOrders.reduce((sum, o) => {
      const val = typeof o.totalAmount === 'string' ? parseFloat(o.totalAmount) : Number(o.totalAmount);
      return sum + (isNaN(val) ? 0 : val);
    }, 0);
    
    return {
      ...user,
      orderCount: userOrders.length,
      totalValue: totalOrderValue,
      orders: userOrders
    };
  }

  async update(id: string, updateUserDto: any) {
    const user = await this.userRepository.findOne({ where: { id } });
    if (!user) throw new NotFoundException('User not found');
    
    if (updateUserDto.email !== undefined && updateUserDto.email !== user.email) {
      const existingEmail = await this.userRepository.findOne({ where: { email: updateUserDto.email } });
      if (existingEmail) {
        throw new BadRequestException('Email address is already in use by another account');
      }
    }

    if (updateUserDto.phone !== undefined && updateUserDto.phone !== user.phone) {
      const existingPhone = await this.userRepository.findOne({ where: { phone: updateUserDto.phone } });
      if (existingPhone) {
        throw new BadRequestException('Phone number is already in use by another account');
      }
    }

    if (updateUserDto.name !== undefined) user.name = updateUserDto.name;
    if (updateUserDto.email !== undefined) user.email = updateUserDto.email;
    if (updateUserDto.phone !== undefined) user.phone = updateUserDto.phone;
    if (updateUserDto.birthday !== undefined) user.birthday = updateUserDto.birthday;
    if (updateUserDto.password !== undefined && updateUserDto.password !== '') {
      user.password = updateUserDto.password;
    }
    
    const savedUser = await this.userRepository.save(user);
    const { password, ...result } = savedUser;
    return result;
  }

  async remove(id: string) {
    const user = await this.userRepository.findOne({ where: { id } });
    if (!user) throw new NotFoundException('User account not found');
    await this.userRepository.remove(user);
    return { success: true, message: 'User account permanently deleted' };
  }
}
