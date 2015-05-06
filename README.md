# Situation Room

Situation Room is a self-hosted website "status checker" much along the lines of
[pingdom.com][1] or similar services. Initially, the Situation Room will support
simple uptime status checks, but the ability to add in additional statu type
checks like load times, page load sizes, etc... will be added.


## Development

Copy the `.env.sample` file to `.env` and set the sample enviroment variables to
your preferred settings.

```bash
$ go run main.go
```


[1]: https://www.pingdom.com/
