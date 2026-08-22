-- TCG Invoicing — Supabase schema
-- Run this once in your Supabase project's SQL editor.
-- Keeps the existing text ids from store.json so payment links survive migration.

create table if not exists clients (
  id            text primary key,
  name          text not null,
  contact_name  text default '',
  email         text default '',
  address_lines jsonb default '[]'::jsonb,
  created_at    timestamptz default now()
);

create table if not exists invoices (
  id          text primary key,
  number      text not null,
  client_id   text references clients(id) on delete set null,
  issue_date  date,
  due_date    date,
  status      text default 'draft',          -- 'draft' | 'sent' (paid/partial/overdue are derived in the app)
  line_items  jsonb default '[]'::jsonb,
  tax_rate    numeric default 0,
  discount    numeric default 0,
  notes       text default '',
  created_at  timestamptz default now()
);

create table if not exists payments (
  id          text primary key,
  invoice_id  text references invoices(id) on delete cascade,
  date        date,
  amount      numeric not null default 0,
  method      text default '',
  note        text default '',
  created_at  timestamptz default now()
);

-- Single-row app settings (business info, logo, prefixes). id is pinned to 1.
create table if not exists settings (
  id   int primary key default 1,
  data jsonb not null,
  constraint settings_single_row check (id = 1)
);

create index if not exists invoices_client_id_idx on invoices(client_id);
create index if not exists payments_invoice_id_idx on payments(invoice_id);

-- Row Level Security: only an authenticated user (you) can read/write.
alter table clients  enable row level security;
alter table invoices enable row level security;
alter table payments enable row level security;
alter table settings enable row level security;

create policy "authed full access" on clients  for all
  using (auth.role() = 'authenticated') with check (auth.role() = 'authenticated');
create policy "authed full access" on invoices for all
  using (auth.role() = 'authenticated') with check (auth.role() = 'authenticated');
create policy "authed full access" on payments for all
  using (auth.role() = 'authenticated') with check (auth.role() = 'authenticated');
create policy "authed full access" on settings for all
  using (auth.role() = 'authenticated') with check (auth.role() = 'authenticated');

-- ===== State presence tracker =====
-- Trips are date ranges; overrides pin a single day. Home state lives in the
-- settings JSONB row, so every unlogged day counts as home.

create table if not exists location_trips (
  id                text primary key,
  state             text not null,
  start_date        date not null,
  end_date          date not null,
  purpose           text default '',
  travel_days_home  boolean not null default true,
  created_at        timestamptz default now()
);

create table if not exists location_overrides (
  id          text primary key,
  date        date not null unique,
  state       text not null,
  note        text default '',
  -- true = this state carries forward until the next marked day; false = this single day only
  sticky      boolean not null default false,
  created_at  timestamptz default now()
);
alter table location_overrides add column if not exists sticky boolean not null default false;

create index if not exists location_trips_start_date_idx on location_trips(start_date);
create index if not exists location_overrides_date_idx   on location_overrides(date);

alter table location_trips     enable row level security;
alter table location_overrides enable row level security;

drop policy if exists "authed full access" on location_trips;
drop policy if exists "authed full access" on location_overrides;

create policy "authed full access" on location_trips for all
  using (auth.role() = 'authenticated') with check (auth.role() = 'authenticated');
create policy "authed full access" on location_overrides for all
  using (auth.role() = 'authenticated') with check (auth.role() = 'authenticated');
