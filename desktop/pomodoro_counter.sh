#!/bin/bash

WORKDAY_HOURS=8
WORKDAY_MINUTES=0
WORKDAY_SECONDS=$((3600*$WORKDAY_HOURS+60*$WORKDAY_MINUTES))

DAYS_AGO=${1:-0}
DAYS_AGO_STR="$DAYS_AGO day ago"

THIS_WEEK_REGEX=$(
  for i in $(seq 1 "$(date +%u -d "$DAYS_AGO_STR")") ; do
    date '+%y-%m-%d' -d "$((i-1 + DAYS_AGO)) day ago"
  done \
    | tr '\n' '|' \
    | sed -e 's/|$//;s/^/\\(/;s/$/\\)/;s/|/\\|/g'
)
TODAY_REGEX=$(date '+%y-%m-%d' -d "$DAYS_AGO_STR")
THIS_MONTH_REGEX=$(
  for i in $(seq 1 "$(date +%d -d "$DAYS_AGO_STR")") ; do
    date '+%y-%m-%d' -d "$((i-1 + DAYS_AGO)) day ago"
  done \
    | tr '\n' '|' \
    | sed -e 's/|$//;s/^/\\(/;s/$/\\)/;s/|/\\|/g'
)
THIS_WORK_MONTH_REGEX=$(
  for i in $(seq 1 "$(date +%d -d "$DAYS_AGO_STR")") ; do
    if [ "$(date +%u -d "$((i-1 + DAYS_AGO)) day ago")" -lt 6 ] ; then
      date '+%y-%m-%d' -d "$((i-1 + DAYS_AGO)) day ago"
    fi
  done \
    | tr '\n' '|' \
    | sed -e 's/|$//;s/^/\\(/;s/$/\\)/;s/|/\\|/g'
)

success() {
  grep succeed
}

logs() {
  cat "$HOME/.logs/pomodoro.csv" | grep -P "\t$1\t"
}

hours_time() {
  printf "%d:%02d" "$(($1/3600))" "$(($1%3600/60))"
}

hours_time_decimal() {
  echo "scale=3;$1/3600" | bc -l
}

days_time() {
  days=$(($1/"$WORKDAY_SECONDS"))
  hours=$(($1%"$WORKDAY_SECONDS"/3600))
  minutes=$(( ( $1%"$WORKDAY_SECONDS" % 3600) / 60))
  if [ "$days" != 0 ] ; then
    printf "%dmd,%d:%02d" $days $hours $minutes
  else
    printf "%d:%02d" $hours $minutes
  fi
}

total_time() {
  cut -f 3 | awk 'BEGIN{total=0} {total=total + $1}END{print(total)}'
}

working_days_worked() {
  SELECTION=$1
  WORKDAY_REGEX=$2
  logs "$SELECTION" | grep -e "$WORKDAY_REGEX" | cut -f 2 | cut -d / -f 1 | sort -u | wc -l
}

worked_time() {
  SELECTION=$1
  WIDE_REGEX=$2
  logs "$SELECTION" | grep -e "$WIDE_REGEX" | total_time
}

time_left() {
  SELECTION=$1
  WIDE_REGEX=$2
  WORKDAY_REGEX=${3:-$2}

  current_pomodoro=$(pomodoro-client status | grep Pomodoro | sed -e 's/^.*\b\([0-9][0-9]*:[0-9]*\)\b.*$/\1/;s/:/*60+/' | bc -l)

  if [ -z "$current_pomodoro" ]; then
    WORKED_TIME=$(( $(worked_time "$SELECTION" "$WIDE_REGEX")  ))
  else
    cp=$(( "$current_pomodoro" + 0 ))
    WORKED_TIME=$(( 29*60 - "$cp" + $(worked_time "$SELECTION" "$WIDE_REGEX") ))
  fi
  WORKING_DAYS_WORKED=$(working_days_worked "$SELECTION" "$WORKDAY_REGEX")
  if [ "$WORKING_DAYS_WORKED" -eq 0 ] ; then
    if [ "$(date +%u -d "$DAYS_AGO_STR")" -lt 6 ] ; then
      WORKING_DAYS_WORKED=1
    fi
  fi
  echo $((WORKDAY_SECONDS*WORKING_DAYS_WORKED - WORKED_TIME))
}


success_time() {
  SELECTION=$1
  WIDE_REGEX=$2

  WORKED_TIME=$(worked_time "$SELECTION" "$WIDE_REGEX")
  SUCCESS_TIME=$(logs "$SELECTION" | grep -e "$WIDE_REGEX" | success | total_time)
  if [ "$WORKED_TIME" == "0" ] ; then
    WORKED_TIME=1
  fi
  echo $((100*SUCCESS_TIME / WORKED_TIME))
}

COMPANY=Wincent

echo "Time left $(hours_time "$(time_left "$COMPANY" "$TODAY_REGEX")")($(success_time "$COMPANY" "$TODAY_REGEX")%)"
echo "w: $(hours_time "$(time_left "$COMPANY" "$THIS_WEEK_REGEX")")($(success_time "$COMPANY" "$THIS_WEEK_REGEX")%)"
echo "m: $(days_time "$(time_left "$COMPANY" "$THIS_MONTH_REGEX" "$THIS_WORK_MONTH_REGEX")")($(success_time "$COMPANY" "$THIS_MONTH_REGEX")%)"
if [ -n "$2" ] ; then
  echo "Working days worked: $(working_days_worked "$COMPANY" "$THIS_WORK_MONTH_REGEX")"
  worked=$(worked_time ""$COMPANY"-oncall" "$THIS_MONTH_REGEX")
  if [ -z "$worked" ]; then
    worked="0"
  fi
  echo "Oncall emergency time $(hours_time "$worked") ($(hours_time_decimal "$worked"))"
  logs ""$COMPANY"\-oncall" | grep -e "$THIS_MONTH_REGEX"
fi
