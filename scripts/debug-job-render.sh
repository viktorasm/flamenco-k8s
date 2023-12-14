#!/bin/bash

curl -v -X 'POST' \
  'http://localhost:8080/api/v3/jobs' \
  -H 'accept: application/json' \
  -H 'Content-Type: application/json' \
  -d '{
  "metadata": {
    "project": "Debugging Flamenco",
    "user.name": "Viktoras"
  },
  "name": "Test Render",
  "type": "simple-blender-render",
  "settings": {
    "add_path_components": 0,
    "blender_cmd": "{blender}",
    "blendfile": "/assets/cube.blend",
    "chunk_size": 3,
    "format": "PNG",
    "fps": 24,
    "frames": "1-60",
    "image_file_extension": ".png",
    "images_or_video": "images",
    "render_output_path": "/tmp/flamenco/Demo for Peoples/######",
    "render_output_root": "/tmp/flamenco/",
    "video_container_format": "MPEG1"
  },
  "priority": 50,
  "submitter_platform": "manager"
}'
