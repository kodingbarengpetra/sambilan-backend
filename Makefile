.PHONY: all clean

all: dist/app

PLATFORMS := darwin/arm64 linux/amd64

dist/app: $(PLATFORMS)

$(PLATFORMS): app/api/main.go
	GOOS=$(word 1,$(subst /, ,$@)) GOARCH=$(word 2,$(subst /, ,$@)) go build -o dist/app-$(subst /,-,$@) app/api/main.go
	
clean:
	rm -rf dist/app