# Situation Room

Situation Room is a self-hosted website "status checker" much along the lines of
[pingdom.com][1] or similar services. Initially, the Situation Room will support
simple uptime status checks, but the ability to add in additional statu type
checks like load times, page load sizes, etc... will be added.

The repo is currently in the process of being converted into elixir.
Updates will soon follow.
## Requirements

1. [asdf version manager][2]
    - Install the required elixir/erlang versions for this repo with `asdf install <tool> <version>`.
    - See `.tool-versions` for the needed versions of each tool.
    - See the asdf docs for more info.
2. [Docker][3]
    - Needed to run the local postgres db
3. [direnv][4] to manage env variables.
    - This is what a `.envrc` file is generally consumed by.
    - a regular `.env` file will not work with this project

## Setup

1. Make sure that the necessary tools versions are active for this project. You can use [asdf][2] for this if needed.
2. run `cp sample.envrc .envrc`
3. Initialize the postgres database by running: `docker-compose up -d`.
4. Install the dependencies: `mix deps.get`
5. Create the database for migrations: `mix ecto.create`
6. Run the migrations: `mix ecto.migrate`
7. Test everything: `mix test`
8. Start the elixir HTTP server: `mix run --no-halt`


[1]: https://www.pingdom.com/
[2]: https://asdf-vm.com/
[3]: https://docs.docker.com/get-docker/
[4]: https://direnv.net/
[5]: https://sqlite.org/
[6]: https://www.mysql.com/
[7]: http://www.postgresql.org/
