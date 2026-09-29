-- ==============================================================================
-- AI Agent Spend Guardian (SpendGuard) - Supabase SQL Schema
-- ==============================================================================

-- Enable UUID extension
create extension if not exists "uuid-ossp";

-- 1. PROFILES & SUBSCRIPTIONS
create table public.profiles (
    id uuid primary key references auth.users(id) on delete cascade,
    display_name text,
    email text not null,
    subscription_tier text not null default 'free' check (subscription_tier in ('free', 'pro')),
    created_at timestamp with time zone default timezone('utc'::text, now()) not null,
    updated_at timestamp with time zone default timezone('utc'::text, now()) not null
);

-- 2. BUDGET CONFIGURATIONS
create table public.budget_configs (
    id uuid default uuid_generate_v4() primary key,
    user_id uuid references public.profiles(id) on delete cascade not null unique,
    daily_budget numeric(10, 2) default 10.00 not null,
    monthly_budget numeric(10, 2) default 100.00 not null,
    alert_at_70 boolean default true not null,
    alert_at_90 boolean default true not null,
    is_hard_limit_enabled boolean default false not null,
    push_notifications_enabled boolean default true not null,
    email_alerts_enabled boolean default false not null,
    alert_email text,
    updated_at timestamp with time zone default timezone('utc'::text, now()) not null
);

-- 3. CONNECTED AI PROVIDERS & ENCRYPTED KEYS
create table public.provider_connections (
    id uuid default uuid_generate_v4() primary key,
    user_id uuid references public.profiles(id) on delete cascade not null,
    provider_type text not null check (provider_type in ('openAI', 'anthropic', 'googleGemini', 'groq', 'openRouter')),
    is_active boolean default true not null,
    encrypted_key text not null,
    key_hint text, -- e.g. "sk-...4a8F"
    last_synced_at timestamp with time zone,
    created_at timestamp with time zone default timezone('utc'::text, now()) not null,
    unique(user_id, provider_type)
);

-- 4. SPEND & USAGE RECORDS (Granular tracking)
create table public.spend_records (
    id uuid default uuid_generate_v4() primary key,
    user_id uuid references public.profiles(id) on delete cascade not null,
    provider_type text not null,
    model_name text not null,
    prompt_tokens integer default 0 not null,
    completion_tokens integer default 0 not null,
    total_tokens integer default 0 not null,
    cost_usd numeric(12, 6) default 0.000000 not null,
    request_count integer default 1 not null,
    recorded_at timestamp with time zone default timezone('utc'::text, now()) not null
);

-- 5. ALERTS & NOTIFICATIONS LOG
create table public.alert_logs (
    id uuid default uuid_generate_v4() primary key,
    user_id uuid references public.profiles(id) on delete cascade not null,
    severity text not null check (severity in ('info', 'warning70', 'warning90', 'hardLimitReached', 'emergencyFreeze', 'anomalyDetected')),
    title text not null,
    message text not null,
    is_read boolean default false not null,
    related_provider text,
    created_at timestamp with time zone default timezone('utc'::text, now()) not null
);

-- 6. EMERGENCY FREEZE STATE (KILL-SWITCH)
create table public.freeze_states (
    user_id uuid primary key references public.profiles(id) on delete cascade,
    is_frozen boolean default false not null,
    frozen_at timestamp with time zone,
    reason text,
    is_hard_limit_triggered boolean default false not null,
    updated_at timestamp with time zone default timezone('utc'::text, now()) not null
);

-- ==============================================================================
-- ROW-LEVEL SECURITY (RLS) POLICIES
-- ==============================================================================
alter table public.profiles enable row level security;
alter table public.budget_configs enable row level security;
alter table public.provider_connections enable row level security;
alter table public.spend_records enable row level security;
alter table public.alert_logs enable row level security;
alter table public.freeze_states enable row level security;

-- Profiles: users can select and update only their own profile
create policy "Users can view own profile" on public.profiles for select using (auth.uid() = id);
create policy "Users can update own profile" on public.profiles for update using (auth.uid() = id);

-- Budget Configs:
create policy "Users can view own budgets" on public.budget_configs for select using (auth.uid() = user_id);
create policy "Users can insert own budgets" on public.budget_configs for insert with check (auth.uid() = user_id);
create policy "Users can update own budgets" on public.budget_configs for update using (auth.uid() = user_id);

-- Provider Connections:
create policy "Users can manage own provider keys" on public.provider_connections for all using (auth.uid() = user_id);

-- Spend Records:
create policy "Users can view own spend records" on public.spend_records for select using (auth.uid() = user_id);
create policy "Users can insert spend records" on public.spend_records for insert with check (auth.uid() = user_id);

-- Alert Logs:
create policy "Users can view own alerts" on public.alert_logs for select using (auth.uid() = user_id);
create policy "Users can update own alerts" on public.alert_logs for update using (auth.uid() = user_id);

-- Freeze States:
create policy "Users can manage own freeze state" on public.freeze_states for all using (auth.uid() = user_id);

-- ==============================================================================
-- INDEXES FOR FAST QUERYING
-- ==============================================================================
create index idx_spend_records_user_date on public.spend_records(user_id, recorded_at desc);
create index idx_spend_records_provider on public.spend_records(user_id, provider_type);
create index idx_alert_logs_user on public.alert_logs(user_id, is_read, created_at desc);
