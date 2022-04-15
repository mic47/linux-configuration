#!/bin/bash

(sleep 10 && pomodoro-client resume >> ~/.logs/pomodoro-client.debug 2>&1 ) &
