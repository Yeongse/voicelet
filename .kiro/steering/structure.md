# Project Structure

## Organization Philosophy

**モノレポ + レイヤードアーキテクチャ**: バックエンドとモバイルクライアントを同一リポジトリで管理。各プロジェクトは関心の分離を意識したディレクトリ構成を採用。

## Directory Patterns

### Project Root
```
.
├── backend/           # Fastify API server
├── mobile-client/     # Flutter mobile app
├── database/          # Docker compose for PostgreSQL
└── docs/              # Project documentation
```

### Backend (`/backend/`)
**Philosophy**: Controller-Service-Model パターン

```
backend/
├── src/
│   ├── controller/    # Route handlers (autoloaded)
│   │   └── {resource}/
│   │       ├── controller.ts
│   │       ├── schema.ts
│   │       └── _paramName/  # Dynamic routes
│   ├── lib/           # Shared utilities
│   ├── model/         # Domain models
│   ├── database.ts    # Prisma client export
│   └── main.ts        # App entry point
└── prisma/
    ├── schema.prisma  # DB schema
    ├── migrations/    # DB migrations
    └── seed/          # Seed data
```

**Route Convention**: `_paramName` ディレクトリはURLパラメータに変換される
- `controller/users/_userId/` → `/api/users/:userId`

### Mobile Client (`/mobile-client/lib/`)
**Philosophy**: Feature-first + Core utilities

```
lib/
├── core/              # Shared infrastructure
│   └── api/           # HTTP client
├── features/          # Feature modules
│   └── {feature}/
│       ├── models/    # Data models (freezed)
│       ├── pages/     # UI screens
│       └── providers/ # Riverpod providers
├── l10n/              # Localization
└── main.dart          # App entry point
```

## Naming Conventions

### Backend (TypeScript)
- **Files**: kebab-case (`user-service.ts`)
- **Classes**: PascalCase (`UserService`)
- **Functions**: camelCase (`getUser`)
- **Schema files**: `schema.ts` (per controller)

### Mobile (Dart)
- **Files**: snake_case (`user_detail_page.dart`)
- **Classes**: PascalCase (`UserDetailPage`)
- **Providers**: camelCase suffix `Provider` (`usersProvider`)

## Import Organization

### Backend
```typescript
// Node built-ins
import path from "node:path";

// External packages
import Fastify from "fastify";

// Internal modules (path alias)
import { prisma } from "@/database";
import { ServerInstance } from "@/lib/fastify";
```

**Path Aliases**:
- `@/`: maps to `./src/`

### Mobile
```dart
// Dart/Flutter SDK
import 'package:flutter/material.dart';

// External packages
import 'package:flutter_riverpod/flutter_riverpod.dart';

// Internal (relative)
import '../models/user.dart';
```

## Code Organization Principles

- **Controller per resource**: 1つのリソースに対して1つのcontrollerディレクトリ
- **Schema co-location**: Zodスキーマはcontrollerと同階層に配置
- **Feature isolation**: Mobileは機能単位で完結したディレクトリ構成
- **Shared utilities in lib/core**: 横断的な機能はcoreに集約

---
_Document patterns, not file trees. New files following patterns shouldn't require updates_
