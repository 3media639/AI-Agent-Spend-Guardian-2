# AI Agent Spend Guardian (SpendGuard) 🛡️

> **Stop runaway AI bills before they start. Exclusive iOS App for iPhone.**

SpendGuard is a premium, Apple Human Interface Design-inspired mobile app created specifically for **iPhone (iOS)** using Flutter. It empowers developers, power users, and AI enthusiasts to monitor real-time AI spending across OpenAI, Anthropic Claude, and Google Gemini, set automated daily/monthly budgets, and immediately kill runaway agent loops with a single tap.

---

## 🎨 iOS Human Interface Design (Life Admin Aesthetic)

The user interface follows the clean, minimalist iOS aesthetic from modern Apple applications:
- **Teal & Mint Accents**: Deep Teal (`#0E7C86`) and Vibrant Mint (`#3CB8C3`) indicating health, financial safety, and calm assurance.
- **Glassmorphic Translucent Cards**: `rgba(255,255,255, 0.72)` (Light mode) and `rgba(44,46,54, 0.62)` (Dark mode) with backdrop blur and subtle Apple system borders.
- **Floating Island Navigation**: Suspended rounded bottom navigation bar with a centered red emergency freeze killswitch.
- **Circular Budget Ring**: Real-time animated remaining balance ring with instant color shifts (Teal -> Amber -> Red).

---

## 🌟 Key Features

1. **Multi-Provider Unified Tracking**: Connect **OpenAI**, **Anthropic (Claude)**, and **Google Gemini** accounts with zero-knowledge, iOS Keychain AES-256 encryption.
2. **Real-time Live Dashboard**:
   - Today's spending vs. daily budget cap.
   - Monthly spending progress ring with dynamic alerts.
   - Daily spending trend charts (last 7 days).
   - Cost breakdown by provider and individual model (GPT-4o, Claude 3.5 Sonnet, Gemini 1.5 Pro).
3. **Smart Budgeting & Alerts**:
   - Daily and Monthly spending caps.
   - Soft alerts delivered at 70% and 90% via Apple Push Notifications (APNs) and email.
   - Spending anomaly detection (e.g. sudden spike of 120 calls in 4 minutes).
4. **1-Tap Emergency Kill Switch**:
   - Instant suspension of all outbound AI agent calls.
   - SpendGuard Proxy returns immediate `HTTP 429 / 403 Stop Signal` to runaway agents.
   - One-tap unfreeze with biometric / confirmation protection.
5. **Subscription Model**:
   - **Free Plan**: 1 connected provider, daily tracking, standard push alerts.
   - **Pro Plan** ($9.99/mo): Unlimited providers, hard limit kill-switch, sub-second gateway, unlimited CSV history.

---

## 📱 App Architecture

```
[ SpendGuard iPhone App (Flutter iOS) ]
     ├── iOS Keychain AES-256 Encrypted Keystore
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

## 📦 How to Build the iOS App (.ipa) with Codemagic

This repository is pre-configured with `codemagic.yaml` specifically for iOS `.ipa` generation.

1. **Push this repository to GitHub**:
   - Remote URL: `https://github.com/3media639/AI-Agent-Spend-Guardian-2.git`
2. **Log into [Codemagic](https://codemagic.io/)**:
   - Click **Add Application** -> Select **GitHub** -> Choose `AI-Agent-Spend-Guardian-2`.
   - Select **Flutter App**.
3. **Run the iOS Workflow**:
   - Codemagic will detect the `ios-workflow` in `codemagic.yaml`.
   - Click **Start new build**.
   - Codemagic runs on Apple Silicon (`mac_mini_m1`), packages `Runner.app`, and generates `SpendGuard.ipa`.
4. **Download & Install**:
   - Download the artifact `SpendGuard.ipa` directly from Codemagic.
   - Install it on your iPhone via Apple Configurator, Sideloadly, TrollStore, or upload to TestFlight.

---

## 💻 Live Web Preview & Simulator

To preview and interact with the complete iOS app design in any browser:
Open `web_preview/index.html` in your web browser or run:
```powershell
Start-Process "web_preview\index.html"
```
You can switch screens, toggle Dark/Light mode, test the Emergency Killswitch, configure budgets, and add API keys directly in the iPhone simulator frame.
