-- up
create table sites (
  id integer primary key,
  url text not null,
  email text,
  status text,
  duration real,
  created_at integer not null default(strftime('%s', 'now')),
  updated_at integer
)

-- down
drop table sites
