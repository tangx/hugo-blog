
WORKDIR ?= $(shell pwd)

run: 
	docker run -v $(WORKDIR):/srv/jekyll --rm -it -p 4000:4000 jekyll/jekyll jekyll serve

builder.build:
	docker run -v $(WORKDIR):/srv/jekyll --rm -it jekyll/builder jekyll build

jekyll.build:
	docker run -v $(WORKDIR):/srv/jekyll --rm -it jekyll/jekyll jekyll build

# npm install -g sass
main.css:
	sass scss/main.scss main.css


docker:
	docker build -t ghcr.io/tangx/blog:latest .

clean:
	docker rmi `docker images -f "dangling=true" -q`