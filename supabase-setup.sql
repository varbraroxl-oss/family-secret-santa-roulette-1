create table if not exists public.participants (
 codename text primary key,
 recipient_codename text,
 drawn_at timestamptz,
 constraint no_self_draw check (recipient_codename is null or recipient_codename <> codename)
);
alter table public.participants enable row level security;
revoke all on public.participants from anon, authenticated;
create or replace function public.admin_set_participants(p_codenames text[])
returns void language plpgsql security definer set search_path=public as $$
declare n int; i int; shuffled text[];
begin
 perform pg_advisory_xact_lock(918273);
 if coalesce(array_length(p_codenames,1),0)<2 or array_length(p_codenames,1)>20 then raise exception 'Enter between 2 and 20 codenames'; end if;
 if (select count(distinct lower(x)) from unnest(p_codenames) x) <> array_length(p_codenames,1) then raise exception 'Codenames must be unique'; end if;
 n:=array_length(p_codenames,1);
 -- Random permutation; retry until no one is assigned to self.
 for i in 1..500 loop
   select array_agg(x order by random()) into shuffled from unnest(p_codenames) x;
   exit when not exists (select 1 from generate_subscripts(p_codenames,1) k where lower(p_codenames[k])=lower(shuffled[k]));
 end loop;
 if exists (select 1 from generate_subscripts(p_codenames,1) k where lower(p_codenames[k])=lower(shuffled[k])) then raise exception 'Could not create a valid draw'; end if;
 delete from public.participants;
 insert into public.participants(codename,recipient_codename)
 select p_codenames[k],shuffled[k] from generate_subscripts(p_codenames,1) k;
end $$;
create or replace function public.reveal_for_codename(p_codename text)
returns table(recipient_codename text) language plpgsql security definer set search_path=public as $$
begin
 return query update public.participants p set drawn_at=coalesce(p.drawn_at,now())
 where lower(p.codename)=lower(trim(p_codename))
 returning p.recipient_codename;
end $$;
revoke all on function public.admin_set_participants(text[]) from public, anon, authenticated;
revoke all on function public.reveal_for_codename(text) from public, anon, authenticated;
grant execute on function public.admin_set_participants(text[]) to service_role;
grant execute on function public.reveal_for_codename(text) to service_role;
