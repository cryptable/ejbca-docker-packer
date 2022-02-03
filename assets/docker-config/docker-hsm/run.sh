#!/bin/bash

docker run --rm -v hsm:/hsm -d --name utimacohsm -p 3001:3001 utimacohsm
