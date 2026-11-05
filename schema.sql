-- NetLedger Supabase Schema for Lebanese ISP Management
-- Run in Supabase SQL Editor.

create extension if not exists pgcrypto;

-- 1. Clients Table
create table if not exists public.clients (
  id uuid primary key default gen_random_uuid(),
  name text not null,
  phone text not null,
  address text,
  package_name text,
  monthly_fee numeric(14,2) not null default 0 check (monthly_fee >= 0),
  currency text not null check (currency in ('USD','LBP')),
  status text not null default 'active' check (status in ('active','inactive')),
  start_date date,
  notes text,
  created_at timestamptz not null default now()
);

-- 2. Monthly Invoices Table (Ledger & Arrears tracking)
create table if not exists public.invoices (
  id uuid primary key default gen_random_uuid(),
  client_id uuid not null references public.clients(id) on delete cascade,
  billing_month date not null, -- First day of billing month (e.g. 2026-11-01)
  amount numeric(14,2) not null check (amount >= 0),
  currency text not null check (currency in ('USD','LBP')),
  status text not null default 'unpaid' check (status in ('unpaid','paid','partial')),
  created_at timestamptz not null default now(),
  unique(client_id, billing_month)
);

-- 3. Payments Table
create table if not exists public.payments (
  id uuid primary key default gen_random_uuid(),
  client_id uuid not null references public.clients(id) on delete restrict,
  invoice_id uuid references public.invoices(id) on delete set null,
  amount numeric(14,2) not null check (amount > 0),
  currency text not null check (currency in ('USD','LBP')),
  paid_at date not null default current_date,
  method text,
  note text,
  created_at timestamptz not null default now()
);

-- Performance Indexes
create index if not exists clients_name_idx on public.clients (lower(name));
create index if not exists clients_phone_idx on public.clients (phone);
create index if not exists invoices_client_month_idx on public.invoices (client_id, billing_month desc);
create index if not exists payments_client_date_idx on public.payments (client_id, paid_at desc);

-- Enable Row Level Security (RLS)
alter table public.clients enable row level security;
alter table public.invoices enable row level security;
alter table public.payments enable row level security;

-- Admin RLS Policies
drop policy if exists "authenticated admins manage clients" on public.clients;
create policy "authenticated admins manage clients" on public.clients for all to authenticated using (true) with check (true);

drop policy if exists "authenticated admins manage invoices" on public.invoices;
create policy "authenticated admins manage invoices" on public.invoices for all to authenticated using (true) with check (true);

drop policy if exists "authenticated admins manage payments" on public.payments;
create policy "authenticated admins manage payments" on public.payments for all to authenticated using (true) with check (true);
