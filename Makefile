# Setup name variables for the package/tool
NAME := ergaleia
REPO := codem8s/ergaleia

VERSION := $(shell cat VERSION)
KUBERNETES_VERSION := $(shell curl -s https://storage.googleapis.com/kubernetes-release/release/stable.txt)
GITCOMMIT := $(shell git rev-parse --short HEAD)
GITUNTRACKEDCHANGES := $(shell git status --porcelain --untracked-files=no)
ifneq ($(GITUNTRACKEDCHANGES),)
	GITCOMMIT := $(GITCOMMIT)-dirty
endif

ifdef TRAVIS
	BUILD_TAG := "travis-$(TRAVIS_BUILD_NUMBER)-$(TRAVIS_BRANCH)-$(GITCOMMIT)-k8s$(KUBERNETES_VERSION)"  
	ifneq ($(TRAVIS_TAG),)
		LATEST_TAG := "latest"
		VERSION_TAG := "$(VERSION)"
  else
		LATEST_TAG := "$(GITCOMMIT)-k8s$(KUBERNETES_VERSION)"
		VERSION_TAG := "$(VERSION)-$(GITCOMMIT)-k8s$(KUBERNETES_VERSION)"    
	endif
else
	BUILD_TAG := "local-$(GITCOMMIT)-k8s$(KUBERNETES_VERSION)"
	LATEST_TAG := "local-latest-k8s$(KUBERNETES_VERSION)"
	VERSION_TAG := "local-$(VERSION)-k8s$(KUBERNETES_VERSION)"
endif

.DEFAULT_GOAL := help

.PHONY: all
all: docker-build docker-push ## Runs a docker-build, docker-push

.PHONY: docker-build
docker-build: ## Build the container
	@echo "+ $@"
	@echo "  REPO=$(REPO)"
	@echo "  VERSION=$(VERSION)"
	@echo "  GITCOMMIT=$(GITCOMMIT)"
	@echo "  VERSION_TAG=$(VERSION_TAG)"
	@echo "  BUILD_TAG=$(BUILD_TAG)"
	@echo "  LATEST_TAG=$(LATEST_TAG)"
	@docker build -t $(REPO):$(GITCOMMIT) .
	@docker tag $(REPO):$(GITCOMMIT) quay.io/$(REPO):$(VERSION_TAG)
	@docker tag $(REPO):$(GITCOMMIT) quay.io/$(REPO):$(BUILD_TAG)
	@docker tag $(REPO):$(GITCOMMIT) quay.io/$(REPO):$(LATEST_TAG)

.PHONY: docker-push
docker-push: ## Push the container
	@echo "+ $@"
	@docker login -u="${QUAY_USER}" -p="${QUAY_PASS}" quay.io
	@docker push quay.io/$(GITCOMMIT):$(VERSION_TAG)
	@docker push quay.io/$(GITCOMMIT):$(BUILD_TAG)
	@docker push quay.io/$(GITCOMMIT):$(LATEST_TAG)

.PHONY: bump-version
BUMP := patch
bump-version: ## Bump the version in the version file. Set BUMP to [ patch | major | minor ]
	@go get -u github.com/jessfraz/junk/sembump # update sembump tool
	$(eval NEW_VERSION=$(shell sembump --kind $(BUMP) $(VERSION)))
	@echo "Bumping VERSION from $(VERSION) to $(NEW_VERSION)"
	echo $(NEW_VERSION) > VERSION
	@echo "Updating links to download binaries in README.md"
	sed -i s/$(VERSION)/$(NEW_VERSION)/g README.md
	git add VERSION README.md
	git commit -vsam "Bump version to $(NEW_VERSION)"
	@echo "Run make tag to create and push the tag for new version $(NEW_VERSION)"

.PHONY: tag
tag: ## Create a new git tag to prepare to build a release
	git tag -sa $(VERSION) -m "$(VERSION)"
	@echo "Run git push origin $(VERSION) to push your new tag to GitHub and trigger a travis build."

.PHONY: help
help:
	@grep -E '^[a-zA-Z_-]+:.*?## .*$$' $(MAKEFILE_LIST) | sort | awk 'BEGIN {FS = ":.*?## "}; {printf "\033[36m%-30s\033[0m %s\n", $$1, $$2}'

.PHONY: status
status: ## Shows git and dep status
	@echo "Changed files:"
	@git status --porcelain
	@echo
	@echo "Ignored but tracked files:"
	@git ls-files -i --exclude-standard
	@echo