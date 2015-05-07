build: *.go
	go build -o build/situation-room

gin:
	@gin -a 4567 -p 8989
