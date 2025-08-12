# ---------- Stage 1: build ----------
FROM node:20-alpine AS builder
WORKDIR /app

# Dependências de sistema (se houver libs nativas)
RUN apk add --no-cache python3 make g++ git

# Copia manifestos e instala deps (DEV + PROD)
COPY package*.json ./
RUN npm ci

# Garante o CLI do Nest disponível no PATH
RUN npm i -g @nestjs/cli

# Copia o resto do código e compila
COPY . .
# Só pra ver versão do nest no build log (debug opcional)
RUN npx nest --version
RUN nest build

# ---------- Stage 2: runtime ----------
FROM node:20-alpine
WORKDIR /app
ENV NODE_ENV=production

# Só as deps de produção
COPY package*.json ./
RUN npm ci --omit=dev --ignore-scripts

# Artefatos compilados
COPY --from=builder /app/dist ./dist

# Não precisa fixar EXPOSE aqui (o Compose faz o bind), mas se quiser:
# EXPOSE 3001

CMD ["node", "dist/main"]
