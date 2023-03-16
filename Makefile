VERSION=1.5.1
DOCKER_USERNAME ?=darron
DOCKER_PASSWORD ?=yeah-sure
AMD_IMAGE_NAME=$(DOCKER_USERNAME)/spanner-emulator-amd64
ARM_IMAGE_NAME=$(DOCKER_USERNAME)/spanner-emulator-arm64
FINAL_IMAGE_NAME=$(DOCKER_USERNAME)/spanner-emulator-multiarch


all: buildx

.PHONY: buildx
buildx:
	docker buildx build . --platform linux/amd64 -t ${AMD_IMAGE_NAME}:${VERSION}-amd64 --push
	docker buildx build . --platform linux/arm64 -t ${ARM_IMAGE_NAME}:${VERSION}-arm64 -f Dockerfile.arm64 --push

.PHONY: manifest
manifest:
	manifest-tool \
		push from-spec manifest.yaml \
		--username ${DOCKER_USERNAME} \
		--password ${DOCKER_PASSWORD}

.PHONY: inspect-remote
inspect-remote:
	docker buildx imagetools inspect ${ARM_IMAGE_NAME}:${VERSION}-arm64
	docker buildx imagetools inspect ${AMD_IMAGE_NAME}:${VERSION}-amd64

.PHONY: pull-inspect
pull-inspect:
	docker pull ${FINAL_IMAGE_NAME}:${VERSION}
	docker image inspect ${FINAL_IMAGE_NAME}:${VERSION} -f "{{ .Architecture }}"

# Stuff I read to make this happen:
# 
# https://github.com/GoogleCloudPlatform/cloud-spanner-emulator
#
# Adusted from this to use buildx:
# https://www.docker.com/blog/multi-arch-build-and-images-the-simple-way/
# https://www.docker.com/blog/how-to-rapidly-build-multi-architecture-images-with-buildx/
#
# https://dev.to/aws-builders/using-docker-manifest-to-create-multi-arch-images-on-aws-graviton-processors-1320
#
# buildx inspect:
# https://www.thorsten-hans.com/how-to-build-multi-arch-docker-images-with-ease/
#
# Final working manifest:
# https://github.com/OpenLiberty/ci.docker/blob/main/docs/multi-arch-images.md
# https://github.com/estesp/manifest-tool
# Build from: https://github.com/estesp/manifest-tool/pull/218