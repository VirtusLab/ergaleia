# Import config
# You can change the default config with `make config="config_special.env" build`
config ?= config.env
include $(config)

ifeq ($(KUBERNETES_VERSION),)
	$(error KUBERNETES_VERSION is undefined)
endif

VERSION := $(shell cat VERSION)
GITCOMMIT := $(shell git rev-parse --short HEAD)
GITBRANCH := $(shell git rev-parse --abbrev-ref HEAD)
GITUNTRACKEDCHANGES := $(shell git status --porcelain --untracked-files=no)
ifneq ($(GITUNTRACKEDCHANGES),)
	GITCOMMIT := $(GITCOMMIT)-dirty
endif

LATEST_TAG := "v$(GITCOMMIT)-k8s$(KUBERNETES_VERSION)"
VERSION_TAG := "v$(GITCOMMIT)-k8s$(KUBERNETES_VERSION)"
BUILD_TAG := "$(GITBRANCH)-$(GITCOMMIT)-k8s$(KUBERNETES_VERSION)"

ifdef TRAVIS
	ifneq ($(TRAVIS_TAG),)
		LATEST_TAG := "$(VERSION)-k8s$(KUBERNETES_VERSION)"
		VERSION_TAG := "$(VERSION)-k8s$(KUBERNETES_VERSION)"
	endif
	BUILD_TAG := "travis-$(TRAVIS_BUILD_NUMBER)-$(TRAVIS_BRANCH)-$(GITCOMMIT)-k8s$(KUBERNETES_VERSION)"
endif

ifeq ($(KUBERNETES_VERSION),stable)
	KUBERNETES_VERSION := $(shell curl -s https://storage.googleapis.com/kubernetes-release/release/stable.txt)
	LATEST_TAG := "stable"
	VERSION_TAG := "$(VERSION)"
endif

ifeq ($(KUBERNETES_VERSION),latest)
	KUBERNETES_VERSION := $(shell curl -s https://storage.googleapis.com/kubernetes-release/release/latest.txt)
	LATEST_TAG := "latest"
	VERSION_TAG := "$(VERSION)"
endif

.DEFAULT_GOAL := help

.PHONY: all
all: docker-build docker-images docker-push ## Runs a docker-build, docker-images, docker-push

.PHONY: docker-build
docker-build: ## Build the container
	@echo "+ $@"
	@docker build --build-arg KUBERNETES_VERSION=$(KUBERNETES_VERSION) -t $(REPO):$(GITCOMMIT) .
	@docker tag $(REPO):$(GITCOMMIT) $(DOCKER_REGISTRY)/$(REPO):$(LATEST_TAG)
	@docker tag $(REPO):$(GITCOMMIT) $(DOCKER_REGISTRY)/$(REPO):$(VERSION_TAG)
	@docker tag $(REPO):$(GITCOMMIT) $(DOCKER_REGISTRY)/$(REPO):$(BUILD_TAG)

.PHONY: docker-login
docker-login: ## Log in into the repository
	@echo "+ $@"
	@docker login -u="${QUAY_USER}" -p="${QUAY_PASS}" $(DOCKER_REGISTRY)

.PHONY: docker-images
docker-images: ## List all local containers
	@echo "+ $@"
	@docker images

.PHONY: docker-push
docker-push: docker-login ## Push the container
	@echo "+ $@"
	@docker push $(DOCKER_REGISTRY)/$(REPO):$(LATEST_TAG)
	@docker push $(DOCKER_REGISTRY)/$(REPO):$(VERSION_TAG)
	@docker push $(DOCKER_REGISTRY)/$(REPO):$(BUILD_TAG)

.PHONY: bump-version
BUMP := patch
bump-version: ## Bump the version in the version file. Set BUMP to [ patch | major | minor ]
	@go get -u github.com/jessfraz/junk/sembump # update sembump tool
	$(shell command -v sembump)
	$(eval NEW_VERSION=$(shell sembump --kind $(BUMP) $(VERSION)))
	@echo "Bumping VERSION from $(VERSION) to $(NEW_VERSION)"
	echo $(NEW_VERSION) > VERSION
	@echo "Updating version from $(VERSION) to $(NEW_VERSION) in README.md"
	sed -i s/$(VERSION)/$(NEW_VERSION)/g README.md
	@echo "Updating version from $(VERSION) to $(NEW_VERSION) in kubernetes/ergaleia.yaml"
	sed -i s/$(VERSION)/$(NEW_VERSION)/g kubernetes/ergaleia.yaml
	git add VERSION README.md kubernetes/ergaleia.yaml
	git commit -vsam "Bump version to $(NEW_VERSION)"
	@echo "Run make tag to create and push the tag for new version $(NEW_VERSION)"

.PHONY: tag
tag: ## Create a new git tag to prepare to build a release
	git tag -sa $(VERSION) -m "$(VERSION)"
	@echo "Run git push origin $(VERSION) to push your new tag to GitHub and trigger a travis build."

.PHONY: help
help:
	@grep -Eh '^[a-zA-Z_-]+:.*?## .*$$' $(MAKEFILE_LIST) | sort | awk 'BEGIN {FS = ":.*?## "}; {printf "\033[36m%-30s\033[0m %s\n", $$1, $$2}'

.PHONY: status
status: ## Shows git and dep status
	@echo "Changed files:"
	@git status --porcelain
	@echo
	@echo "Ignored but tracked files:"
	@git ls-files -i --exclude-standard
	@echo
