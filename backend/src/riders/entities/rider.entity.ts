import { Entity, Column, PrimaryGeneratedColumn, CreateDateColumn, UpdateDateColumn, Index } from 'typeorm';

export enum RiderStatus {
  AVAILABLE = 'Available',
  ON_DELIVERY = 'On Delivery',
  OFFLINE = 'Offline',
  ON_BREAK = 'On Break',
}

@Entity('riders')
export class Rider {
  @PrimaryGeneratedColumn('uuid')
  id: string;

  @Column()
  @Index()
  name: string;

  @Column({ unique: true })
  email: string;

  @Column({ unique: true })
  phone: string;

  @Column({ default: 'Bike' })
  vehicleType: string;

  @Column({
    type: 'enum',
    enum: RiderStatus,
    default: RiderStatus.OFFLINE,
  })
  status: RiderStatus;

  @Column('decimal', { precision: 2, scale: 1, default: 4.5 })
  rating: number;

  @Column('int', { default: 0 })
  totalDeliveries: number;

  @Column({ nullable: true })
  currentLatitude: number;

  @Column({ nullable: true })
  currentLongitude: number;

  @CreateDateColumn()
  createdAt: Date;

  @UpdateDateColumn()
  updatedAt: Date;
}
