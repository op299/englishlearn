# 📚 LexiRise API - Tài Liệu Chi Tiết

Một ứng dụng backend FastAPI để học tiếng Anh với hệ thống flashcard, tiến trình học tập, và quản lý cấp độ người dùng.

## 📋 Mục lục

1. [Tổng Quan](#tổng-quan)
2. [Kiến Trúc Ứng Dụng](#kiến-trúc-ứng-dụng)
3. [Cấu Trúc Cơ Sở Dữ Liệu](#cấu-trúc-cơ-sở-dữ-liệu)
4. [API Endpoints](#api-endpoints)
5. [Hướng Dẫn Sử Dụng](#hướng-dẫn-sử-dụng)
6. [Cấu Hình Môi Trường](#cấu-hình-môi-trường)

---

## 🎯 Tổng Quan

**LexiRise API** là backend được xây dựng để hỗ trợ ứng dụng học tiếng Anh với các tính năng:

- ✅ **Xác thực & Bảo mật**: Đăng ký, đăng nhập, JWT token, reset mật khẩu
- ✅ **Quản lý Học tập**: 6 cấp độ CEFR (A1-C2), các chủ đề, bài học, flashcard
- ✅ **Theo Dõi Tiến Trình**: Điểm XP, streak, tỷ lệ độ chính xác, thời gian học
- ✅ **Hồ Sơ Người Dùng**: Cấu hình, thống kê, bảng xếp hạng
- ✅ **Email Service**: Gửi email xác nhận, reset mật khẩu

---

## 🏗️ Kiến Trúc Ứng Dụng

```
my-python-backend/
├── app/
│   ├── __init__.py
│   ├── main.py                 # Điểm khởi đầu, CORS, middleware
│   ├── core/
│   │   ├── config.py          # Cấu hình từ .env
│   │   ├── database.py        # Kết nối database async
│   │   ├── security.py        # JWT, password hashing
│   │   └── dependencies.py    # Dependency injection
│   ├── models/                 # SQLAlchemy ORM models
│   │   ├── user.py            # Thông tin người dùng
│   │   ├── user_meta.py       # Cấu hình & thống kê người dùng
│   │   └── content.py         # Topic, Lesson, Question, UserProgress
│   ├── schemas/                # Pydantic models (validation, serialization)
│   │   ├── auth_schema.py
│   │   ├── content_schema.py
│   │   ├── user_schema.py
│   │   └── progress_schema.py
│   ├── routers/                # API routes
│   │   ├── auth_router.py
│   │   ├── content_router.py
│   │   ├── user_router.py
│   │   └── progress_router.py
│   ├── services/               # Business logic
│   │   ├── auth_service.py
│   │   ├── content_service.py
│   │   ├── user_service.py
│   │   ├── progress_service.py
│   │   └── email_service.py
├── tests/
├── .env                        # Cấu hình môi trường
├── requirements.txt
└── README.md
```

### 🔄 Flow Dữ Liệu

```
Request → Router → Service → Database
                       ↓
          Response ← Schema validation
```

---

## 📊 Cấu Trúc Cơ Sở Dữ Liệu

### Users (Người Dùng)
```
users
├── id (UUID)
├── email (unique)
├── password_hash
├── full_name
├── avatar_url
├── daily_goal_minutes (mục tiêu hàng ngày)
├── current_level (A1-C2)
├── created_at
├── updated_at
```

### Topics (Chủ Đề)
```
topics
├── id (UUID)
├── title (tên chủ đề)
├── level (A1-C2)
├── category (Vocabulary / Grammar)
├── created_at
└── lessons (relationship: 1 topic → N lessons)
```

### Lessons (Bài Học)
```
lessons
├── id (UUID)
├── topic_id (FK)
├── order (thứ tự bài)
├── xp_reward (100 XP)
├── created_at
├── questions (relationship: 1 lesson → N questions)
└── progress_records (relationship: 1 lesson → N user progress)
```

### Questions (Flashcard/Câu Hỏi)
```
questions
├── id (UUID)
├── lesson_id (FK)
├── word (từ vựng)
├── context_sentence (câu ví dụ)
├── correct_answer (đáp án)
├── distractors (JSON: 3 đáp án sai)
├── image_url
└── created_at
```

### UserProgress (Tiến Trình Học)
```
user_progress
├── user_id (FK) + lesson_id (FK) [Composite Primary Key]
├── is_completed (hoàn thành?)
├── accuracy (0-100%)
├── time_spent_seconds
├── last_studied_at
└── needs_review (cần ôn tập?)
```

### UserSettings & UserStats
```
user_settings                 user_stats
├── user_id (FK)              ├── user_id (FK)
├── theme (light/dark)        ├── total_xp
├── high_contrast_borders     ├── streak_count
├── notifications_enabled     ├── last_active_date
└── updated_at                ├── words_mastered_count
                              └── updated_at
```

---

## 🔌 API Endpoints

### 🔐 Authentication (`/api/v1/auth`)

#### 1. Đăng Ký
```
POST /api/v1/auth/register
Content-Type: application/json

{
  "email": "user@example.com",
  "password": "SecurePassword123!",
  "full_name": "Tên Người Dùng"
}

Response (201):
{
  "id": "uuid",
  "email": "user@example.com",
  "full_name": "Tên Người Dùng",
  "created_at": "2024-05-13T10:30:00"
}
```

#### 2. Đăng Nhập
```
POST /api/v1/auth/login
{
  "email": "user@example.com",
  "password": "SecurePassword123!"
}

Response (200):
{
  "access_token": "eyJ0eXAiOiJKV1QiLCJhbGc...",
  "refresh_token": "eyJ0eXAiOiJKV1QiLCJhbGc...",
  "token_type": "bearer",
  "expires_in": 86400
}
```

#### 3. Refresh Token
```
POST /api/v1/auth/refresh
{
  "refresh_token": "token_here"
}

Response:
{
  "access_token": "new_token",
  "token_type": "bearer"
}
```

#### 4. Forgot Password
```
POST /api/v1/auth/forgot-password
{
  "email": "user@example.com"
}

Response:
{
  "message": "Email xác nhận đã được gửi"
}
```

#### 5. Reset Password
```
POST /api/v1/auth/reset-password
{
  "token": "reset_token_from_email",
  "new_password": "NewPassword123!"
}

Response:
{
  "message": "Mật khẩu đã được đặt lại"
}
```

#### 6. Verify Email
```
GET /api/v1/auth/verify-email?token=verification_token

Response:
{
  "message": "Email đã được xác thực"
}
```

---

### 📚 Learning (`/api/v1/learning`)

#### 1. Lấy Danh Sách Chủ Đề
```
GET /api/v1/learning/topics?level=A1&category=Vocabulary

Query Parameters:
- level: A1, A2, B1, B2, C1, C2 (optional)
- category: Vocabulary, Grammar (optional)

Response:
{
  "topics": [
    {
      "id": "uuid",
      "title": "Business Negotiation",
      "level": "B1",
      "category": "Vocabulary",
      "created_at": "2024-05-13T10:30:00"
    }
  ],
  "total": 10
}
```

#### 2. Lấy Bài Học của Chủ Đề
```
GET /api/v1/learning/topics/{topic_id}/lessons

Response:
{
  "lessons": [
    {
      "id": "uuid",
      "topic_id": "uuid",
      "order": 1,
      "xp_reward": 100,
      "completed": false
    }
  ],
  "total": 15
}
```

#### 3. Chi Tiết Bài Học
```
GET /api/v1/learning/lessons/{lesson_id}

Response:
{
  "id": "uuid",
  "topic_id": "uuid",
  "xp_reward": 100,
  "questions": [
    {
      "id": "uuid",
      "word": "negotiate",
      "context_sentence": "We need to negotiate the contract terms",
      "correct_answer": "thương lượng",
      "distractors": ["thảo luận", "đề xuất", "yêu cầu"],
      "image_url": "https://..."
    }
  ]
}
```

---

### 👤 User (`/api/v1/user`)

#### 1. Lấy Dashboard
```
GET /api/v1/user/dashboard
Authorization: Bearer {access_token}

Response:
{
  "user": {
    "id": "uuid",
    "email": "user@example.com",
    "full_name": "Tên",
    "current_level": "B1"
  },
  "stats": {
    "total_xp": 5000,
    "streak_count": 15,
    "words_mastered": 250,
    "ranking": "Top 5%"
  },
  "recent_lessons": [...]
}
```

#### 2. Lấy Hồ Sơ
```
GET /api/v1/user/profile
Authorization: Bearer {access_token}

Response:
{
  "id": "uuid",
  "email": "user@example.com",
  "full_name": "Tên Người Dùng",
  "avatar_url": "https://...",
  "current_level": "B1",
  "daily_goal_minutes": 30,
  "settings": {
    "theme": "dark",
    "notifications": true
  }
}
```

#### 3. Cập Nhật Cài Đặt
```
PATCH /api/v1/user/settings
Authorization: Bearer {access_token}
{
  "theme": "dark",
  "high_contrast_borders": false,
  "notifications_enabled": true
}

Response: 200 OK
```

#### 4. Đổi Mật Khẩu
```
PUT /api/v1/user/security
Authorization: Bearer {access_token}
{
  "current_password": "OldPassword123!",
  "new_password": "NewPassword123!"
}

Response: 200 OK
```

---

### 📊 Progress (`/api/v1/lessons`)

#### 1. Nộp Bài Học
```
POST /api/v1/lessons/{lesson_id}/submit
Authorization: Bearer {access_token}

{
  "answers": [
    {"question_id": "uuid", "user_answer": "thương lượng"},
    {"question_id": "uuid", "user_answer": "đàm phán"}
  ],
  "time_spent_seconds": 300
}

Response:
{
  "lesson_id": "uuid",
  "accuracy": 85.5,
  "xp_earned": 100,
  "new_total_xp": 5100,
  "is_completed": true,
  "next_lesson": "uuid or null"
}
```

---

## 🚀 Hướng Dẫn Sử Dụng

### 1. Khởi Động Server
```bash
# Kích hoạt virtual environment (nếu chưa)
venv\Scripts\activate

# Chạy development server
python -m uvicorn app.main:app --reload
```

Server chạy tại: `http://localhost:8000`

### 2. Truy Cập API Docs
- **Swagger UI**: `http://localhost:8000/docs`
- **ReDoc**: `http://localhost:8000/redoc`

### 3. Kiểm Tra Health
```bash
curl http://localhost:8000/health
# Response: {"status": "ok", "app": "LexiRise API"}
```

### 4. Ví Dụ Quy Trình Học
```bash
# 1. Đăng ký
curl -X POST http://localhost:8000/api/v1/auth/register \
  -H "Content-Type: application/json" \
  -d '{
    "email": "student@example.com",
    "password": "MyPassword123!",
    "full_name": "John Doe"
  }'

# 2. Đăng nhập
curl -X POST http://localhost:8000/api/v1/auth/login \
  -H "Content-Type: application/json" \
  -d '{
    "email": "student@example.com",
    "password": "MyPassword123!"
  }'
# Lưu access_token từ response

# 3. Lấy danh sách chủ đề
curl http://localhost:8000/api/v1/learning/topics \
  -H "Authorization: Bearer {access_token}"

# 4. Lấy chi tiết bài học
curl http://localhost:8000/api/v1/learning/lessons/{lesson_id} \
  -H "Authorization: Bearer {access_token}"

# 5. Nộp bài học
curl -X POST http://localhost:8000/api/v1/lessons/{lesson_id}/submit \
  -H "Authorization: Bearer {access_token}" \
  -H "Content-Type: application/json" \
  -d '{
    "answers": [...],
    "time_spent_seconds": 300
  }'
```

---

## ⚙️ Cấu Hình Môi Trường

### Tệp `.env`
```env
# App
APP_NAME=LexiRise API
DEBUG=false

# Database
DB_HOST=localhost
DB_PORT=3306
DB_USER=root
DB_PASSWORD=1234
DB_NAME=lexirise

# JWT
JWT_SECRET_KEY=your-secret-key-here
JWT_ALGORITHM=HS256
ACCESS_TOKEN_EXPIRE_MINUTES=1440
REFRESH_TOKEN_EXPIRE_DAYS=30

# Email SMTP
SMTP_HOST=smtp.gmail.com
SMTP_PORT=587
SMTP_USER=your-email@gmail.com
SMTP_PASSWORD=your-app-password
EMAIL_FROM=your-email@gmail.com

# Frontend URL
RESET_PASSWORD_URL=http://localhost:3000/reset-password
```

---

## 🛠️ Công Nghệ Sử Dụng

| Layer | Công Nghệ |
|-------|-----------|
| **Framework** | FastAPI 0.115.0 |
| **Server** | Uvicorn 0.30.6 |
| **Database** | MySQL/MariaDB + SQLAlchemy 2.0.35 |
| **Async DB** | aiomysql 0.2.0 |
| **Validation** | Pydantic 2.9.2 |
| **Auth** | JWT (python-jose) + bcrypt |
| **Email** | aiosmtplib 3.0.1 |

---

## 📝 Quy Tắc Mã Hóa

### Response Format
Tất cả API responses tuân theo định dạng:
```json
{
  "data": {...},
  "status": "success|error",
  "message": "Chi tiết (nếu có)"
}
```

### Error Handling
```json
{
  "status": "error",
  "detail": "Mô tả lỗi",
  "code": "ERROR_CODE"
}
```

### HTTP Status Codes
- `200`: OK
- `201`: Created
- `400`: Bad Request
- `401`: Unauthorized
- `403`: Forbidden
- `404`: Not Found
- `500`: Server Error

---

## 🔒 Bảo Mật

✅ **JWT Token**: Access token hết hạn sau 24 giờ, refresh token sau 30 ngày
✅ **Password Hashing**: Bcrypt với 12 rounds
✅ **CORS**: Mở cho tất cả origins (có thể hạn chế)
✅ **Email Verification**: Xác nhận email khi đăng ký
✅ **Reset Password**: Token hết hạn sau 24 giờ

---

## 📊 Thống Kê & Tính Năng

### Cấp Độ CEFR
- **A1**: Người mới bắt đầu
- **A2**: Sơ cấp
- **B1**: Trung cấp
- **B2**: Trung cấp cao
- **C1**: Nâng cao
- **C2**: Thành thạo

### Hệ Thống Điểm
- Mỗi bài học: **100 XP**
- Streak hàng ngày: Bonus XP
- Bảng xếp hạng dựa trên tổng XP

### Theo Dõi Tiến Trình
- **Accuracy**: Tỷ lệ đáp án đúng
- **Time Spent**: Thời gian học tập
- **Streak**: Số ngày học liên tiếp
- **Words Mastered**: Từ vựng đã thành thạo

---

## 📞 Liên Hệ & Hỗ Trợ

Nếu có vấn đề, vui lòng:
1. Kiểm tra logs trong terminal
2. Xem file `.env` có cấu hình đúng không
3. Đảm bảo MySQL đang chạy
4. Kiểm tra database connection

---

**Phiên Bản**: 1.0.0  
**Cập Nhật**: Tháng 5, 2026  
**Tác Giả**: LexiRise Team
