# Set POSIX sh for maximum interoperability
SHELL := /bin/sh

# Set an output prefix, which is the local directory if not specified
PREFIX?=$(shell pwd)

# Setup variables for the Makefile
NAME=ergaleia
REPO=virtuslab/ergaleia
DOCKER_REGISTRY=quay.io

VERSION := $(shell cat VERSION.txt)
GITCOMMIT := $(shell git rev-parse --short HEAD)
GITBRANCH := $(shell git rev-parse --abbrev-ref HEAD)
GITUNTRACKEDCHANGES := $(shell git status --porcelain --untracked-files=no)
GITIGNOREDBUTTRACKEDCHANGES := $(shell git ls-files -i --exclude-standard)
ifneq ($(GITUNTRACKEDCHANGES),)
    GITCOMMIT := $(GITCOMMIT)-dirty
endif
ifneq ($(GITIGNOREDBUTTRACKEDCHANGES),)
    GITCOMMIT := $(GITCOMMIT)-dirty
endif

KUBERNETES_VERSION ?= latest
LATEST_KUBERNETES_VERSION := $(shell curl -s https://storage.googleapis.com/kubernetes-release/release/latest.txt)
STABLE_KUBERNETES_VERSION := $(shell curl -s https://storage.googleapis.com/kubernetes-release/release/stable.txt)

DETAILED_TAG := $(GITCOMMIT)-$(KUBERNETES_VERSION)
VERSION_TAG := $(GITCOMMIT)-$(KUBERNETES_VERSION)
LATEST_TAG := $(GITCOMMIT)-$(KUBERNETES_VERSION)

ifeq ($(KUBERNETES_VERSION),stable)
	override KUBERNETES_VERSION := $(STABLE_KUBERNETES_VERSION)
endif

ifeq ($(KUBERNETES_VERSION),latest)
	override KUBERNETES_VERSION := $(LATEST_KUBERNETES_VERSION)
endif

ifneq ($(TRAVIS_TAG),)
	override DETAILED_TAG := $(TRAVIS_TAG)-$(GITCOMMIT)-$(KUBERNETES_VERSION)
	override VERSION_TAG := $(TRAVIS_TAG)-$(KUBERNETES_VERSION)
	override LATEST_TAG := old
	ifeq ($(KUBERNETES_VERSION),$(STABLE_KUBERNETES_VERSION))
		override VERSION_TAG := $(TRAVIS_TAG)
		override LATEST_TAG := stable
	endif
	ifeq ($(KUBERNETES_VERSION),$(LATEST_KUBERNETES_VERSION))
		override LATEST_TAG := edge
	endif
endif

.DEFAULT_GOAL := help

.PHONY: all
all: docker-build docker-images docker-push ## Runs a docker-build, docker-images, docker-push
	@echo "+ $@"

.PHONY: check-env
check-env: ## Checks the environment variables
	@echo "+ $@"
ifndef KUBERNETES_VERSION
	$(error KUBERNETES_VERSION is undefined)
endif
	@echo "KUBERNETES_VERSION: $(KUBERNETES_VERSION)"
	@echo "DETAILED_TAG: $(DETAILED_TAG)"
	@echo "VERSION_TAG: $(VERSION_TAG)"
	@echo "LATEST_TAG: $(LATEST_TAG)"
	@echo "TRAVIS_TAG: $(TRAVIS_TAG)"

.PHONY: docker-build
docker-build: check-env ## Build the container
	@echo "+ $@"
	@docker build --build-arg KUBERNETES_VERSION=$(KUBERNETES_VERSION) -t $(REPO):$(GITCOMMIT) .

.PHONY: docker-login
docker-login: ## Log in into the repository
	@echo "+ $@"
	@docker login -u="${DOCKER_USER}" -p="${DOCKER_PASS}" $(DOCKER_REGISTRY)

.PHONY: docker-images
docker-images: ## List all local containers
	@echo "+ $@"
	@docker images

.PHONY: docker-push
docker-push: docker-login ## Push the container
	@echo "+ $@"
	@docker tag $(REPO):$(GITCOMMIT) $(DOCKER_REGISTRY)/$(REPO):$(DETAILED_TAG)
	@docker tag $(REPO):$(GITCOMMIT) $(DOCKER_REGISTRY)/$(REPO):$(VERSION_TAG)
	@docker tag $(REPO):$(GITCOMMIT) $(DOCKER_REGISTRY)/$(REPO):$(LATEST_TAG)
	@docker push $(DOCKER_REGISTRY)/$(REPO):$(DETAILED_TAG)
	@docker push $(DOCKER_REGISTRY)/$(REPO):$(VERSION_TAG)
	@docker push $(DOCKER_REGISTRY)/$(REPO):$(LATEST_TAG)

.PHONY: docker-run
docker-run: docker-build ## Build and run the container
	@echo "+ $@"
	docker run -i -t --privileged \
          -v /var/run/docker.sock:/host/var/run/docker.sock \
          -v /dev:/host/dev -v /proc:/host/proc:ro \
          -v /boot:/host/boot:ro \
          -v /lib/modules:/host/lib/modules:ro \
          -v /usr:/host/usr:ro $(REPO):$(GITCOMMIT)

.PHONY: bump-version
BUMP := patch
bump-version: ## Bump the version in the version file. Set BUMP to [ patch | major | minor ]
	@echo "+ $@"
	go get -u github.com/jessfraz/junk/sembump # update sembump tool
	$(eval NEW_VERSION=$(shell sembump --kind $(BUMP) $(VERSION)))
	@echo "Bumping VERSION.txt from $(VERSION) to $(NEW_VERSION)"
	echo $(NEW_VERSION) > VERSION.txt
	@echo "Updating version from $(VERSION) to $(NEW_VERSION) in README.md"
	sed -i s/$(VERSION)/$(NEW_VERSION)/g README.md
	@echo "Updating version from $(VERSION) to $(NEW_VERSION) in kubernetes/ergaleia.yaml"
	sed -i s/$(VERSION)/$(NEW_VERSION)/g kubernetes/ergaleia.yaml
	git add VERSION.txt README.md kubernetes/ergaleia.yaml
	git commit -vseam "Bump version to $(NEW_VERSION)"
	@echo "Run make tag to create and push the tag for new version $(NEW_VERSION)"

.PHONY: tag
tag: ## Create a new git tag to prepare to build a release
	@echo "+ $@"
	git tag -a $(VERSION) -m "$(VERSION)"
	git push origin $(VERSION)

.PHONY: help
help:
	@grep -Eh '^[a-zA-Z_-]+:.*?## .*$$' $(MAKEFILE_LIST) | sort | awk 'BEGIN {FS = ":.*?## "}; {printf "\033[36m%-30s\033[0m %s\n", $$1, $$2}'

.PHONY: status
status: ## Shows git and dep status
	@echo "+ $@"
	@echo "Commit: $(GITCOMMIT), VERSION: $(VERSION)"
	@echo
ifneq ($(GITUNTRACKEDCHANGES),)
	@echo "Changed files:"
	@git status --porcelain --untracked-files=no
	@echo
endif
ifneq ($(GITIGNOREDBUTTRACKEDCHANGES),)
	@echo "Ignored but tracked files:"
	@git ls-files -i --exclude-standard
	@echo
endif
