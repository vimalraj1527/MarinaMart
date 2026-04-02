import { Module } from '@nestjs/common';
import { ServeStaticModule } from '@nestjs/serve-static';
import { join } from 'path';
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
import { StatsModule } from './stats/stats.module';
import { SettingsModule } from './settings/settings.module';
import { Setting } from './settings/entities/setting.entity';

@Module({
  imports: [
    ConfigModule.forRoot({
      isGlobal: true,
    }),
    ServeStaticModule.forRoot({
      rootPath: join(__dirname, '..', 'uploads'),
      serveRoot: '/uploads',
    }),
    TypeOrmModule.forRoot({
      type: 'postgres',
      host: process.env.DB_HOST || 'localhost',
      port: parseInt(process.env.DB_PORT || '5433'),
      username: process.env.DB_USER || 'grocery_user',
      password: process.env.DB_PASSWORD || 'grocery_password',
      database: process.env.DB_NAME || 'grocery_delivery',
      entities: [Product, Category, Setting],
      synchronize: true, // Auto-create tables (Dev only)
      autoLoadEntities: true,
    }),
    CategoriesModule,
    ProductsModule,
    OrdersModule,
    RidersModule,
    UsersModule,
    AuthModule,
    StatsModule,
    SettingsModule,
  ],
})
export class AppModule {}
