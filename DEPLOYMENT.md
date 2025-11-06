# Руководство по развертыванию

## Обзор инфраструктуры

Приложение состоит из следующих компонентов:
- **PostgreSQL** - база данных (порт 5432)
- **Go Backend** - REST API сервер (порт 8080)
- **React Frontend** - SPA приложение (порт 80)
- **Nginx** - reverse proxy и SSL termination (порт 443)

## Локальная разработка

### Предварительные требования

- Docker Desktop (Windows/Mac) или Docker Engine + Docker Compose (Linux)
- Go 1.21+ (опционально, для разработки backend)
- Node.js 20+ (опционально, для разработки frontend)

### Запуск через Docker Compose

1. **Подготовка SSL сертификатов**

Для локальной разработки создайте самоподписанные сертификаты:

```bash
# Linux/Mac или Git Bash на Windows
cd nginx/ssl
openssl req -x509 -nodes -days 365 -newkey rsa:2048 \
  -keyout key.pem -out cert.pem \
  -subj "/C=RU/ST=State/L=City/O=Bar/CN=localhost"
cd ../..
```

Или используйте mkcert (рекомендуется):
```bash
# Установка mkcert
# Windows (Chocolatey): choco install mkcert
# Mac (Homebrew): brew install mkcert
# Linux: см. https://github.com/FiloSottile/mkcert

cd nginx/ssl
mkcert -install
mkcert localhost 127.0.0.1 ::1
mv localhost+2.pem cert.pem
mv localhost+2-key.pem key.pem
cd ../..
```

2. **Настройка переменных окружения**

Создайте файл `.env` в корне проекта:

```env
JWT_SECRET=your-development-secret-key
POSTGRES_USER=baruser
POSTGRES_PASSWORD=barpass
POSTGRES_DB=bardb
```

3. **Запуск всех сервисов**

```bash
docker-compose up -d
```

4. **Проверка статуса**

```bash
docker-compose ps
```

Все сервисы должны быть в статусе "Up".

5. **Доступ к приложению**

- Frontend: https://localhost (или http://localhost:80)
- Backend API: http://localhost:8080
- PostgreSQL: localhost:5432

### Разработка без Docker

**Backend:**

```bash
cd backend
go mod download
export DATABASE_URL="postgres://baruser:barpass@localhost:5432/bardb?sslmode=disable"
export JWT_SECRET="dev-secret"
go run main.go
```

**Frontend:**

```bash
cd frontend
npm install
npm run dev
```

Frontend будет доступен на http://localhost:3000 с автоматическим proxy на backend.

## Развертывание в баре (Production)

### Требования к оборудованию

**Минимальные требования:**
- Мини-ПК или Raspberry Pi 4 (4GB RAM)
- 32GB+ свободного места на диске
- Роутер Keenetic с поддержкой KeenDNS
- Стабильное интернет-соединение (4G/LTE или проводное)

**Рекомендуемые характеристики:**
- Intel NUC или аналог (8GB RAM)
- 128GB SSD
- Keenetic Skipper 4G или выше

### Настройка сервера

1. **Установка операционной системы**

Рекомендуется Ubuntu Server 22.04 LTS или Debian 12.

2. **Установка Docker**

```bash
# Обновление системы
sudo apt update && sudo apt upgrade -y

# Установка Docker
curl -fsSL https://get.docker.com -o get-docker.sh
sudo sh get-docker.sh

# Добавление пользователя в группу docker
sudo usermod -aG docker $USER

# Установка Docker Compose
sudo apt install docker-compose-plugin -y

# Перезагрузка для применения изменений
sudo reboot
```

3. **Клонирование проекта**

```bash
git clone <repository-url> bar-website
cd bar-website
```

4. **Настройка переменных окружения**

```bash
cp .env.example .env
nano .env
```

Установите надежный JWT_SECRET:
```env
JWT_SECRET=$(openssl rand -base64 32)
```

### Настройка KeenDNS и SSL

1. **Регистрация домена в KeenDNS**

- Войдите в веб-интерфейс роутера Keenetic
- Перейдите в раздел "Интернет" → "KeenDNS"
- Зарегистрируйте домен (например, `mybar.keenetic.pro`)
- Включите автоматическое обновление IP

2. **Получение SSL сертификата**

KeenDNS автоматически предоставляет SSL сертификаты. Для ручной настройки:

```bash
# Установка certbot
sudo apt install certbot -y

# Получение сертификата
sudo certbot certonly --standalone -d mybar.keenetic.pro

# Копирование сертификатов
sudo cp /etc/letsencrypt/live/mybar.keenetic.pro/fullchain.pem nginx/ssl/cert.pem
sudo cp /etc/letsencrypt/live/mybar.keenetic.pro/privkey.pem nginx/ssl/key.pem
sudo chmod 644 nginx/ssl/*.pem
```

3. **Настройка проброса портов на роутере**

В веб-интерфейсе Keenetic:
- Перейдите в "Домашняя сеть" → "Серверы"
- Добавьте правила:
  - HTTP: внешний порт 80 → IP сервера:80
  - HTTPS: внешний порт 443 → IP сервера:443

### Запуск в production

1. **Сборка и запуск контейнеров**

```bash
docker-compose up -d --build
```

2. **Проверка логов**

```bash
docker-compose logs -f
```

3. **Проверка работоспособности**

```bash
curl http://localhost/health
curl http://localhost:8080/health
```

### Настройка автозапуска

Создайте systemd service для автоматического запуска при перезагрузке:

```bash
sudo nano /etc/systemd/system/bar-website.service
```

Содержимое файла:

```ini
[Unit]
Description=Bar Website Docker Compose
Requires=docker.service
After=docker.service

[Service]
Type=oneshot
RemainAfterExit=yes
WorkingDirectory=/home/user/bar-website
ExecStart=/usr/bin/docker-compose up -d
ExecStop=/usr/bin/docker-compose down
TimeoutStartSec=0

[Install]
WantedBy=multi-user.target
```

Активация:

```bash
sudo systemctl enable bar-website.service
sudo systemctl start bar-website.service
```

## Локальная сеть (офлайн-режим)

Для работы внутри бара без интернета:

1. **Настройка статического IP на сервере**

```bash
# Пример для Ubuntu с netplan
sudo nano /etc/netplan/01-netcfg.yaml
```

```yaml
network:
  version: 2
  ethernets:
    eth0:
      dhcp4: no
      addresses:
        - 192.168.1.100/24
      gateway4: 192.168.1.1
      nameservers:
        addresses: [8.8.8.8, 1.1.1.1]
```

```bash
sudo netplan apply
```

2. **Настройка DNS на роутере**

В настройках DHCP роутера добавьте локальный DNS:
- `bar.local` → `192.168.1.100`

3. **Обновление frontend конфигурации**

Frontend автоматически определит локальный сервер при подключении к WiFi бара.

## Обслуживание

### Резервное копирование базы данных

```bash
# Создание backup
docker-compose exec postgres pg_dump -U baruser bardb > backup_$(date +%Y%m%d).sql

# Восстановление из backup
docker-compose exec -T postgres psql -U baruser bardb < backup_20241106.sql
```

### Обновление приложения

```bash
# Остановка сервисов
docker-compose down

# Получение обновлений
git pull

# Пересборка и запуск
docker-compose up -d --build

# Проверка логов
docker-compose logs -f
```

### Мониторинг

```bash
# Просмотр логов
docker-compose logs -f [service_name]

# Статус контейнеров
docker-compose ps

# Использование ресурсов
docker stats
```

### Очистка

```bash
# Удаление неиспользуемых образов
docker image prune -a

# Удаление неиспользуемых volumes
docker volume prune

# Полная очистка (осторожно!)
docker system prune -a --volumes
```

## Устранение неполадок

### Контейнер не запускается

```bash
# Проверка логов
docker-compose logs [service_name]

# Пересоздание контейнера
docker-compose up -d --force-recreate [service_name]
```

### База данных недоступна

```bash
# Проверка статуса PostgreSQL
docker-compose exec postgres pg_isready -U baruser

# Перезапуск базы данных
docker-compose restart postgres
```

### SSL сертификаты истекли

```bash
# Обновление сертификатов
sudo certbot renew

# Копирование новых сертификатов
sudo cp /etc/letsencrypt/live/mybar.keenetic.pro/fullchain.pem nginx/ssl/cert.pem
sudo cp /etc/letsencrypt/live/mybar.keenetic.pro/privkey.pem nginx/ssl/key.pem

# Перезапуск nginx
docker-compose restart nginx
```

### Проблемы с производительностью

```bash
# Проверка использования ресурсов
docker stats

# Увеличение лимитов памяти в docker-compose.yml
# Добавьте в нужный сервис:
# deploy:
#   resources:
#     limits:
#       memory: 2G
```

## Безопасность

### Рекомендации

1. **Измените JWT_SECRET** на случайную строку в production
2. **Используйте сильные пароли** для PostgreSQL
3. **Регулярно обновляйте** Docker образы и систему
4. **Настройте firewall** (ufw на Ubuntu):

```bash
sudo ufw allow 22/tcp   # SSH
sudo ufw allow 80/tcp   # HTTP
sudo ufw allow 443/tcp  # HTTPS
sudo ufw enable
```

5. **Ограничьте доступ к PostgreSQL** только из Docker сети
6. **Настройте автоматические обновления безопасности**:

```bash
sudo apt install unattended-upgrades
sudo dpkg-reconfigure -plow unattended-upgrades
```

## Контакты и поддержка

При возникновении проблем обратитесь к документации или создайте issue в репозитории проекта.
