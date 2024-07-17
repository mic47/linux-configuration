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

PYTHON_PROGRAM='
import sys

all_todos = []
with open(sys.argv[2]) as todos:
  for todo in todos:
    all_todos.append(todo.strip())
all_todos_set = set(all_todos)
emitted_todos = set()
with open(sys.argv[1]) as order:
  for todo in order:
    todo = todo.strip()
    if todo in all_todos_set:
      print(todo)
      emitted_todos.add(todo)
for todo in all_todos:
  if todo not in emitted_todos:
    print(todo)
'

STATE=$1
DURATION=$2
# shellcheck disable=SC2001
ELAPSED=$(echo "$3" | sed -e 's/[.].*$//' | sed -e 's/^$/0/')
TRIGGER=$4
NOW_TIMESTAMP=${5:-$(date +%s)}
NOW=$(date "+%y-%m-%d/%H:%M:%S" -d "@$NOW_TIMESTAMP")
STARTED_TIMESTAMP=$(($NOW_TIMESTAMP - $ELAPSED))
STARTED=$(date "+%y-%m-%d/%H:%M:%S" -d "@$STARTED_TIMESTAMP")


if [ "$((DURATION - 60))" -lt "$ELAPSED" ] ; then
  # Add 1 minute, which is break
  ELAPSED=$((ELAPSED + 60))
fi


WORKSPACE=$(cat ~/.ssh/asana.token | jq .workspace -r)
ASANA_TOKEN=$(cat ~/.ssh/asana.token | jq .asana_token -r)

COMBO_VALUES=$(python \
  -c "$PYTHON_PROGRAM" \
  <(
    cat ~/.logs/pomodoro.csv \
      | cut -f 6 -d $'\t' \
      | grep -v '^\s*$' \
      | sed -e 's/,$//' \
      | tac \
      | awk '{if (a[$0] != 1) {print($0); a[$0] = 1}}'
  ) \
  <(echo "other" ;
    grep --with-filename '\(^ *- *\[ \]\|^ *\[ \]\)' $(\
    (
      ls \
        /home/$USER/Documents/WorkNotext.md \
        /home/$USER/Documents/WorkLog/*/*/*.md \
        | sort -r \
      ; \
      ls \
        /home/$USER/Dropbox/Wiki/log/*/*/*.md \
        | sort -r \
      ) \
    ) \
    | sed -e 's/^\/home\/[^\/]*\/Documents\///;s/^\/home\/[^\/]*\/Dropbox\/Wiki\///' \
    | sed -e 's/:- *\[ *\] */:/;s/: *\[ *\] */:/;s/ *$//'
  ) | tr '\n' '|'
)

#COMBO_VALUES=$(
#  tempfile=$(mktemp)
#
#  #curl -X GET 'https://app.asana.com/api/1.0/workspaces/'$WORKSPACE'/tasks/search?assignee.any=me&completed_on=null&opt_fields=name,resource_type,completed,completed_at,assignee,projects,subtasks,this.subtasks.name,this.subtasks.assignee,this.subtasks.completed,assignee.name,this.subtasks.assignee.name,parent.gid,parent.name,custom_fields.name,custom_fields.enum_value.name,this.subtasks.custom_fields.name,this.subtasks.custom_fields.enum_value.name,created_at'  -H 'Accept: application/json'   -H 'Authorization: Bearer '$ASANA_TOKEN \
#  #  | jq "$JQ_PROGRAM"  -r > "$tempfile"
#  #(cat "$tempfile" | grep -e '\(Development\|Code Review\)' ; cat "$tempfile" ) \
#  #  | tr '\t' ' ' \
#  #  | tr '|' ' ' \
#  #  | tr '\n' '|' \
#  #  | sed -e 's/Code Review/📗/g;s/Development/⌚/g;s/In Acceptance/📘/g;s/Inbox/📫/g;s/Backlog/📬/g'
#  echo "other|$(grep --with-filename '\(^ *- *\[ \]\|^ *\[ \]\)' $(\
#    (
#      ls \
#        /home/$USER/Documents/WorkNotext.md \
#        /home/$USER/Documents/WorkLog/*/*/*.md \
#        /home/$USER/Documents/WorkLog/*/*/*.md \
#        | sort -r \
#      ; \
#      ls \
#        /home/$USER/Dropbox/Wiki/log/*/*/*.md \
#        | sort -r \
#      ) \
#    ) \
#    | sed -e 's/^\/home\/[^\/]*\/Documents\///;s/^\/home\/[^\/]*\/Dropbox\/Wiki\///' \
#    | sed -e 's/:- *\[ *\] */:/;s/: *\[ *\] */:/;s/ *$//' | tr '\n' '|'
#  )"
#)


echo "A"
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
    --combo-values "$(cat "$HOME"/.billable_companies | tr '\n' '|')None" \
    --add-entry "Why failed?" \
    --text "$STARTED - $NOW" \
    --separator "$(echo -e '\t')"
}

(
  form_output=$( question || question || question )

  echo -e "${NOW_TIMESTAMP}\t${NOW}\t$ELAPSED\t$form_output" >> "$HOME"/.logs/pomodoro.csv
  env > "$HOME"/.logs/pomodoro.env
  echo "$*" > "$HOME"/.logs/pomodoro.args
)
