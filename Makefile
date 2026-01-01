.PHONY: build install clean test fmt lint completions dev help

# Build variables
BINARY_NAME=dux
VERSION ?= $(shell git describe --tags --always --dirty 2>/dev/null || echo "dev")
COMMIT ?= $(shell git rev-parse --short HEAD 2>/dev/null || echo "none")
DATE ?= $(shell date -u +"%Y-%m-%dT%H:%M:%SZ")
LDFLAGS=-ldflags "-s -w -X main.version=$(VERSION) -X main.commit=$(COMMIT) -X main.date=$(DATE)"

# Go parameters
GOCMD=go
GOBUILD=$(GOCMD) build
GOTEST=$(GOCMD) test
GOGET=$(GOCMD) get
GOMOD=$(GOCMD) mod
GOFMT=gofmt

# Directories
BUILD_DIR=.
COMPLETIONS_DIR=completions

## help: Show this help message
help:
	@echo "dux - Docker Use Context"
	@echo ""
	@echo "Usage:"
	@echo "  make <target>"
	@echo ""
	@echo "Targets:"
	@grep -E '^## ' $(MAKEFILE_LIST) | sed 's/## /  /'

## build: Build the binary
build:
	@mkdir -p $(BUILD_DIR)
	$(GOBUILD) $(LDFLAGS) -o $(BUILD_DIR)/$(BINARY_NAME) ./cmd/dux

## install: Install to GOPATH/bin
install:
	$(GOBUILD) $(LDFLAGS) -o $(GOPATH)/bin/$(BINARY_NAME) ./cmd/dux

## install-local: Install to ~/.local/bin
install-local: build
	@mkdir -p $(HOME)/.local/bin
	cp $(BUILD_DIR)/$(BINARY_NAME) $(HOME)/.local/bin/

## clean: Remove build artifacts
clean:
	rm -rf $(BUILD_DIR)
	rm -f $(COMPLETIONS_DIR)/dux.bash
	rm -f $(COMPLETIONS_DIR)/dux.zsh
	rm -f $(COMPLETIONS_DIR)/dux.fish

## test: Run tests
test:
	$(GOTEST) -v ./...

## fmt: Format code
fmt:
	$(GOFMT) -s -w .

## lint: Run linter
lint:
	golangci-lint run

## completions: Copy completion files (hand-written, not generated)
completions:
	@echo "Completions are hand-written in completions/ directory"
	@ls -la $(COMPLETIONS_DIR)/

## dev: Build and run
dev: build
	./$(BUILD_DIR)/$(BINARY_NAME)

## tidy: Tidy go modules
tidy:
	$(GOMOD) tidy

## build-all: Build for all platforms
build-all:
	@mkdir -p $(BUILD_DIR)
	GOOS=darwin GOARCH=amd64 $(GOBUILD) $(LDFLAGS) -o $(BUILD_DIR)/$(BINARY_NAME)-darwin-amd64 ./cmd/dux
	GOOS=darwin GOARCH=arm64 $(GOBUILD) $(LDFLAGS) -o $(BUILD_DIR)/$(BINARY_NAME)-darwin-arm64 ./cmd/dux
	GOOS=linux GOARCH=amd64 $(GOBUILD) $(LDFLAGS) -o $(BUILD_DIR)/$(BINARY_NAME)-linux-amd64 ./cmd/dux
	GOOS=linux GOARCH=arm64 $(GOBUILD) $(LDFLAGS) -o $(BUILD_DIR)/$(BINARY_NAME)-linux-arm64 ./cmd/dux

## release-dry: Test goreleaser locally
release-dry:
	goreleaser release --snapshot --clean

## release: Create a new release (requires tag)
release:
	goreleaser release --clean

