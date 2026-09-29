# AI Agent Spend Guardian (SpendGuard) 🛡️

> **Stop runaway AI bills before they start.**

SpendGuard is a mobile application (Android & iPhone) built with **Flutter** that empowers developers, power users, and small teams to control, monitor, budget, and instantly freeze their AI tool and agent spending.

---

## 🌟 Key Features

1. **Multi-Provider Unified Tracking**: Connect **OpenAI**, **Anthropic (Claude)**, and **Google Gemini** accounts with zero-knowledge, hardware-backed AES-256 encryption.
2. **Real-time Live Dashboard**:
   - Today's spending vs. daily budget cap.
   - Monthly spending progress bar with dynamic color alerts.
   - Daily spending trend charts (last 7 days).
   - Cost breakdown by provider and individual model (GPT-4o, Claude 3.5 Sonnet, Gemini 1.5 Pro).
3. **Smart Budgeting & Alerts**:
   - Daily and Monthly spending caps.
   - Soft alerts delivered at 70% and 90% via push notifications and email.
   - Spending anomaly detection (e.g. sudden spike of 120 calls in 4 minutes).
4. **1-Tap Emergency Kill Switch**:
   - Instant suspension of all outbound AI agent calls.
   - SpendGuard Proxy returns immediate `HTTP 429 / 403 Stop Signal` to runaway agents.
   - One-tap unfreeze with confirmation protection.
5. **Subscription Model**:
   - **Free Plan**: 1 connected provider, daily tracking, standard push alerts.
   - **Pro Plan** ($9.99/mo): Unlimited providers, hard limit kill-switch, sub-second gateway, unlimited CSV history.

---

## 📱 App Architecture

```
[ SpendGuard Mobile App (Flutter) ]
     ├── Local AES-256 Encrypted Keystore (KeyStore / Keychain)
     ├── Riverpod Reactive State Architecture
     └── GoRouter Multi-route Navigation
                 │
                 ▼
[ Supabase Cloud Backend & RLS ]
     ├── Row Level Security (RLS) policies per user
     ├── Tables: profiles, budget_configs, provider_connections, spend_records, alert_logs, freeze_states
     └── Edge Functions:
          ├── sync-spend: Periodic polling of provider billing endpoints
          ├── emergency-kill: Instantaneous freeze / unfreeze webhook
          └── spend-proxy: Zero-latency AI gateway with instant kill-switch
```

---

## 🚀 Quick Start & Local Preview

### 1. Interactive Web Simulator (Instant Preview)
Open `web_preview/index.html` in your web browser:
```bash
# Windows PowerShell
Start-Process "web_preview\index.html"
```
Or start a local HTTP server:
```bash
npx serve web_preview
```
This lets you test all screens (Dashboard, Emergency Freeze, Budgets, Provider connections, History, and Dark/Light modes) inside an authentic phone frame.

### 2. Flutter Mobile Build
When Flutter SDK is installed on your machine:
```bash
flutter pub get
flutter run
```

### 3. Codemagic CI/CD Build
SpendGuard includes a pre-configured `codemagic.yaml` ready for automated continuous deployment:
- Builds release Android App Bundle (`.aab`) and APK.
- Builds iOS `.ipa` for TestFlight and App Store submission.
- Runs `flutter analyze` and `flutter test`.

---

## 🤖 Protecting AI Agents (SpendGuard Gateway)

To give agents sub-second emergency freeze protection, simply point their `baseURL` to your SpendGuard proxy:

### Python (OpenAI SDK):
```python
from openai import OpenAI

client = OpenAI(
    base_url="https://YOUR_PROJECT_ID.functions.supabase.co/spend-proxy/v1",
    api_key="your_spendguard_api_key_or_openai_key"
)

# If you hit "Freeze" in the SpendGuard app, this call immediately stops!
response = client.chat.completions.create(
    model="gpt-4o",
    messages=[{"role": "user", "content": "Autonomous task..."}]
)
```

### LangChain / CrewAI:
```python
from langchain_openai import ChatOpenAI

llm = ChatOpenAI(
    model="gpt-4o",
    openai_api_base="https://YOUR_PROJECT_ID.functions.supabase.co/spend-proxy/v1"
)
```

---

## 🗄️ Database Setup (Supabase)

1. Open your Supabase SQL Editor.
2. Execute the migration script located at:
   `supabase/migrations/20260929_spendguard_schema.sql`
3. Deploy the Edge Functions:
   ```bash
   supabase functions deploy sync-spend
   supabase functions deploy emergency-kill
   supabase functions deploy spend-proxy
   ```
