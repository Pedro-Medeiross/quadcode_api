import { NestFactory } from '@nestjs/core';
import { AppModule } from './app.module.js';
import { ValidationPipe, Logger } from '@nestjs/common';
import { ConfigService } from '@nestjs/config';
import { FastifyAdapter, NestFastifyApplication } from '@nestjs/platform-fastify';
import compress from '@fastify/compress';

import { SwaggerModule, DocumentBuilder } from '@nestjs/swagger';

async function bootstrap() {
  const app = await NestFactory.create<NestFastifyApplication>(
    AppModule,
    new FastifyAdapter(),
  );

  await app.register(compress);
  const configService = app.get(ConfigService);
  const port = configService.get<number>('PORT', 3000);
  const nodeEnv = configService.get<string>('NODE_ENV', 'development');

  app.setGlobalPrefix('api');
  app.enableCors();

  app.useGlobalPipes(
    new ValidationPipe({
      whitelist: true,
      forbidNonWhitelisted: true,
      transform: true,
    }),
  );

  // ✅ Configurar Swagger
  const config = new DocumentBuilder()
    .setTitle('Quadcode API')
    .setDescription('API de trading com SDK Quadcode (IQ Option / Avalon)')
    .setVersion('1.0')
    .addTag('trading')
    .build();

  const document = SwaggerModule.createDocument(app, config);
  SwaggerModule.setup('/docs', app, document);

  await app.listen({ port, host: '0.0.0.0' });
  Logger.log(`Server running on http://localhost:${port}/api`, 'Bootstrap');
  Logger.log(`Swagger disponível em http://localhost:${port}/docs`, 'Swagger');
  Logger.log(`Current environment: ${nodeEnv}`, 'Bootstrap');
}
bootstrap();
