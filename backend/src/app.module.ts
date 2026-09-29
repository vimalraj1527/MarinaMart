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
import { BannersModule } from './banners/banners.module';
import { Banner } from './banners/entities/banner.entity';
import { WalletModule } from './wallet/wallet.module';
import { SupportModule } from './support/support.module';

@Module({
  imports: [
    ConfigModule.forRoot({
      isGlobal: true,
    }),
    ServeStaticModule.forRoot({
      rootPath: join(__dirname, '..', 'uploads'),
      serveRoot: '/uploads',
    }),
    TypeOrmModule.forRootAsync({
      useFactory: () => {
        const dbUrl = process.env.DATABASE_URL;
        const useSsl = process.env.DB_SSL === 'true' || !!process.env.DATABASE_URL;
        return {
          type: 'postgres',
          ...(dbUrl ? { url: dbUrl } : {
            host: process.env.DB_HOST || 'localhost',
            port: parseInt(process.env.DB_PORT || '5433'),
            username: process.env.DB_USER || 'grocery_user',
            password: process.env.DB_PASSWORD || 'grocery_password',
            database: process.env.DB_NAME || 'grocery_delivery',
          }),
          entities: [Product, Category, Setting, Banner],
          synchronize: true, // Auto-create tables
          autoLoadEntities: true,
          ssl: useSsl ? { rejectUnauthorized: false } : false,
        };
      },
    }),
    CategoriesModule,
    ProductsModule,
    OrdersModule,
    RidersModule,
    UsersModule,
    AuthModule,
    StatsModule,
    SettingsModule,
    BannersModule,
    WalletModule,
    SupportModule,
  ],
})
export class AppModule {}
