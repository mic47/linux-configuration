#!/bin/bash

JQ_PROGRAM='
.data
| [
  sort_by(.created_at)[]
  | {
    name:.name,
    gid: .gid,
    subtasks: [
      .subtasks[]
      | select(.completed==false)
      | select((.assignee.gid == "1167135748936328") or (.assignee.gid == null))
      | (
        {
          name: .name,
          gid: .gid,
          assignee: .assignee.name
        } + (
          [ .custom_fields[]
            | {"key": .name, "value": .enum_value.name}
          ] | from_entries
        )
      )
    ],
    assignee: .assignee.name
  } + (
    [ .custom_fields[]
      | {"key": .name, "value": .enum_value.name}
    ] | from_entries
  )
] as $data
| [ $data[].subtasks[].gid] as $subtasks
| [
  $data[]
  | .gid as $i
  | select(($subtasks | index($i)) == null)
][]
| (
  ("♦️[" + (."Task Status" // "❓") + (if .assignee == null then "☠️" else "" end) + "] " + .name + "\t:" + .gid),
  (.subtasks[] | ("      [" + (."Task Status" // "❓") + (if .assignee == null then "☠️" else "" end) + "] " + .name + "\t:" + .gid))
)
'

STATE=$1
DURATION=$2
# shellcheck disable=SC2001
ELAPSED=$(echo "$3" | sed -e 's/[.].*$//')
TRIGGER=$4
NOW_TIMESTAMP=${5:-$(date +%s)}
NOW=$(date "+%y-%m-%d/%H:%M:%S" -d "@$NOW_TIMESTAMP")


if [ "$((DURATION - 60))" -lt "$ELAPSED" ] ; then
  # Add 1 minute, which is break
  ELAPSED=$((ELAPSED + 60))
fi


WORKSPACE=$(cat ~/.ssh/asana.token | jq .workspace -r)
ASANA_TOKEN=$(cat ~/.ssh/asana.token | jq .asana_token -r)

COMBO_VALUES=$(
  tempfile=$(mktemp)

  curl -X GET 'https://app.asana.com/api/1.0/workspaces/'$WORKSPACE'/tasks/search?assignee.any=me&completed_on=null&opt_fields=name,resource_type,completed,completed_at,assignee,projects,subtasks,this.subtasks.name,this.subtasks.assignee,this.subtasks.completed,assignee.name,this.subtasks.assignee.name,parent.gid,parent.name,custom_fields.name,custom_fields.enum_value.name,this.subtasks.custom_fields.name,this.subtasks.custom_fields.enum_value.name,created_at'  -H 'Accept: application/json'   -H 'Authorization: Bearer '$ASANA_TOKEN \
    | jq "$JQ_PROGRAM"  -r > "$tempfile"
  (cat "$tempfile" | grep -e '\(Development\|Code Review\)' ; cat "$tempfile" ) \
    | tr '\t' ' ' \
    | tr '|' ' ' \
    | tr '\n' '|' \
    | sed -e 's/Code Review/📗/g;s/Development/⌚/g;s/In Acceptance/📘/g;s/Inbox/📫/g;s/Backlog/📬/g'
)


question() {
  (sleep 1 && wmctrl -F -a "Pomodoro survey" -b add,above) &
  zenity \
    --forms \
    --title "Pomodoro survey" \
    --add-combo="Was pomodoro successfull?" \
    --combo-values="succeed|fail" \
    --add-entry "What did you do?" \
    --add-combo "What asana task?" \
    --combo-values "$COMBO_VALUES" \
    --add-list "Type of work" \
    --list-values "Focus work|Meeting|Overhead|Learning" \
    --add-combo "Billable to" \
    --combo-values "$(cat /home/mic/.billable_companies | tr '\n' '|')None" \
    --add-entry "Why failed?" \
    --text "" \
    --separator "$(echo -e '\t')"
}

(
  form_output=$( question || question || question )

  echo -e "${NOW_TIMESTAMP}\t${NOW}\t$ELAPSED\t$form_output" >> /home/mic/.logs/pomodoro.csv
  env > /home/mic/.logs/pomodoro.env
  echo "$*" > /home/mic/.logs/pomodoro.args
) &
