PROJECT=currentweather
ORGANIZATION=giantswarm

SOURCE := $(shell find . -name '*.go')
GOPATH := $(shell pwd)/.gobuild
PROJECT_PATH := $(GOPATH)/src/github.com/$(ORGANIZATION)
GOOS := linux
GOARCH := amd64

.PHONY=all clean deps $(PROJECT) up

all: deps $(PROJECT)

clean:
	rm -rf $(GOPATH) $(PROJECT)

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

$(PROJECT): $(SOURCE) 
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
	    go build -a -o $(PROJECT)

up: $(PROJECT)
	fig build
	fig up