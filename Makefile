.PHONY: gin deps test

PORT=4567

build: *.go
	go build -o build/situation-room

gin:
	@gin -i -a ${PORT} -p 8989

deps:
	@cd client && npm i
	@go get ./...

test: deps
	@cd client && npm test
	@go test ./...
