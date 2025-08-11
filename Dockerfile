# Stage 1: build (com devDependencies)
FROM node:20-alpine AS builder
WORKDIR /app

# Instalação determinística
COPY package*.json ./
RUN npm ci

# Copia o código e compila
COPY . .
# Garante que o script "build" funcione (ex: "nest build" ou "tsc -p tsconfig.build.json")
RUN npm run build

# Stage 2: runtime (somente prod deps)
FROM node:20-alpine AS runtime
WORKDIR /app
ENV NODE_ENV=production

COPY package*.json ./
# Apenas deps de produção
RUN npm ci --omit=dev

# Copia a build do stage anterior
COPY --from=builder /app/dist ./dist

# EXPOSE é opcional (compose publica as portas). Pode omitir ou usar um número fixo.
# EXPOSE 3001

# Ajuste o nome do arquivo conforme sua build (geralmente main.js)
CMD ["node", "dist/main.js"]
