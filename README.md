# Situation Room

Situation Room is a self-hosted website "status checker" much along the lines of
[pingdom.com][1] or similar services. Initially, the Situation Room will support
simple uptime status checks, but the ability to add in additional statu type
checks like load times, page load sizes, etc... will be added.


## Requirements

* [go][4] - 1.13 or newer

### Optional

* [sqlite][5]
* [postgresql][7] - not yet supported
* [mysql][6] - not yet supported
* [redis][3] - not yet supported


## Development

Copy the `.env.sample` file to `.env` and set the sample enviroment variables to
your preferred settings.

Situation Room now uses [go modules](https://github.com/golang/go/wiki/Modules) for
dependency management via the `go.mod` and `go.sum` files.

First install all the app dependencies:

```bash
$ go get ./...
```

In the future, when adding new dependencies, you can just add your `require`
statements to any `*.go` source file, and go modules will install the required
dependency the next time a build command is run.

If you want to use [gin][2] for app live-reloading while you develop, you can
use the following.

```bash
$ go get github.com/codegangsta/gin
$ PORT=8888 make gin
```

This will start the server on port 8989 and auto-restart the app when any Go
sourcefile changes. Make sure your `.env` file sets the `PORT=8989` to match.

If you don't want to use gin you can do the usual:

```bash
$ make
$ ./build/situation-room
```

You will need to rebuild and restart the app manually when you make code changes
with this method.


[1]: https://www.pingdom.com/
[2]: https://github.com/codegangsta/gin
[3]: http://redis.io/
[4]: http://golang.org/
[5]: https://sqlite.org/
[6]: https://www.mysql.com/
[7]: http://www.postgresql.org/
