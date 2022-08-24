CREATE TABLE schema_migrations (version text primary key)
CREATE TABLE sites (
  id integer primary key,
  url text not null,
  email text,
  status text,
  duration real,
  created_at integer not null default(strftime('%s', 'now')),
  updated_at integer
)
CREATE TABLE checks (
  id integer primary key,
  url text not null,
  response interger,
  response_time integer,
  site_id integer,
  created_at integer not null default(strftime('%s', 'now')),
  FOREIGN KEY(site_id) REFERENCES sites(id)
)