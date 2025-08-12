# Stage 1: build
FROM node:20-alpine AS builder
WORKDIR /app

# instala deps **com dev** (precisa do @nestjs/cli)
COPY package*.json ./
RUN npm ci

# copia código e compila
COPY . .
RUN npm run build

# Stage 2: runtime
FROM node:20-alpine
WORKDIR /app
ENV NODE_ENV=production

# instala deps **sem dev**
COPY package*.json ./
RUN npm ci --omit=dev

# copia o build
COPY --from=builder /app/dist ./dist

# (opcional) EXPOSE não é obrigatório; o compose publica as portas
# EXPOSE 3001

# start
CMD ["node", "dist/main.js"]
