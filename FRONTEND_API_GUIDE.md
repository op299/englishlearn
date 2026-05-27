# LexiRise Frontend API Guide

Tai lieu nay mo ta cac API backend hien tai de frontend tich hop cac man hinh chinh cua LexiRise.

## Tong Quan

- Framework backend: FastAPI
- Base URL local: `http://localhost:8000`
- API prefix: `/api/v1`
- API docs: `http://localhost:8000/docs`
- Auth: JWT Bearer token
- Database: MySQL async qua SQLAlchemy
- Response fields dung `snake_case`

Header cho cac endpoint can dang nhap:

```http
Authorization: Bearer <access_token>
```

## Endpoint Summary

| Method | Path | Auth | Muc dich |
|---|---|---:|---|
| GET | `/health` | No | Health check |
| POST | `/api/v1/auth/register` | No | Dang ky |
| POST | `/api/v1/auth/login` | No | Dang nhap |
| POST | `/api/v1/auth/refresh` | No | Refresh access token |
| POST | `/api/v1/auth/reset-password` | No | Dat lai mat khau |
| GET | `/api/v1/auth/me` | Yes | Lay user hien tai |
| GET | `/api/v1/learning/topics` | No | List/search topics |
| GET | `/api/v1/learning/explore` | Yes | Data cho man Explore |
| GET | `/api/v1/learning/topics/{topic_id}/lessons` | No | Lessons cua topic |
| GET | `/api/v1/learning/lessons/{lesson_id}` | No | Lesson detail va questions |
| GET | `/api/v1/user/dashboard` | Yes | Data cho Home dashboard |
| GET | `/api/v1/user/profile` | Yes | Profile va stats |
| PATCH | `/api/v1/user/profile` | Yes | Cap nhat profile |
| PATCH | `/api/v1/user/settings` | Yes | Cap nhat goal/theme/settings |
| PUT | `/api/v1/user/security` | Yes | Doi mat khau |
| POST | `/api/v1/lessons/{lesson_id}/submit` | Yes | Hoan thanh lesson |
| GET | `/api/v1/progress/summary` | Yes | Data cho Progress screen |
| GET | `/api/v1/review` | Yes | Lessons can review |
| GET | `/api/v1/review/mistakes` | Yes | Cau sai de review |

## Screen Mapping

### 1. Define Daily Commitment

Dung khi user chon 5/10/15 phut moi ngay.

```http
PATCH /api/v1/user/settings
```

Request:

```json
{
  "daily_goal_minutes": 10
}
```

Response:

```json
{
  "message": "Cap nhat thanh cong"
}
```

### 2. Explore

Dung endpoint tong hop:

```http
GET /api/v1/learning/explore?q=business&level=B2
```

Query params:

| Param | Required | Values |
|---|---:|---|
| `q` | No | keyword tim topic |
| `level` | No | `A1`, `A2`, `B1`, `B2`, `C1`, `C2` |

Response mau:

```json
{
  "vocabulary_topics": [
    {
      "id": "topic-b2-business",
      "title": "Business Communication",
      "level": "B2",
      "category": "Vocabulary",
      "lesson_count": 4,
      "completed_lessons": 1,
      "progress_percent": 25
    }
  ],
  "grammar_topics": [
    {
      "id": "topic-b2-passive-voice",
      "title": "Passive Voice",
      "level": "B2",
      "category": "Grammar",
      "lesson_count": 4,
      "completed_lessons": 0,
      "progress_percent": 0
    }
  ],
  "stats": {
    "retention_rate": 84,
    "daily_goal_minutes": 10,
    "daily_goal_completed": 2,
    "daily_goal_target": 3
  },
  "total": 2
}
```

Neu chi can list topic public:

```http
GET /api/v1/learning/topics?category=Vocabulary&level=B2&q=business
```

### 3. Home Dashboard

Dung cho man Home: daily goal, today's mission, streak, words met.

```http
GET /api/v1/user/dashboard
```

Response mau:

```json
{
  "streak": 12,
  "today_xp": 180,
  "total_xp": 4200,
  "daily_goal_minutes": 10,
  "tier": "Beginner",
  "message": "Keep going!",
  "words_mastered": 1284,
  "accuracy": 92,
  "retention_rate": 84,
  "daily_goal": {
    "minutes": 10,
    "target_xp": 300,
    "today_xp": 180,
    "percent": 60,
    "completed_lessons": 2,
    "target_lessons": 3
  },
  "missions": [
    {
      "lesson_id": "lesson-a1-family-01",
      "topic_id": "topic-a1-family",
      "title": "Family and Friends",
      "description": "Build fluency with family and friends vocabulary.",
      "category": "Vocabulary",
      "level": "A1",
      "lesson_order": 1,
      "xp_reward": 100,
      "completed_questions": 0,
      "total_questions": 3,
      "progress_percent": 0,
      "is_completed": false,
      "label": "CORE"
    },
    {
      "lesson_id": "lesson-a1-food-01",
      "topic_id": "topic-a1-food",
      "title": "Food and Drinks",
      "description": "Build fluency with food and drinks vocabulary.",
      "category": "Vocabulary",
      "level": "A1",
      "lesson_order": 1,
      "xp_reward": 100,
      "completed_questions": 0,
      "total_questions": 3,
      "progress_percent": 0,
      "is_completed": false,
      "label": "CORE"
    },
    {
      "lesson_id": "lesson-a1-school-01",
      "topic_id": "topic-a1-school",
      "title": "School Life",
      "description": "Build fluency with school life vocabulary.",
      "category": "Vocabulary",
      "level": "A1",
      "lesson_order": 1,
      "xp_reward": 110,
      "completed_questions": 0,
      "total_questions": 3,
      "progress_percent": 0,
      "is_completed": false,
      "label": "CORE"
    }
  ]
}
```

**Ghi chu ve Mission logic:**
- `target_lessons` la **so luong mission duoc gan cho hom nay** (khong con la con so co dinh nhu truoc).
- `target_xp` = `daily_goal_minutes * 30` (da giam tu `* 50`).
- Missions duoc chon **ngau nhien dua tren seed theo ngay** (`random.Random(f"{date.today()}_{user.id}")`), dam bao **moi ngay missions khac nhau**.
- Chi chon **cac lesson chua hoan thanh** (da hoan thanh hom qua se bi loai tru, qua ngay moi reset).
- So luong mission duoc chon sao cho **tong XP cua missions >= target_xp**. Neu thieu, se lay them tu level cao hon.
- Neu tat ca lesson da hoan thanh, se lay lai 3 lesson cu (da complete) de hien thi.

### 4. Progress

Dung cho man Progress: words mastered, activity 7 ngay, streak, accuracy, milestones, daily goal.

```http
GET /api/v1/progress/summary
```

Response mau:

```json
{
  "words_mastered": 1284,
  "words_mastered_since_yesterday": 12,
  "activity": [
    {
      "date": "2026-05-20",
      "weekday": "Wed",
      "completed_lessons": 2,
      "xp": 300,
      "minutes": 24
    }
  ],
  "streak": 14,
  "accuracy": 92,
  "retention_rate": 84,
  "recent_milestones": [
    {
      "title": "Advanced Syntax Completed",
      "description": "Module 4 - +450 XP",
      "occurred_at": "2026-05-26T20:30:00",
      "is_highlighted": true
    }
  ],
  "daily_goal_minutes": 10,
  "daily_goal_xp": 300,
  "today_xp": 180,
  "daily_goal_percent": 60,
  "today_completed_lessons": 2,
  "daily_goal_target_lessons": 3,
  "ranking": "Top 10%"
}
```

### 5. Lesson Detail

Dung khi user vao mot lesson de hoc.

```http
GET /api/v1/learning/lessons/{lesson_id}
```

Response:

```json
{
  "lesson_id": "lesson-b2-business-01",
  "topic_title": "Business Communication",
  "order": 1,
  "xp_reward": 220,
  "questions": [
    {
      "id": "q-b2-business-01-01",
      "word": "Business Communication Core Word L1.1",
      "context_sentence": "In Business Communication, lesson 1 asks learners to practice core word at B2 level.",
      "correct_answer": "A central word or structure used in this topic for Business Communication at B2 level.",
      "distractors": ["A random place name - Business Communication"],
      "image_url": null
    }
  ]
}
```

### 6. Session Complete

Dung khi user hoan thanh lesson. Endpoint nay cap nhat XP, streak, words mastered, review flag va tao session history.

```http
POST /api/v1/lessons/{lesson_id}/submit
```

Request toi thieu:

```json
{
  "accuracy": 94,
  "time_spent": 720
}
```

Request day du neu frontend muon luu cau sai de Review Mistakes:

```json
{
  "accuracy": 94,
  "time_spent": 720,
  "answers": [
    {
      "question_id": "q-b2-business-01-01",
      "selected_answer": "Wrong answer",
      "is_correct": false
    },
    {
      "question_id": "q-b2-business-01-02",
      "selected_answer": "Correct answer",
      "is_correct": true
    }
  ]
}
```

Response:

```json
{
  "lesson_id": "lesson-b2-business-01",
  "topic_title": "Business Communication",
  "lesson_order": 1,
  "accuracy": 94,
  "time_spent": 720,
  "earned_xp": 220,
  "total_xp": 5220,
  "current_streak": 14,
  "mastered_words": 1284,
  "ranking": "Top 10%",
  "needs_review": false,
  "already_completed": false,
  "daily_goal_percent": 70,
  "mastery": {
    "title": "Vocabulary Master",
    "level": 6,
    "progress_percent": 22
  }
}
```

Important:

- Neu submit lai cung lesson da completed, backend van luu session moi nhung `earned_xp = 0`.
- `needs_review = true` khi `accuracy < 70`.
- `answers` la optional. Neu khong gui, Review Mistakes se khong co du lieu cau sai moi.

### 7. Review

Lay lesson can on tap:

```http
GET /api/v1/review
```

Response:

```json
{
  "total": 1,
  "lessons": [
    {
      "lesson_id": "lesson-b2-business-01",
      "topic_title": "Business Communication",
      "lesson_order": 1,
      "xp_reward": 220,
      "accuracy": 62.5,
      "needs_review": true
    }
  ]
}
```

Lay cau sai:

```http
GET /api/v1/review/mistakes?limit=50
```

Response:

```json
{
  "total": 1,
  "mistakes": [
    {
      "question_id": "q-b2-business-01-01",
      "lesson_id": "lesson-b2-business-01",
      "topic_title": "Business Communication",
      "lesson_order": 1,
      "word": "Negotiation",
      "context_sentence": "The salary negotiation lasted nearly two hours.",
      "selected_answer": "Celebration",
      "correct_answer": "A discussion to reach an agreement.",
      "distractors": ["Celebration", "Competition", "Vacation"],
      "answered_at": "2026-05-26T20:30:00"
    }
  ]
}
```

## Auth APIs

### Register

```http
POST /api/v1/auth/register
```

Request:

```json
{
  "email": "user@example.com",
  "password": "Password123",
  "full_name": "Nguyen Van A",
  "daily_goal_minutes": 10,
  "current_level": "A1"
}
```

Response:

```json
{
  "user_id": "string",
  "email": "user@example.com",
  "full_name": "Nguyen Van A",
  "access_token": "jwt_access_token",
  "refresh_token": "jwt_refresh_token",
  "token_type": "bearer"
}
```

### Login

```http
POST /api/v1/auth/login
```

Request:

```json
{
  "email": "user@example.com",
  "password": "Password123"
}
```

Response:

```json
{
  "user_id": "string",
  "email": "user@example.com",
  "full_name": "Nguyen Van A",
  "current_level": "A1",
  "access_token": "jwt_access_token",
  "refresh_token": "jwt_refresh_token",
  "token_type": "bearer"
}
```

### Refresh

```http
POST /api/v1/auth/refresh
```

Request:

```json
{
  "refresh_token": "jwt_refresh_token"
}
```

Response:

```json
{
  "access_token": "new_access_token",
  "token_type": "bearer"
}
```

### Me

```http
GET /api/v1/auth/me
```

Response:

```json
{
  "user_id": "string",
  "email": "user@example.com",
  "full_name": "Nguyen Van A",
  "current_level": "B1"
}
```

## User APIs

### Get Profile

```http
GET /api/v1/user/profile
```

Response:

```json
{
  "email": "user@example.com",
  "full_name": "Nguyen Van A",
  "avatar_url": null,
  "current_level": "B1",
  "total_xp": 5220,
  "streak": 14,
  "words_mastered": 1284,
  "total_words": 1500,
  "mastery_ratio": 85.6,
  "tier": "Intermediate"
}
```

### Update Profile

```http
PATCH /api/v1/user/profile
```

Request:

```json
{
  "full_name": "Nguyen Van A",
  "avatar_url": "https://example.com/avatar.png",
  "current_level": "B2"
}
```

### Update Settings

```http
PATCH /api/v1/user/settings
```

Request:

```json
{
  "daily_goal_minutes": 15,
  "theme": "dark",
  "high_contrast_borders": true,
  "notifications_enabled": false,
  "current_level": "B2"
}
```

### Change Password

```http
PUT /api/v1/user/security
```

Request:

```json
{
  "old_password": "OldPassword123",
  "new_password": "NewPassword123",
  "confirm_password": "NewPassword123"
}
```

## Backend/Database Notes

`english_app.sql` hien la script chinh de tao database va seed du lieu demo lon.

Script nay tao:

- `48` topics
- `192` lessons
- `1920` questions
- `users`, `user_settings`, `user_stats`, `user_progress`
- `user_lesson_sessions` de tinh XP hom nay, activity, milestones
- `user_question_attempts` de hien Review Mistakes

Chay import:

```powershell
python import_db.py
```

Can luu y:

- `english_app.sql` co `DROP TABLE`, nen se reset database `lexirise`.
- Demo users trong seed dung mat khau: `Password123!`
- Neu database cu da ton tai truoc khi them API moi, can re-import `english_app.sql` hoac migrate them 2 bang moi: `user_lesson_sessions`, `user_question_attempts`, va cot `user_progress.last_studied_at`.

## Frontend Integration Flow

### App Bootstrap

1. Neu co `access_token`, goi `GET /api/v1/auth/me`.
2. Neu `401`, goi `POST /api/v1/auth/refresh`.
3. Neu refresh fail, dua user ve login.
4. Sau khi authenticated, prefetch:
   - `GET /api/v1/user/dashboard`
   - `GET /api/v1/progress/summary`
   - `GET /api/v1/learning/explore`

### Learn Lesson

1. `GET /api/v1/learning/explore`
2. User chon topic.
3. `GET /api/v1/learning/topics/{topic_id}/lessons`
4. User chon lesson.
5. `GET /api/v1/learning/lessons/{lesson_id}`
6. Frontend cham diem local.
7. `POST /api/v1/lessons/{lesson_id}/submit`
8. Render Session Complete bang response submit.
9. Refresh:
   - `GET /api/v1/user/dashboard`
   - `GET /api/v1/progress/summary`

### Review Mistakes

1. `GET /api/v1/review`
2. `GET /api/v1/review/mistakes?limit=50`
3. Khi user hoc lai, submit lai lesson bang endpoint submit.

## Error Format

Business error:

```json
{
  "detail": "Lesson not found"
}
```

Validation error:

```json
{
  "detail": [
    {
      "type": "greater_than",
      "loc": ["body", "time_spent"],
      "msg": "Input should be greater than 0"
    }
  ]
}
```

Server error:

```json
{
  "detail": "Loi server, vui long thu lai sau."
}
```
