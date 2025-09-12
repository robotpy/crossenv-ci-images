UBUNTU?=24.04
PYVERSION=py313

usage:
	@echo "Run make update, make build, and make push"

.PHONY: update
update:
	docker pull docker.io/ubuntu:${UBUNTU}

#
# Build
#

.PHONY: build/base
build/base:
	docker build . \
		-t ghcr.io/robotpy/crossenv-ci-images:base-${UBUNTU} \
		-f Dockerfile.${UBUNTU}

.PHONY: build/cross-arm64
build/cross-arm64:
	docker build . \
		-t ghcr.io/robotpy/crossenv-ci-images:cross-arm64-${UBUNTU} \
		--build-arg UBUNTU=${UBUNTU} \
		-f Dockerfile.cross-arm64



.PHONY: build/cross-arm64-python
build/cross-arm64-python:
	docker build . \
		-t ghcr.io/robotpy/crossenv-ci-images:${PYVERSION}-arm64-${UBUNTU} \
		--build-arg UBUNTU=$(UBUNTU) \
		--build-arg ARCH=arm64 \
		--build-arg TARGET_HOST=aarch64-ubuntu-linux-gnu \
		--build-arg AC_TARGET_HOST=aarch64-ubuntu-linux-gnu \
		-f Dockerfile.${PYVERSION}

.PHONY: build/cross-arm64-python-qemu
build/cross-arm64-python-qemu:
	docker build . \
		-t ghcr.io/robotpy/crossenv-ci-images:${PYVERSION}-arm64-${UBUNTU}-qemu \
		--build-arg BASE_IMAGE=ghcr.io/robotpy/crossenv-ci-images:${PYVERSION}-arm64-${UBUNTU} \
		-f Dockerfile.qemu-arm64

.PHONY: build
build: build/base build/cross-arm64 build/cross-arm64-python build/cross-arm64-python-qemu

#
# Push
#

.PHONY: push/base
push/base:
	docker push ghcr.io/robotpy/crossenv-ci-images:base-${UBUNTU}

.PHONY: push/cross-arm64
push/cross-arm64:
	docker push ghcr.io/robotpy/crossenv-ci-images:cross-arm64-${UBUNTU}


.PHONY: push/cross-arm64-python
push/cross-arm64-python:
	docker push ghcr.io/robotpy/crossenv-ci-images:${PYVERSION}-arm64-${UBUNTU}

.PHONY: push/cross-arm64-python-qemu
push/cross-arm64-python-qemu:
	docker push ghcr.io/robotpy/crossenv-ci-images:${PYVERSION}-arm64-${UBUNTU}-qemu


.PHONY: push
push: push/base push/cross-arm64 push/cross-arm64-python push/cross-arm64-python-qemu

#
# Save
#

.PHONY: save/base
save/minimal:
	docker save ghcr.io/robotpy/crossenv-ci-images:base-${UBUNTU} | zstd > base.tar.zst
	docker save ghcr.io/robotpy/crossenv-ci-images:cross-arm64-${UBUNTU} | zstd > cross-arm64.tar.zst
