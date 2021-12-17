
WORKDIR ?= $(shell pwd)

IMAGE ?= ghcr.io/tangx/blog:latest

run:
	hugo serve

build:
	hugo --gc --minify --cleanDestinationDir --baseURL=https://tangx.in/
	touch public/.nojekyll

docker: build
	docker build -t $(IMAGE) . && docker push $(IMAGE)

clean:
	docker rmi `docker images -f "dangling=true" -q`
