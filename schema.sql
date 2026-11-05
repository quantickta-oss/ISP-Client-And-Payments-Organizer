-- NetLedger initial Supabase schema
-- Run in Supabase SQL Editor. Enable email/password auth and create the first admin user.
create extension if not exists pgcrypto;
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
create table if not exists public.payments (
  id uuid primary key default gen_random_uuid(),
  client_id uuid not null references public.clients(id) on delete restrict,
  amount numeric(14,2) not null check (amount > 0),
  currency text not null check (currency in ('USD','LBP')),
  paid_at date not null default current_date,
  method text,
  note text,
  created_at timestamptz not null default now()
);
create index if not exists clients_name_idx on public.clients (lower(name));
create index if not exists clients_phone_idx on public.clients (phone);
create index if not exists payments_client_date_idx on public.payments (client_id, paid_at desc);
-- Single-ISP starter: any authenticated admin can access the business data.
alter table public.clients enable row level security;
alter table public.payments enable row level security;
drop policy if exists "authenticated admins manage clients" on public.clients;
create policy "authenticated admins manage clients" on public.clients for all to authenticated using (true) with check (true);
drop policy if exists "authenticated admins manage payments" on public.payments;
create policy "authenticated admins manage payments" on public.payments for all to authenticated using (true) with check (true);
