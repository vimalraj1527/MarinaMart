import { Module } from '@nestjs/common';
import { TypeOrmModule } from '@nestjs/typeorm';
import { ConfigModule } from '@nestjs/config';
import { ProductsModule } from './products/products.module';
import { Product } from './products/entities/product.entity';
import { CategoriesModule } from './categories/categories.module';
import { Category } from './categories/entities/category.entity';
import { OrdersModule } from './orders/orders.module';
import { RidersModule } from './riders/riders.module';
import { UsersModule } from './users/users.module';
import { AuthModule } from './auth/auth.module';

@Module({
  imports: [
    ConfigModule.forRoot({
      isGlobal: true,
    }),
    TypeOrmModule.forRoot({
      type: 'postgres',
      host: process.env.DB_HOST || 'localhost',
      port: parseInt(process.env.DB_PORT || '5433'),
      username: process.env.DB_USER || 'grocery_user',
      password: process.env.DB_PASSWORD || 'grocery_password',
      database: process.env.DB_NAME || 'grocery_delivery',
      entities: [Product, Category],
      synchronize: true, // Auto-create tables (Dev only)
      autoLoadEntities: true,
    }),
    CategoriesModule,
    ProductsModule,
    OrdersModule,
    RidersModule,
    UsersModule,
    AuthModule,
  ],
})
export class AppModule {}
