# Situation Room

Situation Room is a self-hosted website "status checker" much along the lines of
[pingdom.com][1] or similar services. Initially, the Situation Room will support
simple uptime status checks, but the ability to add in additional statu type
checks like load times, page load sizes, etc... will be added.

The repo is currently in the process of being converted into elixir.
Updates will soon follow.
## Requirements

This will be populated as the elixir features are built out.

## Getting things Running:
1. create `.envrc` and copy contents from `.sample.envrc`
2. run `mix deps.get`
3. run `docker-compose up -d`
4. run `mix Ecto.create`
5. run `mix Ecto.migrate`
6. to make sure everything is working, run `mix test`
7. In one terminal, run `mix run --no-halt`
8. In another terminal, `cd client` and `yarn run dev`


[1]: https://www.pingdom.com/
[5]: https://sqlite.org/
[6]: https://www.mysql.com/
[7]: http://www.postgresql.org/
