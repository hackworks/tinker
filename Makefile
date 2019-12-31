# Build a linux docker image

USER := $(shell whoami)
HOME := $(shell realpath ~)

all: refresh build

refresh:
	@if [ -f linux.latest ] ; then find linux.latest -mtime +7 -exec rm -f {} + ; fi

build: linux.latest

linux.latest: SOURCE=$(word 2, $(shell grep -m 1 -E "^FROM" Dockerfile))
linux.latest: bashrc Makefile Dockerfile
	@echo Building linux based on ${SOURCE}
	@docker pull ${SOURCE}
	@docker build -q --build-arg HOME=${HOME} --build-arg USER=${USER} --tag=linux:latest --rm .
	@touch linux.latest

run: linux.latest
	# This is how I invoke it through an alias
	@docker run --rm --cap-add SYS_PTRACE --cap-add SYS_ADMIN -v ${HOME}:${HOME} --hostname=tinker -it linux

clean: IMAGE=$(shell docker images -f "reference=linux:latest" --format={{.ID}})
clean:
	@if [ -n "${IMAGE}" ] ; then docker image rm -f ${IMAGE}; fi
	@rm -f linux.latest

.PHONY:
	clean refresh
