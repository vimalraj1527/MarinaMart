import { NestFactory } from '@nestjs/core';
import { AppModule } from '../app.module';
import { UsersService } from '../users/users.service';

async function bootstrap() {
  const app = await NestFactory.createApplicationContext(AppModule);
  const usersService = app.get(UsersService);
  const userRepo: any = (usersService as any).userRepository;

  const users = await userRepo.find({ where: { role: 'Customer' } });
  if (users.length > 0) {
    console.log('--- FOUND USER ---');
    console.log(`Email: ${users[0].email}`);
    // we can't easily get the plain text password, but we can reset it
    users[0].password = 'User@2026'; // this will be hashed by entity listener
    await userRepo.save(users[0]);
    console.log(`Password reset to: User@2026`);
  } else {
    console.log('--- CREATING USER ---');
    const newUser = userRepo.create({
      name: 'Test User',
      email: 'user@bloomarina.com',
      password: 'User@2026',
      role: 'Customer',
      isActive: true,
    });
    await userRepo.save(newUser);
    console.log(`Email: user@bloomarina.com`);
    console.log(`Password: User@2026`);
  }

  await app.close();
  process.exit(0);
}

bootstrap();
