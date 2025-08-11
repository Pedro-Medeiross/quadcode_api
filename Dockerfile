# ---------- Stage 1: build (com devDependencies) ----------
FROM node:20-alpine AS builder
WORKDIR /app

# Instala de forma determinística
COPY package*.json ./
RUN npm ci

# Copia o código do projeto (o Dockerfile deve estar no mesmo diretório do código)
COPY . .

# Compila (ex.: script "build" chama "nest build" ou "tsc")
RUN npm run build

# ---------- Stage 2: runtime (somente prod deps) ----------
FROM node:20-alpine
WORKDIR /app
ENV NODE_ENV=production

# Apenas deps de produção
COPY package*.json ./
RUN npm ci --omit=dev

# Copia a build do stage anterior
COPY --from=builder /app/dist ./dist

# Dica: não use EXPOSE com variável (não expande). Pode omitir, o compose publica as portas.
# EXPOSE 3001

# Ajuste o entrypoint conforme o arquivo gerado no build
CMD ["node", "dist/main.js"]