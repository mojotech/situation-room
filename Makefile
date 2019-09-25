.PHONY: gin deps test parcel

build: *.go
	go build -o build/situation-room

gin:
	@gin -i -a 4567 -p 8989

parcel:
	@cd client && yarn run parcel index.html

deps:
	@cd client && npm i
	@go get ./...

test: deps
	@cd client && npm test
	@go test ./...
