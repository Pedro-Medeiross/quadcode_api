# ---------- Stage 1: build ----------
FROM node:20-bullseye-slim AS builder
WORKDIR /app

# deps de toolchain (para eventuais builds nativos)
RUN apt-get update \
 && apt-get install -y --no-install-recommends python3 make g++ git ca-certificates \
 && rm -rf /var/lib/apt/lists/*

COPY package*.json ./
# instala deps completas para compilar
RUN npm ci

# CLI do Nest só no build stage (não vai pro runtime)
RUN npm i -g @nestjs/cli

# copia o código e compila
COPY . .
RUN npx nest --version && nest build

# ---------- Stage 2: runtime ----------
FROM node:20-bullseye-slim
WORKDIR /app
ENV NODE_ENV=production

COPY package*.json ./
# instala só deps de prod, sem scripts (seguro/rápido)
RUN npm ci --omit=dev --ignore-scripts

# copia os artefatos compilados
COPY --from=builder /app/dist ./dist

# porta é lida via env PORT no runtime (EXPOSE é opcional)
# EXPOSE 3001

CMD ["node", "dist/main"]
