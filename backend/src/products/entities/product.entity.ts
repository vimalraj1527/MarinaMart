import { Entity, Column, PrimaryGeneratedColumn, CreateDateColumn, UpdateDateColumn, Index } from 'typeorm';

export class ColumnNumericTransformer {
  to(data: number): number {
    return data;
  }
  from(data: string): number {
    return parseFloat(data);
  }
}

@Entity('products')
export class Product {
  @PrimaryGeneratedColumn('uuid')
  id: string;

  @Column()
  @Index()
  name: string;

  @Column('text')
  description: string;

  @Column('decimal', { precision: 10, scale: 2, transformer: new ColumnNumericTransformer() })
  price: number;

  @Column('decimal', { precision: 10, scale: 2, nullable: true, transformer: new ColumnNumericTransformer() })
  originalPrice: number;

  @Column('text', { array: true })
  images: string[];

  @Column()
  @Index()
  category: string;

  @Column({ nullable: true })
  subCategory: string;

  @Column()
  unit: string; // kg, ltr, box

  @Column('int', { default: 0 })
  stock: number;

  @Column({ default: true })
  isAvailable: boolean;

  @Column({ default: false })
  isTrending: boolean;

  @Column('decimal', { precision: 2, scale: 1, default: 4.5, transformer: new ColumnNumericTransformer() })
  ratings: number;

  @Column('int', { default: 0 })
  reviewCount: number;

  @CreateDateColumn()
  createdAt: Date;

  @UpdateDateColumn()
  updatedAt: Date;
}
