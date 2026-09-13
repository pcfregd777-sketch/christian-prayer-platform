# FINAL DEPLOYMENT CHECKLIST — USER ACTIONS

## 1. Infrastructure
- [ ] Choose cloud host
- [ ] Create managed PostgreSQL
- [ ] Create domain and DNS
- [ ] Enable HTTPS

## 2. Accounts / credentials
- [ ] SMS/OTP provider
- [ ] Payment gateway merchant account
- [ ] Email provider
- [ ] Push notification project
- [ ] Secure video provider
- [ ] Maps provider if rider tracking is enabled
- [ ] Object storage for product images

## 3. Configure
- [ ] Copy .env.example to .env
- [ ] Add secrets in host dashboard (never commit them)
- [ ] Set production database URL
- [ ] Set strong JWT_SECRET
- [ ] Configure allowed domains/CORS
- [ ] Configure provider webhooks

## 4. Deploy
- [ ] Build API container
- [ ] Run database migrations
- [ ] Deploy Admin/Vendor panels
- [ ] Build signed Android APK/AAB from Flutter apps
- [ ] Test every payment, booking, notification and cancellation flow

## 5. Before public launch
- [ ] Privacy Policy
- [ ] Terms
- [ ] Service/Cancellation/Refund policies
- [ ] Offering policy
- [ ] Support contacts
- [ ] Consent/recording policy
- [ ] Backups and monitoring
