AUTHOR=mpeterson
NAME=php5_fpm
VERSION=0.1

.PHONY: all build tag_latest

all: build tag_latest

build:
	docker build -t $(AUTHOR)/$(NAME):$(VERSION) --rm image

tag_latest:
	docker tag $(AUTHOR)/$(NAME):$(VERSION) $(AUTHOR)/$(NAME):latest
