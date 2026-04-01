import { NestFactory } from '@nestjs/core';
import { ValidationPipe } from '@nestjs/common';
import { SwaggerModule, DocumentBuilder } from '@nestjs/swagger';
import { AppModule } from './app.module';

async function bootstrap() {
  const app = await NestFactory.create(AppModule);

  // Security: Enable CORS for the Admin Panel (Port 5173/5174/5175)
  app.enableCors({
    origin: '*', // For development, allow all
    methods: 'GET,HEAD,PUT,PATCH,POST,DELETE',
    credentials: true,
  });

  // Global Validation Pipeline
  app.useGlobalPipes(new ValidationPipe({
    whitelist: true,
    transform: true,
    forbidNonWhitelisted: true,
  }));

  // API Documentation (OpenAPI/Swagger)
  const config = new DocumentBuilder()
    .setTitle('Bloomarina Instamart API')
    .setDescription('The core grocery delivery API documentation')
    .setVersion('1.0')
    .addBearerAuth()
    .build();
  const document = SwaggerModule.createDocument(app, config);
  SwaggerModule.setup('docs', app, document);

  const port = process.env.PORT || 5001;
  await app.listen(port, '0.0.0.0');
  console.log(`Backend is running on: http://localhost:${port} (and reachable via your local IP)`);
  console.log(`API Documentation available at: http://localhost:${port}/docs`);
}
bootstrap();
