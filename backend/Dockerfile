# ============================================
# Production image with tsx
# ============================================
FROM node:24-bullseye-slim

WORKDIR /app

COPY package*.json ./
COPY prisma ./prisma/

# tsx は devDependencies にあるため、全ての依存関係をインストール
RUN npm ci && npx prisma generate

COPY src ./src
COPY tsconfig.json ./

ENV NODE_ENV=production

EXPOSE 3002

CMD ["npm", "start"]
