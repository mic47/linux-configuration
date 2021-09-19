#!/bin/bash

FROM=$(date --date "$1" +%s)
UNTIL=$(date --date "$2" +%s)
MINUTES=$(("$UNTIL" - "$FROM"))
DOUBLE_MINUTES=$(("$MINUTES" * 2))

pomodoro-question.sh "Manual" "$DOUBLE_MINUTES" "$MINUTES" "Manual" "$UNTIL"
