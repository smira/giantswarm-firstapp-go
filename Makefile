PROJECT=currentweather
ORGANIZATION=giantswarm

SOURCE := $(shell find . -name '*.go')
VERSION := $(shell cat VERSION)
GOPATH := $(shell pwd)/.gobuild
PROJECT_PATH := $(GOPATH)/src/github.com/$(ORGANIZATION)
RELEASE_PATH := $(shell pwd)/release

.PHONY=all clean test deps bin

all: deps $(PROJECT)

clean:
	rm -rf $(GOPATH) $(PROJECT) simple

test:
	GOPATH=$(GOPATH) go test ./...

# deps
deps: .gobuild
.gobuild:
	mkdir -p $(PROJECT_PATH)
	cd $(PROJECT_PATH) && ln -s ../../../.. $(PROJECT)

	# Fetch private packages first (so `go get` skips them later)
	# git clone git@git.giantswarm.io:giantswarm/eventstream.git $(PROJECT_PATH)/eventstream

	#
	# Fetch public packages
	GOPATH=$(GOPATH) go get -d github.com/$(ORGANIZATION)/$(PROJECT)

	#
	# Fetch test packages
	GOPATH=$(GOPATH) go get -d github.com/onsi/gomega
	GOPATH=$(GOPATH) go get -d github.com/onsi/ginkgo

# build
$(PROJECT): $(SOURCE) VERSION
	GOPATH=$(GOPATH) go build -ldflags "-X main.projectVersion $(VERSION)" -o $(PROJECT)

install: $(PROJECT)
	cp $(PROJECT) /usr/local/bin/

$(BIN): VERSION $(SOURCE) 
	echo Building for $(GOOS)/$(GOARCH)
	docker run \
	    --rm \
	    -it \
	    -v $(shell pwd):/usr/code \
	    -e GOPATH=/usr/code/.gobuild \
	    -e GOOS=$(GOOS) \
	    -e GOARCH=$(GOARCH) \
	    -w /usr/code \
	    golang:1.3.1-cross \
	    go build -a -ldflags "-X main.projectVersion $(VERSION) -X main.projectBuild $(COMMIT)" -o $(BIN)

$(RELEASE_PATH):
	mkdir $(RELEASE_PATH)

crosscompile: deps $(RELEASE_PATH) $(SOURCE)
	./crosscompile.sh $(RELEASE_PATH)

up: $(PROJECT)
	fig up