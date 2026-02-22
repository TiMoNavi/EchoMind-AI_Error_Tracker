# EchoMind 服务器部署指南（傻瓜式）

> 本文档面向零运维经验用户，按顺序逐步执行即可完成部署。

## 目录

1. [服务器选购与配置建议](#1-服务器选购与配置建议)
2. [服务器初始化](#2-服务器初始化)
3. [克隆代码与配置环境变量](#3-克隆代码与配置环境变量)
4. [一键启动服务](#4-一键启动服务)
5. [数据库迁移与种子数据](#5-数据库迁移与种子数据)
6. [Nginx 反向代理 + HTTPS](#6-nginx-反向代理--https)
7. [Flutter APK 构建](#7-flutter-apk-构建)
8. [CCCC 多智能体配置](#8-cccc-多智能体配置)
9. [日常维护命令](#9-日常维护命令)

---

## 1. 服务器选购与配置建议

### 最低配置（开发/测试）

| 项目 | 规格 |
|------|------|
| CPU | 2 核 |
| 内存 | 4 GB |
| 系统盘 | 40 GB SSD |
| 系统 | Ubuntu 22.04 LTS |
| 带宽 | 3 Mbps |

### 推荐配置（生产环境）

| 项目 | 规格 |
|------|------|
| CPU | 4 核 |
| 内存 | 8 GB |
| 系统盘 | 80 GB SSD |
| 系统 | Ubuntu 22.04 LTS |
| 带宽 | 5 Mbps |

### 云服务商选择

阿里云 ECS、腾讯云 CVM、华为云 ECS 均可，选最便宜的即可。

**不需要额外购买的服务：**
- ❌ 不需要买云数据库（PostgreSQL 跑在 Docker 里）
- ❌ 不需要买对象存储（暂时本地存储，后续可迁移）
- ❌ 不需要买 Redis（当前架构不需要）

**需要额外准备的：**
- ✅ 一个域名（可选，用 IP 也能跑）
- ✅ 开放端口：22(SSH)、80(HTTP)、443(HTTPS)、8000(API)

---

## 2. 服务器初始化

> 以下所有命令均以 root 用户执行。SSH 登录服务器后逐行粘贴即可。

### 2.1 更新系统

```bash
apt update && apt upgrade -y
```

### 2.2 安装 Docker

```bash
curl -fsSL https://get.docker.com | sh
systemctl enable docker && systemctl start docker
```

验证：

```bash
docker --version
# 应输出 Docker version 2x.x.x
```

### 2.3 安装 Docker Compose

```bash
apt install -y docker-compose-plugin
```

验证：

```bash
docker compose version
# 应输出 Docker Compose version v2.x.x
```

### 2.4 安装 Git

```bash
apt install -y git
```

### 2.5 配置防火墙

```bash
ufw allow 22
ufw allow 80
ufw allow 443
ufw allow 8000
ufw --force enable
```

---

## 3. 克隆代码与配置环境变量

### 3.1 克隆仓库

```bash
cd /opt
git clone <你的仓库地址> echomind
cd echomind
```

### 3.2 创建后端环境变量

```bash
cp backend/.env.example backend/.env
```

编辑 `backend/.env`，**必须修改 SECRET_KEY**：

```bash
nano backend/.env
```

内容改为：

```env
DATABASE_URL=postgresql+asyncpg://postgres:postgres@db:5432/echomind
SECRET_KEY=这里换成一个随机长字符串
ACCESS_TOKEN_EXPIRE_MINUTES=1440
```

> 生成随机密钥的方法：`openssl rand -hex 32`

### 3.3 修改数据库密码（推荐）

编辑 `docker-compose.yml`，将 `POSTGRES_PASSWORD` 改为强密码，同时更新 `backend/.env` 中 DATABASE_URL 里的密码保持一致。

---

## 4. 一键启动服务

```bash
cd /opt/echomind
docker compose up -d --build
```

等待 1-2 分钟，验证服务状态：

```bash
docker compose ps
```

应看到两个容器状态为 `running`：

```
NAME              STATUS
echomind-db-1     Up
echomind-api-1    Up
```

验证 API 是否正常：

```bash
curl http://localhost:8000/docs
# 应返回 Swagger UI 的 HTML
```

如果启动失败，查看日志：

```bash
docker compose logs api
docker compose logs db
```

---

## 5. 数据库迁移与种子数据

### 5.1 运行 Alembic 迁移

```bash
docker compose exec api alembic upgrade head
```

> 这会自动创建所有数据库表。如果报错 `alembic: command not found`，说明依赖没装好，重新 build：`docker compose up -d --build api`

### 5.2 导入种子数据

```bash
docker compose exec api python seed.py
```

验证数据是否导入成功：

```bash
docker compose exec db psql -U postgres -d echomind -c "SELECT count(*) FROM knowledge_points;"
# 应返回 10
```

### 5.3 运行冒烟测试（可选）

```bash
docker compose exec api python -m pytest tests/ -v
```

---

## 6. Nginx 反向代理 + HTTPS

### 6.1 安装 Nginx

```bash
apt install -y nginx
systemctl enable nginx
```

### 6.2 配置反向代理

```bash
nano /etc/nginx/sites-available/echomind
```

粘贴以下内容（将 `your-domain.com` 替换为你的域名或服务器 IP）：

```nginx
server {
    listen 80;
    server_name your-domain.com;

    client_max_body_size 20M;

    location /api/ {
        proxy_pass http://127.0.0.1:8000/;
        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto $scheme;
    }

    location /docs {
        proxy_pass http://127.0.0.1:8000/docs;
    }

    location /openapi.json {
        proxy_pass http://127.0.0.1:8000/openapi.json;
    }
}
```

启用配置：

```bash
ln -sf /etc/nginx/sites-available/echomind /etc/nginx/sites-enabled/
rm -f /etc/nginx/sites-enabled/default
nginx -t && systemctl reload nginx
```

### 6.3 配置 HTTPS（有域名时）

```bash
apt install -y certbot python3-certbot-nginx
certbot --nginx -d your-domain.com
```

按提示输入邮箱，同意条款即可。证书会自动续期。

### 6.4 无域名时直接用 IP 访问

如果没有域名，把 Nginx 配置中 `server_name` 改为 `_`，Flutter 中 API 地址配为 `http://你的服务器IP/api`。

---

## 7. Flutter APK 构建

### 7.1 在服务器上安装 Flutter（可选）

如果你想在服务器上构建 APK：

```bash
# 安装依赖
apt install -y unzip xz-utils zip libglu1-mesa openjdk-17-jdk

# 安装 Flutter
git clone https://github.com/flutter/flutter.git -b stable /opt/flutter
export PATH="/opt/flutter/bin:$PATH"
echo 'export PATH="/opt/flutter/bin:$PATH"' >> ~/.bashrc

# 验证
flutter doctor
```

### 7.2 构建 APK

```bash
cd /opt/echomind/echomind_app
```

**构建前修改 API 地址**，编辑 `lib/shared/network/api_client.dart`，将 baseUrl 改为你的服务器地址：

```dart
// 改为你的实际地址
static const String baseUrl = 'http://your-domain.com/api';
```

构建：

```bash
flutter build apk --release
```

APK 输出路径：`build/app/outputs/flutter-apk/app-release.apk`

### 7.3 本地构建（推荐）

也可以在本地电脑构建 APK，只需修改 API 地址指向服务器即可。

---

## 8. CCCC 多智能体配置

### 8.1 安装 Node.js

```bash
curl -fsSL https://deb.nodesource.com/setup_20.x | bash -
apt install -y nodejs
```

### 8.2 安装 CCCC

```bash
npm install -g cccc
```

### 8.3 初始化工作组

```bash
cd /opt/echomind
cccc init
```

按提示配置：
- 工作目录：`/opt/echomind`
- Foreman runtime：`claude`
- 添加 peers：`claude-2`、`claude-3`、`claude-4`

### 8.4 启动 CCCC

```bash
cccc start
```

> 建议使用 `tmux` 或 `screen` 保持后台运行：
> ```bash
> apt install -y tmux
> tmux new -s cccc
> cccc start
> # 按 Ctrl+B 然后按 D 脱离会话
> # 重新连接：tmux attach -t cccc
> ```

---

## 9. 日常维护命令

### 更新代码并重启

```bash
cd /opt/echomind
git pull
docker compose up -d --build api
docker compose exec api alembic upgrade head
```

### 查看日志

```bash
# API 日志（实时）
docker compose logs -f api

# 数据库日志
docker compose logs -f db
```

### 重启服务

```bash
docker compose restart api
docker compose restart db
```

### 备份数据库

```bash
docker compose exec db pg_dump -U postgres echomind > backup_$(date +%Y%m%d).sql
```

### 恢复数据库

```bash
cat backup_20260222.sql | docker compose exec -T db psql -U postgres -d echomind
```

### 查看磁盘使用

```bash
df -h
docker system df
```

### 清理 Docker 缓存

```bash
docker system prune -f
```

---

## 快速检查清单

部署完成后，逐项验证：

- [ ] `docker compose ps` 两个容器都是 Up
- [ ] `curl http://localhost:8000/docs` 返回 HTML
- [ ] `curl http://你的IP/api/docs` 通过 Nginx 访问正常
- [ ] 数据库有种子数据（knowledge_points 表有 10 条）
- [ ] Flutter APK 能连接到服务器 API
- [ ] 注册/登录功能正常
- [ ] CCCC 工作组启动正常