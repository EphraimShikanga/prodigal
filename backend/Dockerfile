FROM node:20-slim AS builder

WORKDIR /usr/src/app

COPY package*.json ./
COPY prisma ./prisma/

RUN npm ci --no-audit --no-fund

COPY . .

RUN npx prisma generate
RUN npm run build

FROM node:20-slim

WORKDIR /usr/src/app

COPY package*.json ./
RUN npm ci --omit=dev --no-audit --no-fund --legacy-peer-deps

COPY --from=builder /usr/src/app/dist ./dist
COPY --from=builder /usr/src/app/node_modules/.prisma ./node_modules/.prisma
COPY --from=builder /usr/src/app/prisma ./prisma

EXPOSE 3000

CMD ["node", "dist/src/main"]
