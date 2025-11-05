# Bar Website MVP

Веб-приложение для бара с меню, заказами и бронированием столов.

## Структура проекта

```
.
├── backend/          # Go REST API сервер
├── frontend/         # React + TypeScript SPA
├── database/         # SQL скрипты и миграции
├── nginx/            # Nginx конфигурация для reverse proxy
└── docker-compose.yml
```

## Технологии

- **Backend**: Go 1.21, Gin Framework, PostgreSQL
- **Frontend**: React 18, TypeScript, Vite, PWA
- **Database**: PostgreSQL 16
- **Deployment**: Docker, Nginx

## Быстрый старт

### Предварительные требования

- Docker и Docker Compose
- Go 1.21+ (для локальной разработки)
- Node.js 20+ (для локальной разработки)

### Запуск с Docker

1. Клонируйте репозиторий
2. Создайте SSL сертификаты для разработки:

```bash
cd nginx/ssl
openssl req -x509 -nodes -days 365 -newkey rsa:2048 -keyout key.pem -out cert.pem
cd ../..
```

3. Запустите все сервисы:

```bash
docker-compose up -d
```

4. Приложение будет доступно:
   - Frontend: http://localhost (или https://localhost:443)
   - Backend API: http://localhost:8080
   - PostgreSQL: localhost:5432

### Локальная разработка

**Backend:**

```bash
cd backend
go mod download
go run main.go
```

**Frontend:**

```bash
cd frontend
npm install
npm run dev
```

## Переменные окружения

Создайте файл `.env` в корне проекта:

```env
JWT_SECRET=your-secret-key-change-in-production
```

## Развертывание в баре

### Локальный сервер

1. Установите Docker на сервер (мини-ПК или Raspberry Pi)
2. Настройте роутер Keenetic для проброса портов 80 и 443
3. Получите SSL сертификат через KeenDNS
4. Запустите приложение через docker-compose

### Настройка KeenDNS

1. Зарегистрируйте домен в KeenDNS (например, `bar-name.keenetic.pro`)
2. Включите DDNS на роутере Keenetic
3. Настройте проброс портов:
   - 80 → 80 (HTTP)
   - 443 → 443 (HTTPS)
4. SSL сертификат будет получен автоматически

## Архитектура

Приложение работает в двух режимах:

1. **Локальная сеть (внутри бара)**: Устройства подключаются напрямую к локальному серверу
2. **Внешний доступ**: Через KeenDNS домен с автоматическим SSL

## Разработка

### Структура backend

```
backend/
├── handlers/      # HTTP обработчики
├── models/        # Модели данных
├── repository/    # Слой доступа к БД
├── middleware/    # Middleware (auth, cors, etc.)
└── utils/         # Утилиты
```

### Структура frontend

```
frontend/src/
├── components/    # React компоненты
├── pages/         # Страницы
├── hooks/         # Custom hooks
├── services/      # API сервисы
└── types/         # TypeScript типы
```

## Лицензия

Proprietary
