# Technology Stack

## Architecture

モノレポ構成によるクライアント・サーバー分離アーキテクチャ。RESTful APIを介してモバイルクライアントとバックエンドが通信する。

## Core Technologies

### Backend
- **Language**: TypeScript (strict mode)
- **Framework**: Fastify 5 with fastify-autoload
- **Runtime**: Node.js (ES2022)
- **Database**: PostgreSQL 16 via Prisma ORM
- **Validation**: Zod with fastify-type-provider-zod

### Mobile Client
- **Framework**: Flutter 3.10+
- **Language**: Dart
- **State Management**: Riverpod
- **Routing**: go_router
- **HTTP**: Dio
- **Code Generation**: Freezed, json_serializable

## Key Libraries

| Backend | Mobile |
|---------|--------|
| Prisma (ORM) | flutter_riverpod |
| Zod (Validation) | freezed (Immutable models) |
| pino-pretty (Logging) | go_router (Navigation) |
| @fastify/swagger (API Docs) | dio (HTTP client) |

## Development Standards

### Type Safety
- TypeScript: strict mode, no implicit any
- Dart: strong mode with flutter_lints

### Code Quality
- Backend: Biome (lint + format)
- Mobile: flutter_lints + analysis_options.yaml

### API Design
- OpenAPI/Swagger documentation (dev環境: `/docs`)
- Zod schemas for request/response validation

## Development Environment

### Required Tools
- Node.js 20+
- Flutter SDK 3.10+
- Docker (PostgreSQL)
- tsx (TypeScript execution)

### Common Commands

```bash
# Backend
cd backend && npm run dev          # 開発サーバー (port 3002)
npm run db:migrate                 # マイグレーション実行
npm run lint:fix                   # Biome lint修正

# Mobile
cd mobile-client && flutter run    # アプリ起動
flutter pub run build_runner build # コード生成

# Database
cd database && docker compose up -d  # PostgreSQL起動
```

## Key Technical Decisions

- **Fastify over Express**: パフォーマンスとTypeScript統合の優位性
- **Prisma over raw SQL**: 型安全なDBアクセスとマイグレーション管理
- **Riverpod over Provider/Bloc**: シンプルで型安全な状態管理
- **Freezed**: イミュータブルなデータモデルとJSON serialization

---
_Document standards and patterns, not every dependency_
