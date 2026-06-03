import { NestFactory } from '@nestjs/core';
import { AppModule } from '../app.module';
import { UsersService } from '../users/users.service';

async function bootstrap() {
  const app = await NestFactory.createApplicationContext(AppModule);
  const usersService = app.get(UsersService);
  const userRepo: any = (usersService as any).userRepository;

  const emailsToSeed = ['rvimalrajravi@gmail.com', 'rvimalrajcse@gmail.com', 'user@marinamart.com'];

  for (const email of emailsToSeed) {
    let user = await userRepo.findOne({ where: { email } });
    if (user) {
      console.log(`--- UPDATING USER: ${email} ---`);
      user.password = 'User@2026'; // this will be hashed by entity listener
      await userRepo.save(user);
    } else {
      console.log(`--- CREATING USER: ${email} ---`);
      user = userRepo.create({
        name: email.split('@')[0],
        email: email,
        password: 'User@2026',
        role: 'Customer',
        isActive: true,
      });
      await userRepo.save(user);
    }
  }

  await app.close();
  process.exit(0);
}

bootstrap();
