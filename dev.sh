#!/bin/bash

docker-compose up -d

docker-compose exec valkyrie /bin/bash

docker-compose down
