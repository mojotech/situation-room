-- up
create table checks (
  id integer primary key,
  url text not null,
  response interger,
  response_time integer,
  site_id integer,
  created_at integer not null default(strftime('%s', 'now')),
  FOREIGN KEY(site_id) REFERENCES sites(id)
)

-- down
drop table checks
