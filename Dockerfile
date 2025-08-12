# ---------- Stage 1: build ----------
FROM node:20-alpine AS builder
WORKDIR /app

# troca o mirror pra evitar "temporary error" e atualiza índices
RUN sed -i 's/dl-cdn.alpinelinux.org/mirrors.alpinelinux.org/g' /etc/apk/repositories \
 && apk update

# build-base = gcc/g++/make; python3 e git se realmente precisar
RUN apk add --no-cache build-base python3 git

COPY package*.json ./
RUN npm ci

# garante o CLI do Nest disponível
RUN npm i -g @nestjs/cli

COPY . .
RUN npx nest --version && nest build

# ---------- Stage 2: runtime ----------
FROM node:20-alpine
WORKDIR /app
ENV NODE_ENV=production

COPY package*.json ./
RUN npm ci --omit=dev --ignore-scripts

COPY --from=builder /app/dist ./dist

CMD ["node", "dist/main"]
