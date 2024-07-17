#!/bin/bash


echo '""' | APP=$1 SUM=$2 BOD=$3 ICO=$4 URG=$5 jq '{
  app_name: $ENV.DUNST_APP_NAME,
  summary: $ENV.DUNST_SUMMARY,
  body: $ENV.DUNST_BODY,
  icon_path: $ENV.DUNST_ICON_PATH,
  urgency: $ENV.DUNST_URGENCY,
  id: $ENV.DUNST_ID,
  progress: $ENV.DUNST_PROGRESS,
  category: $ENV.DUNST_CATEGORY,
  stack_tag: $ENV.DUNST_STACK_TAG,
  urls: $ENV.DUNST_URLS,
  timeout: $ENV.DUNST_TIMEOUT,
  timestamp: $ENV.DUNST_TIMESTAMP,
  desktop_entry: $ENV.DUNST_DESKTOP_ENTRY,
  stack_tag: $ENV.DUNST_STACK_TAG,
  params: {
    appname: $ENV.APP,
    summary: $ENV.SUM,
    body: $ENV.BOD,
    icon_path: $ENV.ICO,
    urgency: $ENV.URG
  }
}' -c >> ~/.logs/notifications.jsonl
