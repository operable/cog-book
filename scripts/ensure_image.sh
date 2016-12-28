#!/bin/bash

image=operable/cog-book-toolchain:sphinx

docker inspect ${image} >& /dev/null
if [ $? -gt 0 ]; then
  echo "Retrieving ${image} from Docker Hub. Please wait..."
  docker pull ${image}
else
  echo "Found local instance of ${image}. Continuing build..."
fi
