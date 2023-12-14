#!/bin/bash

echo "MANAGER LOCATION : $MANAGER_LOCATION"
/worker/flamenco-worker  --manager "$MANAGER_LOCATION"