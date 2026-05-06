# Healthcare Appointment System — Ruby on Rails 

A full-stack healthcare workflow system demonstrating the complete appointment lifecycle:

**Patient → Books Appointment → Admin Confirms → Doctor Processes → Diagnosis → Completed**

---

## Tech Stack

| Layer       | Technology                                |
|-------------|-------------------------------------------|
| Backend     | Ruby on Rails 7.1 (API mode), JWT, BCrypt |
| Database    | PostgreSQL 16                             |
| Frontend    | React 18 + Vite, Axios, plain CSS         |
| Container   | Docker + Docker Compose                   |

---

## Quick Start (Docker)

```bash
docker compose up --build
```

| Service  | URL                          |
|----------|-------------------------------|
| Frontend | http://localhost:3000         |
| Backend  | http://localhost:3001         |
| PostgreSQL | localhost:5432             |

> The API auto-migrates and seeds the database on startup.

---

## Demo Credentials

| Role    | Email                          | Password   |
|---------|-------------------------------|------------|
| Admin   | admin@healthcare.com           | Admin@123  |
| Doctor  | alice.smith@healthcare.com     | Doctor@123 |
| Doctor  | bob.johnson@healthcare.com     | Doctor@123 |
| Patient | carol.white@email.com          | Patient@123|
| Patient | david.brown@email.com          | Patient@123|

---

## Workflow

1. **Patient** logs in → Books an appointment (select doctor + time)
2. **Admin** logs in → Confirms or Cancels appointment
3. **Doctor** logs in → Starts appointment (Confirmed → InProgress)
4. **Doctor** → Adds medical record (diagnosis + notes) → Marks Completed
5. **Admin** → Views audit logs of all actions

---

## Appointment Status Transitions

```
Scheduled ──(Admin)──► Confirmed ──(Doctor)──► InProgress ──(Doctor)──► Completed
    │                      │
    └──────(Admin)──────────┴──────────────────────────────────────────► Cancelled
```

---

## Local Development (without Docker)

### Prerequisites

- Ruby >= 3.1
- PostgreSQL
- Node.js >= 18

### Backend

```bash
cd backend
bundle install
rails db:create db:migrate db:seed
rails server -p 3001
```

Runs on: http://localhost:3001

### Frontend

```bash
cd frontend
npm install
npm run dev
```

Runs on: http://localhost:5173

Set `VITE_API_URL=http://localhost:3001` in `frontend/.env` for local dev.

---

## API Endpoints

| Method | Endpoint                          | Role          |
|--------|-----------------------------------|---------------|
| POST   | /api/auth/login                   | Public        |
| POST   | /api/auth/register                | Public        |
| GET    | /api/doctors                      | Authenticated |
| POST   | /api/appointments                 | Patient       |
| GET    | /api/appointments                 | All roles     |
| PATCH  | /api/appointments/{id}/status     | Admin/Doctor  |
| POST   | /api/medical-records              | Doctor        |
| GET    | /api/medical-records/{apptId}     | All roles     |
| GET    | /api/audit-logs                   | Admin         |

---


![Image](https://github.com/user-attachments/assets/e71fec2d-10d6-4ad5-a39c-4fd7f3bfb1eb)
