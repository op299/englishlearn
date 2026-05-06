# 📚 LexiRise API - Tài Liệu Chi Tiết

**Phiên Bản** (Version): 1.0.0  
**Framework**: FastAPI  
**Ngôn Ngữ** (Language): Python  
**Cơ Sở Dữ Liệu** (Database): MySQL  
**Xác Thực** (Authentication): JWT (JSON Web Token)  

---

## 📋 Mục Lục (Table of Contents)

1. [Tổng Quan](#tổng-quan)
2. [Cấu Hình Cơ Bản](#cấu-hình-cơ-bản)
3. [Xác Thực](#xác-thực)
4. [Endpoints Người Dùng](#endpoints-người-dùng)
5. [Cấu Trúc Dữ Liệu](#cấu-trúc-dữ-liệu)
6. [Mã Lỗi](#mã-lỗi)

---

## 🎯 Tổng Quan

**LexiRise API** là một nền tảng backend để học tiếng Anh quản lý:

- ✅ **Xác thực người dùng** (Đăng ký, Đăng nhập, Làm mới Token)
- ✅ **Quản lý hồ sơ cá nhân** (Dashboard, Hồ Sơ, Cài Đặt)
- ✅ **Hệ thống bảo mật** (Đổi Mật Khẩu, Đặt Lại Mật Khẩu)
- ✅ **Theo dõi tiến độ** (XP, Chuỗi Ngày, Thành Thạo Từ Vựng)

---

## 🔧 Cấu Hình Cơ Bản

### URL Gốc (Base URL)
```
http://localhost:8000/api/v1
```

### Headers Bắt Buộc
```json
{
  "Content-Type": "application/json",
  "Authorization": "Bearer {access_token}"
}
```

### Kiểm Tra Sức Khỏe (Health Check) - Không Cần Xác Thực
```
GET /health
```

**Phản Hồi (Response) - 200 OK**
```json
{
  "status": "ok",
  "app": "LexiRise API"
}
```

---

## 🔐 Xác Thực (Authentication)

### 1️⃣ Đăng Ký Người Dùng Mới (Register)

**Endpoint:**
```
POST /auth/register
```

**Mô Tả**: Tạo tài khoản mới với email, mật khẩu và thông tin cá nhân.

**Request Body (Yêu Cầu)**
```json
{
  "email": "user@example.com",
  "password": "StrongPassword123",
  "full_name": "Nguyễn Văn A",
  "daily_goal_minutes": 10,
  "current_level": "A1"
}
```

**Xác Thực Dữ Liệu (Validations)**
| Trường (Field) | Kiểu (Type) | Yêu Cầu (Requirements) |
|-------|------|-----------|
| `email` | string | Email hợp lệ, duy nhất trong hệ thống |
| `password` | string | 8-128 ký tự, tối thiểu 1 chữ hoa, 1 chữ thường, 1 chữ số |
| `full_name` | string | 1-256 ký tự |
| `daily_goal_minutes` | integer | Giá trị chấp nhận: 5, 10, 15 (mặc định: 10) |
| `current_level` | string | Giá trị: A1, A2, B1, B2, C1, C2 (mặc định: A1) |

**Phản Hồi - 201 Created**
```json
{
  "user_id": "550e8400-e29b-41d4-a716-446655440000",
  "email": "user@example.com",
  "full_name": "Nguyễn Văn A",
  "access_token": "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...",
  "refresh_token": "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...",
  "token_type": "bearer"
}
```

**Lỗi Có Thể Xảy Ra**
```json
{
  "detail": "Email đã được đăng ký"
}
```

---

### 2️⃣ Đăng Nhập (Login)

**Endpoint:**
```
POST /auth/login
```

**Mô Tả**: Xác thực người dùng và nhận tokens truy cập.

**Request Body (Yêu Cầu)**
```json
{
  "email": "user@example.com",
  "password": "StrongPassword123"
}
```

**Phản Hồi - 200 OK**
```json
{
  "user_id": "550e8400-e29b-41d4-a716-446655440000",
  "email": "user@example.com",
  "full_name": "Nguyễn Văn A",
  "current_level": "A1",
  "access_token": "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...",
  "refresh_token": "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...",
  "token_type": "bearer"
}
```

**Lỗi Có Thể Xảy Ra**
```json
{
  "detail": "Email hoặc mật khẩu không chính xác"
}
```

---

### 3️⃣ Làm Mới Access Token (Refresh Token)

**Endpoint:**
```
POST /auth/refresh
```

**Mô Tả**: Tạo access token mới bằng refresh token (có hiệu lực trong 30 ngày).

**Request Body (Yêu Cầu)**
```json
{
  "refresh_token": "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9..."
}
```

**Phản Hồi - 200 OK**
```json
{
  "access_token": "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...",
  "token_type": "bearer"
}
```

**Thông Tin Hết Hạn (Expiration)**
- Access Token: Có hiệu lực trong 24 giờ
- Refresh Token: Có hiệu lực trong 30 ngày

---

### 4️⃣ Quên Mật Khẩu (Forgot Password)

**Endpoint:**
```
POST /auth/forgot-password
```

**Mô Tả**: Gửi email với liên kết để đặt lại mật khẩu.

**Request Body (Yêu Cầu)**
```json
{
  "email": "user@example.com"
}
```

**Phản Hồi - 200 OK**
```json
{
  "message": "Nếu email tồn tại trong hệ thống, bạn sẽ nhận được email với hướng dẫn đặt lại mật khẩu."
}
```

**Ghi Chú**: Phản hồi giống nhau bất kể email có tồn tại hay không (để bảo vệ bảo mật).

---

### 5️⃣ Đặt Lại Mật Khẩu (Reset Password)

**Endpoint:**
```
POST /auth/reset-password
```

**Mô Tả**: Đặt lại mật khẩu bằng token được gửi qua email.

**Request Body (Yêu Cầu)**
```json
{
  "token": "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...",
  "new_password": "NewPassword456"
}
```

**Xác Thực Dữ Liệu**
- Mật khẩu: 8-128 ký tự, tối thiểu 1 chữ hoa, 1 chữ thường, 1 chữ số

**Phản Hồi - 200 OK**
```json
{
  "message": "Mật khẩu đã được đặt lại thành công."
}
```

---

### 6️⃣ Lấy Thông Tin Người Dùng Hiện Tại (Get Current User)

**Endpoint:**
```
GET /auth/me
```

**Mô Tả**: Kiểm tra xem token có hợp lệ không và lấy thông tin cơ bản của người dùng.

**Headers Bắt Buộc**
```
Authorization: Bearer {access_token}
```

**Phản Hồi - 200 OK**
```json
{
  "user_id": "550e8400-e29b-41d4-a716-446655440000",
  "email": "user@example.com",
  "full_name": "Nguyễn Văn A",
  "current_level": "A1"
}
```

**Lỗi Có Thể Xảy Ra**
```json
{
  "detail": "Không có token được cung cấp"
}
```

```json
{
  "detail": "Token không hợp lệ hoặc đã hết hạn"
}
```

---

## 👤 Endpoints Người Dùng (User Endpoints)

> ⚠️ **Tất cả các endpoint người dùng yêu cầu xác thực (Bearer Token)**

### 1️⃣ Lấy Dashboard

**Endpoint:**
```
GET /user/dashboard
```

**Mô Tả**: Lấy thông tin tóm tắt tiến độ học tập của ngày hôm nay.

**Headers Bắt Buộc**
```
Authorization: Bearer {access_token}
```

**Phản Hồi - 200 OK**
```json
{
  "streak": 5,
  "today_xp": 150,
  "total_xp": 2450,
  "daily_goal_minutes": 10,
  "message": "Tuyệt vời! Bạn đang duy trì chuỗi ngày học tập của mình!"
}
```

**Giải Thích Các Trường (Fields Explanation)**
| Trường (Field) | Mô Tả (Description) |
|-------|-----------|
| `streak` | Số ngày liên tiếp học tập |
| `today_xp` | Điểm kinh nghiệm (XP) kiếm được hôm nay |
| `total_xp` | Tổng điểm kinh nghiệm tích lũy |
| `daily_goal_minutes` | Mục tiêu hàng ngày tính bằng phút |
| `message` | Thông điệp động viên (tùy chọn) |

---

### 2️⃣ Lấy Hồ Sơ Người Dùng (Get User Profile)

**Endpoint:**
```
GET /user/profile
```

**Mô Tả**: Lấy thông tin đầy đủ về hồ sơ người dùng.

**Headers Bắt Buộc**
```
Authorization: Bearer {access_token}
```

**Phản Hồi - 200 OK**
```json
{
  "email": "user@example.com",
  "full_name": "Nguyễn Văn A",
  "avatar_url": "https://api.example.com/avatars/user123.jpg",
  "current_level": "A1",
  "total_xp": 2450,
  "streak": 5,
  "words_mastered": 127,
  "total_words": 5000,
  "mastery_ratio": 0.0254
}
```

**Giải Thích Các Trường (Fields Explanation)**
| Trường (Field) | Mô Tả (Description) |
|-------|-----------|
| `email` | Email của người dùng |
| `full_name` | Họ và tên đầy đủ |
| `avatar_url` | URL ảnh đại diện (có thể là null) |
| `current_level` | Trình độ tiếng Anh hiện tại (A1-C2) |
| `total_xp` | Tổng điểm kinh nghiệm tích lũy |
| `streak` | Số ngày liên tiếp |
| `words_mastered` | Số từ vựng mà người dùng đã thành thạo |
| `total_words` | Tổng số từ vựng trong hệ thống |
| `mastery_ratio` | Tỷ lệ từ vựng đã thành thạo (0-1) |

---

### 3️⃣ Cập Nhật Cài Đặt Người Dùng (Update Settings)

**Endpoint:**
```
PATCH /user/settings
```

**Mô Tả**: Cập nhật các cài đặt tùy chọn của người dùng.

**Headers Bắt Buộc**
```
Authorization: Bearer {access_token}
```

**Request Body (Yêu Cầu)**
```json
{
  "daily_goal_minutes": 15,
  "theme": "dark"
}
```

**Xác Thực Dữ Liệu (Validations)**
| Trường (Field) | Kiểu (Type) | Yêu Cầu (Requirements) |
|-------|------|-----------|
| `daily_goal_minutes` | integer (tùy chọn) | Tối thiểu: 5, Tối đa: 60 |
| `theme` | string (tùy chọn) | Giá trị: "light", "dark" |

**Phản Hồi - 200 OK**
```json
{
  "message": "Cài đặt đã được cập nhật thành công",
  "daily_goal_minutes": 15,
  "theme": "dark"
}
```

---

### 4️⃣ Đổi Mật Khẩu (Change Password)

**Endpoint:**
```
PUT /user/security
```

**Mô Tả**: Thay đổi mật khẩu của người dùng (yêu cầu mật khẩu hiện tại).

**Headers Bắt Buộc**
```
Authorization: Bearer {access_token}
```

**Request Body (Yêu Cầu)**
```json
{
  "old_password": "OldPassword123",
  "new_password": "NewPassword456",
  "confirm_password": "NewPassword456"
}
```

**Xác Thực Dữ Liệu (Validations)**
| Trường (Field) | Yêu Cầu (Requirements) |
|-------|-----------|
| `old_password` | Phải chính xác (sẽ được xác minh) |
| `new_password` | 8-128 ký tự, tối thiểu 1 chữ hoa, 1 chữ thường, 1 chữ số |
| `confirm_password` | Phải giống hệt `new_password` |

**Phản Hồi - 200 OK**
```json
{
  "message": "Mật khẩu đã được thay đổi thành công"
}
```

**Lỗi Có Thể Xảy Ra**
```json
{
  "detail": "Mật khẩu cũ không chính xác"
}
```

```json
{
  "detail": "Mật khẩu không khớp nhau"
}
```

---

## 📊 Cấu Trúc Dữ Liệu (Data Models)

### Model: User (Người Dùng)

```json
{
  "id": "550e8400-e29b-41d4-a716-446655440000",
  "email": "user@example.com",
  "password_hash": "hashed_password",
  "full_name": "Nguyễn Văn A",
  "avatar_url": "https://api.example.com/avatars/user123.jpg",
  "daily_goal_minutes": 10,
  "current_level": "A1",
  "created_at": "2024-01-15T10:30:00Z",
  "updated_at": "2024-01-15T15:45:30Z"
}
```

### Model: UserSettings (Cài Đặt Người Dùng)

```json
{
  "user_id": "550e8400-e29b-41d4-a716-446655440000",
  "theme": "light",
  "high_contrast_borders": false,
  "notifications_enabled": true,
  "updated_at": "2024-01-15T15:45:30Z"
}
```

### Model: UserStats (Thống Kê Người Dùng)

```json
{
  "user_id": "550e8400-e29b-41d4-a716-446655440000",
  "total_xp": 2450,
  "streak_count": 5,
  "last_active_date": "2024-01-15",
  "words_mastered_count": 127,
  "updated_at": "2024-01-15T15:45:30Z"
}
```

### Enum: Trình Độ Tiếng Anh (English Levels)

```
A1 - Elementary (Beginner) - Sơ Cấp (Người Mới Bắt Đầu)
A2 - Elementary (Pre-Intermediate) - Sơ Cấp (Trung Gian Sơ)
B1 - Intermediate - Trung Bình
B2 - Upper Intermediate - Trung Bình Trên
C1 - Advanced - Nâng Cao
C2 - Proficiency - Thành Thạo Hoàn Toàn
```

---

## ❌ Mã Lỗi (Error Codes)

### Mã HTTP Chung (General HTTP Status Codes)

| Mã (Code) | Mô Tả (Description) |
|--------|-----------|
| 200 | OK - Yêu cầu thành công |
| 201 | Created - Tài nguyên được tạo thành công |
| 400 | Bad Request - Dữ liệu không hợp lệ |
| 401 | Unauthorized - Token không có hoặc không hợp lệ |
| 403 | Forbidden - Không có quyền truy cập |
| 404 | Not Found - Không tìm thấy tài nguyên |
| 409 | Conflict - Xung đột (ví dụ: email đã được đăng ký) |
| 422 | Unprocessable Entity - Xác thực không thành công |
| 500 | Internal Server Error - Lỗi máy chủ |

### Ví Dụ Lỗi Xác Thực (Validation Error Example)

```json
{
  "detail": [
    {
      "loc": ["body", "email"],
      "msg": "invalid email format",
      "type": "value_error.email"
    }
  ]
}
```

### Ví Dụ Lỗi Xác Thực (Authentication Error Example)

```json
{
  "detail": "Token không hợp lệ hoặc đã hết hạn"
}
```

---

## 🚀 Luồng Xác Thực Được Khuyến Nghị (Recommended Authentication Flow)

```
1. [Frontend] Đăng nhập với email và mật khẩu
   ↓
2. [Backend] Trả về access_token và refresh_token
   ↓
3. [Frontend] Lưu trữ tokens trong localStorage/sessionStorage
   ↓
4. [Frontend] Sử dụng access_token trong mỗi yêu cầu (Authorization header)
   ↓
5. Nếu access_token hết hạn (401):
   ├─ [Frontend] Sử dụng refresh_token để lấy access_token mới
   ├─ [Backend] Trả về access_token mới
   └─ [Frontend] Thử lại yêu cầu trước đó
   ↓
6. Nếu refresh_token hết hạn:
   └─ [Frontend] Chuyển hướng đến trang đăng nhập
```

---

## 📱 Ví Dụ Tích Hợp (Integration Examples)

### JavaScript/TypeScript

```javascript
// Đăng nhập (Login)
const response = await fetch('http://localhost:8000/api/v1/auth/login', {
  method: 'POST',
  headers: {
    'Content-Type': 'application/json',
  },
  body: JSON.stringify({
    email: 'user@example.com',
    password: 'StrongPassword123'
  })
});

const data = await response.json();
localStorage.setItem('access_token', data.access_token);
localStorage.setItem('refresh_token', data.refresh_token);

// Sử dụng token trong yêu cầu (Using token in request)
const dashboardResponse = await fetch(
  'http://localhost:8000/api/v1/user/dashboard',
  {
    headers: {
      'Authorization': `Bearer ${localStorage.getItem('access_token')}`
    }
  }
);
```

### Python

```python
import requests

# Đăng nhập (Login)
response = requests.post(
    'http://localhost:8000/api/v1/auth/login',
    json={
        'email': 'user@example.com',
        'password': 'StrongPassword123'
    }
)

tokens = response.json()
access_token = tokens['access_token']

# Lấy Dashboard (Get Dashboard)
dashboard = requests.get(
    'http://localhost:8000/api/v1/user/dashboard',
    headers={'Authorization': f'Bearer {access_token}'}
)
print(dashboard.json())
```

---

## 🔒 Bảo Mật (Security)

### Các Biện Pháp Bảo Mật Đã Triển Khai (Implemented Security Measures)

- ✅ Mật khẩu được mã hóa bằng bcrypt
- ✅ JWT cho xác thực không lưu trữ trạng thái (stateless)
- ✅ CORS được bật (Cần điều chỉnh cho môi trường sản xuất)
- ✅ Xác thực đầu vào bằng Pydantic
- ✅ Token reset mật khẩu có thời gian hết hạn
- ✅ Giới hạn tốc độ được khuyến nghị (cần triển khai cho sản xuất)

### Khuyến Nghị Cho Môi Trường Sản Xuất (Production Recommendations)

- ⚠️ Thay đổi `JWT_SECRET_KEY` trong `.env`
- ⚠️ Cấu hình `RESET_PASSWORD_URL` chính xác
- ⚠️ Sử dụng HTTPS trong sản xuất
- ⚠️ Triển khai giới hạn tốc độ
- ⚠️ Sử dụng biến môi trường cho thông tin xác thực
- ⚠️ Cấu hình CORS với nguồn gốc cụ thể

---

## 📞 Hỗ Trợ và Liên Hệ (Support and Contact)

Để có thêm thông tin về API, hãy kiểm tra:
1. Tài liệu này
2. Mã nguồn trong `app/routers/`
3. Swagger UI có sẵn tại `/docs`
4. ReDoc có sẵn tại `/redoc`

---

**Cập nhật lần cuối** (Last Update): 5 tháng 5 năm 2026  
**Trạng thái** (Status): Đang Phát Triển (In Development)
