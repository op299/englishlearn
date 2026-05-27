# Yêu cầu Frontend — XP, Daily Goal & Dashboard

Tài liệu này dành cho **Frontend team** để đảm bảo gọi đúng API và tự tính đúng các giá trị hiển thị.

---

## 1. Công thức quan trọng (Frontend tự tính, không dùng từ backend)

| Field | Công thức | Ghi chú |
|---|---|---|
| `target_xp` | `daily_goal_minutes × 30` | Backend trả về giá trị này nhưng Frontend **tự tính lại** để đảm bảo đồng bộ |
| `daily_goal_xp` | `daily_goal_minutes × 30` | Tương tự, tự tính local |
| `percent` (daily_goal) | `min(today_xp / target_xp × 100, 100)` | Giới hạn tối đa 100% |
| `daily_goal_percent` | `min(today_xp / daily_goal_xp × 100, 100)` | Giới hạn tối đa 100% |

**Quan trọng:** Backend có thể trả về giá trị cũ (vd: `target_xp` tính theo `minutes * 50`).  
→ Frontend **luôn tự tính lại** các field trên theo công thức `minutes * 30`.

---

## 2. API Dashboard — `GET /api/v1/user/dashboard`

### Response mẫu

```json
{
  "streak": 12,
  "today_xp": 190,
  "total_xp": 4200,
  "daily_goal_minutes": 5,
  "tier": "Beginner",
  "message": "Keep going!",
  "words_mastered": 1284,
  "accuracy": 92,
  "retention_rate": 84,
  "daily_goal": {
    "minutes": 5,
    "target_xp": 150,
    "today_xp": 190,
    "percent": 100,
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
    }
  ]
}
```

### Các field Frontend phải tự tính

| Field trong response | Frontend dùng? | Xử lý |
|---|---|---|
| `daily_goal.target_xp` | ❌ Bỏ qua | Tự tính `daily_goal_minutes * 30` |
| `daily_goal.percent` | ❌ Bỏ qua | Tự tính `min(today_xp / target_xp * 100, 100)` |
| `daily_goal.target_lessons` | ✅ Dùng | Hiển thị trực tiếp (bằng `missions.length`) |
| `daily_goal.completed_lessons` | ✅ Dùng | Hiển thị trực tiếp |
| `daily_goal.today_xp` | ✅ Dùng | Hiển thị trực tiếp |
| `daily_goal.minutes` | ✅ Dùng | Hiển thị trực tiếp |
| `missions[]` | ✅ Dùng | Hiển thị trực tiếp |
| `missions[].xp_reward` | ✅ Dùng | Hiển thị trực tiếp |
| `today_xp` | ✅ Dùng | Hiển thị trực tiếp |

### Logic hiển thị thanh XP (Progress Bar)

```typescript
const targetXp = daily_goal_minutes * 30;        // tự tính, không dùng backend
const percent = Math.min(today_xp / targetXp * 100, 100);  // tự tính, cap 100%

// Hiển thị thanh XP với percent%
// Nếu percent >= 100 → hiển thị trạng thái "Đã hoàn thành mục tiêu"
```

### Logic hiển thị missions

```typescript
// target_lessons = missions.length (có thể dùng từ backend hoặc tự đếm)
const targetLessons = daily_goal?.target_lessons || missions.length;
const completedLessons = daily_goal?.completed_lessons || 0;

// Hiển thị: "X/Y lessons completed"
```

---

## 3. API Progress Summary — `GET /api/v1/progress/summary`

### Response mẫu

```json
{
  "words_mastered": 1284,
  "words_mastered_since_yesterday": 12,
  "activity": [...],
  "streak": 14,
  "accuracy": 92,
  "retention_rate": 84,
  "recent_milestones": [...],
  "daily_goal_minutes": 5,
  "daily_goal_xp": 150,
  "today_xp": 190,
  "daily_goal_percent": 100,
  "today_completed_lessons": 2,
  "daily_goal_target_lessons": 2,
  "ranking": "Top 10%"
}
```

### Các field Frontend phải tự tính

| Field trong response | Frontend dùng? | Xử lý |
|---|---|---|
| `daily_goal_xp` | ❌ Bỏ qua | Tự tính `daily_goal_minutes * 30` |
| `daily_goal_percent` | ❌ Bỏ qua | Tự tính `min(today_xp / (daily_goal_minutes * 30) * 100, 100)` |
| `daily_goal_minutes` | ✅ Dùng | Dùng để tính target_xp |
| `today_xp` | ✅ Dùng | Hiển thị trực tiếp |
| `today_completed_lessons` | ✅ Dùng | Hiển thị trực tiếp |
| `words_mastered` | ✅ Dùng | Hiển thị trực tiếp |
| `streak` | ✅ Dùng | Hiển thị trực tiếp |

---

## 4. API Submit Lesson — `POST /api/v1/lessons/{lesson_id}/submit`

### Request

```json
{
  "accuracy": 94,
  "time_spent": 720,
  "answers": [
    {
      "question_id": "q-...",
      "selected_answer": "answer text",
      "is_correct": true
    }
  ]
}
```

### Response — Các field cần lưu ý

```json
{
  "lesson_id": "...",
  "earned_xp": 220,
  "total_xp": 5220,
  "current_streak": 14,
  "mastered_words": 1284,
  "ranking": "Top 10%",
  "needs_review": false,
  "already_completed": false,
  "daily_goal_percent": 100,
  "mastery": { ... }
}
```

### Xử lý sau submit

```typescript
// Cập nhật today_xp local (nếu có tracking)
todayXp += earned_xp;

// Tính daily_goal_percent mới sau submit
const newPercent = Math.min(todayXp / (daily_goal_minutes * 30) * 100, 100);

// Nếu already_completed = true → không cộng earned_xp nữa
// (Backend trả earned_xp = 0 nếu lesson đã hoàn thành trước đó)
```

---

## 5. API Explore — `GET /api/v1/learning/explore`

### Response stats

```json
{
  "stats": {
    "retention_rate": 84,
    "daily_goal_minutes": 10,
    "daily_goal_completed": 2,
    "daily_goal_target": 3
  }
}
```

Các field này **có thể dùng trực tiếp** từ backend:
- `daily_goal_completed`: số lesson đã học hôm nay
- `daily_goal_target`: target lessons (dựa trên minutes, do backend quyết định)

---

## 6. Tổng kết: Field nào dùng từ backend, field nào tự tính

### 🔵 Dùng trực tiếp từ backend

| Field | Endpoint |
|---|---|
| `missions[]` | `/user/dashboard` |
| `missions[].xp_reward` | `/user/dashboard` |
| `daily_goal.target_lessons` | `/user/dashboard` |
| `daily_goal.completed_lessons` | `/user/dashboard` |
| `daily_goal.today_xp` | `/user/dashboard` |
| `today_xp` | `/user/dashboard`, `/progress/summary` |
| `total_xp` | `/user/dashboard` |
| `streak` | `/user/dashboard`, `/progress/summary` |
| `words_mastered` | `/user/dashboard`, `/progress/summary` |
| `accuracy` | `/user/dashboard`, `/progress/summary` |
| `retention_rate` | `/user/dashboard`, `/progress/summary` |
| `earned_xp` (submit response) | `/lessons/{id}/submit` |
| `already_completed` (submit response) | `/lessons/{id}/submit` |

### 🟡 Tự tính local (bỏ qua giá trị backend)

| Field | Công thức |
|---|---|
| `target_xp` | `daily_goal_minutes * 30` |
| `daily_goal_xp` | `daily_goal_minutes * 30` |
| `percent` (daily_goal bar) | `min(today_xp / (daily_goal_minutes * 30) * 100, 100)` |
| `daily_goal_percent` | `min(today_xp / (daily_goal_minutes * 30) * 100, 100)` |

---

## 7. Một số lưu ý quan trọng

1. **`daily_goal_minutes` là nguồn sự thật duy nhất.**  
   Mọi tính toán target_xp, percent đều dựa trên giá trị này. Luôn lưu `daily_goal_minutes` local sau khi user đổi trong Settings.

2. **Percent luôn được cap ở 100%.**  
   Công thức: `Math.min(todayXp / (dailyGoalMinutes * 30) * 100, 100)`.  
   Không bao giờ hiển thị > 100% cho thanh progress bar.

3. **`target_lessons` nên dùng `missions.length` làm fallback.**  
   ```typescript
   const targetLessons = dashboard.daily_goal?.target_lessons || dashboard.missions.length;
   ```

4. **Sau mỗi lần submit lesson thành công**, frontend nên:
   - Cộng `earned_xp` vào `today_xp` local (nếu `already_completed = false`)
   - Tính lại daily_goal_percent với today_xp mới
   - Cập nhật streak, total_xp, mastered_words từ response

5. **Không hardcode target_xp, target_lessons.**  
   Luôn tính động dựa trên `daily_goal_minutes` hiện tại của user.
