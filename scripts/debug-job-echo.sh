#!/bin/bash

curl -X 'POST' \
  'http://localhost:8090/api/v3/jobs' \
  -H 'accept: application/json' \
  -H 'Content-Type: application/json' \
  -d '{
  "metadata": {
    "project": "Debugging Flamenco",
    "user.name": "ViktorasM",
    "duration": "long"
  },
  "name": "Talk & Sleep longer",
  "priority": 3,
  "settings": {
    "sleep_duration_seconds": 20,
    "sleep_repeats": 1,
    "message": "Blender is {blender}"
  },
  "type": "echo-sleep-test",
  "submitter_platform": "manager"
}'
