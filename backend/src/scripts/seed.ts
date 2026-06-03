import { NestFactory } from '@nestjs/core';
import { AppModule } from '../app.module';
import { UsersService } from '../users/users.service';
import { UserRole } from '../users/entities/user.entity';

const SUPER_ADMIN = {
  name: 'Super Admin Vimal',
  email: 'tech@marinamart.com',
  password: 'WelcomeMM@2026',
  role: UserRole.SUPER_ADMIN,
  isActive: true,
};

async function bootstrap() {
  const app = await NestFactory.createApplicationContext(AppModule);
  const usersService = app.get(UsersService);
  const userRepo: any = (usersService as any).userRepository;

  console.log('--- RE-INITIALIZING SUPER ADMIN ---');

  // DELETE existing to force a fresh hash from the raw password
  await userRepo.delete({ email: SUPER_ADMIN.email });
  console.log(`Purged existing Super Admin account for fresh reset.`);

  // Create anew. ENTITY will hash correctly the RAW password.
  const superAdmin = userRepo.create(SUPER_ADMIN);
  await userRepo.save(superAdmin);
  
  console.log('-----------------------------------');
  console.log('SUCCESS: Super Admin Re-initialized!');
  console.log(`Email: ${SUPER_ADMIN.email}`);
  console.log('-----------------------------------');

  await app.close();
  process.exit(0);
}

bootstrap();
