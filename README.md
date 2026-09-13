# Christian Prayer Platform — Complete Deployable Monorepo

## Applications
- apps/customer-mobile — Flutter customer app
- apps/prayer-team-mobile — Flutter prayer team app starter
- apps/rider-mobile — Flutter rider app starter
- apps/admin-web — Next.js admin panel
- apps/vendor-web — Next.js vendor panel
- services/api — FastAPI backend
- infra — Docker/Nginx deployment assets

## Core modules
Prayer Requests, Online Video Prayer, House Visits, Prayer Oil Store,
Devotional Marketplace, Multi-Vendor, Cart, Orders, Delivery, Offerings,
Notifications, Support, Reports and RBAC.

## Local development
1. Copy `.env.example` to `.env`
2. Set production secrets/providers.
3. `docker compose up --build`

## Production
Use a managed PostgreSQL database and Redis, configure HTTPS, then deploy
containers to Railway/Render/AWS/DigitalOcean/Azure/GCP.

Provider credentials are intentionally not embedded:
- SMS/OTP
- Payment gateway
- Email
- Push notifications
- Video provider
- Maps
