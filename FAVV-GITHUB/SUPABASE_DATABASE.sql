-- FAVV Assistent - eenvoudige veilige basis voor een NIEUW TESTPROJECT
-- Nog niet uitvoeren in productie.
create extension if not exists pgcrypto;

create table if not exists public.businesses (
  id uuid primary key default gen_random_uuid(),
  name text not null,
  enterprise_number text not null unique,
  owner_user_id uuid not null references auth.users(id),
  created_at timestamptz not null default now()
);

create table if not exists public.business_members (
  business_id uuid not null references public.businesses(id) on delete cascade,
  user_id uuid not null references auth.users(id) on delete cascade,
  role text not null check (role in ('owner','manager','employee')),
  active boolean not null default true,
  primary key (business_id,user_id)
);

create table if not exists public.app_data (
  id uuid primary key default gen_random_uuid(),
  business_id uuid not null references public.businesses(id) on delete cascade,
  data_type text not null,
  data jsonb not null default '{}'::jsonb,
  created_by uuid references auth.users(id),
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);

alter table public.businesses enable row level security;
alter table public.business_members enable row level security;
alter table public.app_data enable row level security;

create or replace function public.is_business_member(target_business uuid)
returns boolean language sql stable security definer set search_path=public
as $$
  select exists (
    select 1 from public.business_members m
    where m.business_id=target_business
      and m.user_id=auth.uid()
      and m.active=true
  )
$$;

create policy "members read businesses"
on public.businesses for select to authenticated
using (public.is_business_member(id));

create policy "members read memberships"
on public.business_members for select to authenticated
using (public.is_business_member(business_id));

create policy "members read app data"
on public.app_data for select to authenticated
using (public.is_business_member(business_id));

create policy "members insert app data"
on public.app_data for insert to authenticated
with check (public.is_business_member(business_id));

create policy "members update app data"
on public.app_data for update to authenticated
using (public.is_business_member(business_id))
with check (public.is_business_member(business_id));
