
REQUIRED_STRUCTURE=src/github.com/MQLLAB/MUKLA
TEST?=$$(go list ./... | grep -v /vendor/)
DEPS = $(shell go list -f '{{range .TestImports}}{{.}} {{end}}' ./...)
VETARGS=-asmdecl -atomic -bool -buildtags -copylocks -methods \
				-nilfunc -printf -rangeloops -shift -structtags -unsafeptr

VERSION=$(shell date +"%Y%d%m-%H%M%S")

all: clean version build cover

version:
		echo "${VERSION}" > VERSION

verify:
		echo "Verifying path of project conforms to expected setup and includes ${REQUIRED_STRUCTURE}"
		test -d $(GOPATH)/${REQUIRED_STRUCTURE}

fmt: verify
		mkdir -p tmp
		go fmt .

vet: fmt
		go tool vet ${VETARGS} $$(ls -d */ | grep -v vendor)

test: fmt
		go test -v -timeout=30s -parallel=4 $(TEST)

cover:
		contrib/coverage.sh

build: test vet
		GOOS=darwin GOARCH=amd64 go build -ldflags "-X main.version=$(cat VERSION) -s -w" -o bin/mukla-darwin-amd64-$(cat VERSION) main.go
		GOOS=linux GOARCH=amd64 go build -ldflags "-X main.version=$(cat VERSION) -s -w" -o bin/mukla-linux-amd64-$(cat VERSION) main.go
		GOOS=windows GOARCH=amd64 go build -ldflags "-X main.version=$(cat VERSION) -s -w" -o bin/mukla-windows-amd64-$(cat VERSION).exe main.go
		rm -rf tmp

clean:
		rm -rf bin
		rm -rf tmp
		rm -f coverage.txt
		rm -f VERSION

.PHONY: all deps vet test cover build fmt clean
