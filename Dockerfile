# ---------- Stage 1: build ----------
FROM node:20-bullseye-slim AS builder
WORKDIR /app

RUN apt-get update \
 && apt-get install -y --no-install-recommends python3 make g++ git ca-certificates \
 && rm -rf /var/lib/apt/lists/*

COPY package*.json ./
RUN npm ci

RUN npm i -g @nestjs/cli

COPY . .
RUN npx nest --version && nest build

# ---------- Stage 2: runtime ----------
FROM node:20-bullseye-slim
WORKDIR /app
ENV NODE_ENV=production

COPY package*.json ./
RUN npm ci --omit=dev --ignore-scripts

COPY --from=builder /app/dist ./dist

CMD ["node", "dist/main"]