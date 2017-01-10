#!/bin/bash

set -e

[ $(uname) == "Darwin" ] && command -v docker-machine > /dev/null 2>&1 && {
  docker-machine ssh $(docker-machine active) "sudo udhcpc SIGUSR1 && sudo /etc/init.d/docker restart"
}

docker build -t jancajthaml/mongo .
docker run --privileged jancajthaml/mongo /bin/true