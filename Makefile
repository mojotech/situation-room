.PHONY: gin deps test clean all run

PORT=4567
BUILD_DIR=build
BINARY_NAME=situation-room
GOOS=$(shell go env GOOS)
GOARCH=$(shell go env GOARCH)

build: *.go
	mkdir -p $(BUILD_DIR)
	GORARCH=amd64 GOOS=darwin go build -o $(BUILD_DIR)/$(BINARY_NAME)-darwin-amd64
	GORARCH=amd64 GOOS=linux go build -o $(BUILD_DIR)/$(BINARY_NAME)-linux-amd64
	GORARCH=amd64 GOOS=windows go build -o $(BUILD_DIR)/$(BINARY_NAME)-windows-amd64
	GORARCH=arm64 GOOS=darwin go build -o $(BUILD_DIR)/$(BINARY_NAME)-darwin-arm64
	GORARCH=arm64 GOOS=linux go build -o $(BUILD_DIR)/$(BINARY_NAME)-linux-arm64
	GORARCH=arm64 GOOS=windows go build -o $(BUILD_DIR)/$(BINARY_NAME)-windows-arm64

run:
	./$(BUILD_DIR)/$(BINARY_NAME)-$(GOOS)-$(GOARCH)

gin:
	@gin -i -a $(PORT) -p 8989

deps:
	@cd client && npm i
	@go get ./...

test: deps
	@cd client && npm test
	@go test ./...

clean:
	go clean
	rm -rf $(BUILD_DIR)

all: clean build
