NAME = jancajthaml/mongo
VERSION = latest
CORES := $$(getconf _NPROCESSORS_ONLN)

.PHONY: all clean

all: clean

clean:
	docker images | grep -i "^<none>" | awk '{ print $$3 }' | xargs -P$(CORES) -I{} docker rmi -f {}
	docker ps -a | grep Exit | cut -d ' ' -f 1 | xargs -P$(CORES) -I{} docker rm -f {}
	zombies=$$(docker volume ls -qf dangling=true)
	[ $$($$zombies | wc -l) -gt 0 ] && docker volume rm $$zombies || true