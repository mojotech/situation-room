build: *.go
	go build -o build/situation-room

gin:
	@gin -i -a 4567 -p 8989
