NAME=aliddns
BASE_BUILDDIR=build
BUILDNAME=$(GOOS)-$(GOARCH)$(GOAMD64)$(GOARM)
BUILDDIR=$(BASE_BUILDDIR)/$(BUILDNAME)
VERSION?=dev
UPX?=upx
ENABLE_UPX?=false

ifeq ($(GOOS),windows)
  ext=.exe
  archiveCmd=zip -9 -r $(NAME)-$(BUILDNAME)-$(VERSION).zip $(BUILDNAME)
else
  ext=
  archiveCmd=tar czpvf $(NAME)-$(BUILDNAME)-$(VERSION).tar.gz $(BUILDNAME)
endif

.PHONY: default
default: build

build: clean test
	go build -mod=vendor

release: check-env-release
	mkdir -p $(BUILDDIR)
	cp LICENSE $(BUILDDIR)/
	cp README.md $(BUILDDIR)/
	CGO_ENABLED=0 GOOS=$(GOOS) GOARCH=$(GOARCH) go build -mod=vendor -ldflags "-s -w -X main.VersionString=$(VERSION)" -o $(BUILDDIR)/$(NAME)$(ext)
	if [ "$(ENABLE_UPX)" = "true" ] && [ -x "$(UPX)" ] && [ "$(GOOS)" != "darwin" ]; then \
		echo "UPX压缩前:" && ls -lh $(BUILDDIR)/$(NAME)$(ext) ; \
		$(UPX) --best --lzma $(BUILDDIR)/$(NAME)$(ext) ; \
		echo "UPX压缩后:" && ls -lh $(BUILDDIR)/$(NAME)$(ext) ; \
	fi
	cd $(BASE_BUILDDIR) ; $(archiveCmd)

test:
	go test -race -v -bench=. ./...

clean:
	go clean
	rm -rf $(BASE_BUILDDIR)

check-env-release:
	@ if [ "$(GOOS)" = "" ]; then \
		echo "Environment variable GOOS not set"; \
		exit 1; \
	fi
	@ if [ "$(GOARCH)" = "" ]; then \
		echo "Environment variable GOOS not set"; \
		exit 1; \
	fi
