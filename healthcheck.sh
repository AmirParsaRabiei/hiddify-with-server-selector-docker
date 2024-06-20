#!/bin/sh

status=$(curl -s -o /dev/null -w "%{http_code}" http://localhost:6756)
if [ "$status" -eq 200 ] || [ "$status" -eq 401 ]; then
  exit 0
else
  exit 1
fi
