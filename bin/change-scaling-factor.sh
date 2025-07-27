#!/bin/bash

what=$1
current=$(dconf read /org/gnome/desktop/interface/text-scaling-factor | awk '{printf("%.2f", $1)}')
next=$current
case "$current" in
  "0.5"*)
    if [ "$what" == "increase" ] ; then next="0.6" ; elif [ "$what" == "decrease" ] ; then next="0.5" ; fi
    ;;
  "0.6"*)
    if [ "$what" == "increase" ] ; then next="0.7" ; elif [ "$what" == "decrease" ] ; then next="0.5" ; fi
    ;;
  "0.7"*)
    if [ "$what" == "increase" ] ; then next="0.8" ; elif [ "$what" == "decrease" ] ; then next="0.6" ; fi
    ;;
  "0.8"*)
    if [ "$what" == "increase" ] ; then next="0.9" ; elif [ "$what" == "decrease" ] ; then next="0.7" ; fi
    ;;
  "0.9"*)
    if [ "$what" == "increase" ] ; then next="1.0" ; elif [ "$what" == "decrease" ] ; then next="0.8" ; fi
    ;;
  "1.0"*)
    if [ "$what" == "increase" ] ; then next="1.25" ; elif [ "$what" == "decrease" ] ; then next="0.9" ; fi
    ;;
  "1.25"*)
    if [ "$what" == "increase" ] ; then next="1.5" ; elif [ "$what" == "decrease" ] ; then next="1.0" ; fi
    ;;
  "1.5"*)
    if [ "$what" == "increase" ] ; then next="1.75" ; elif [ "$what" == "decrease" ] ; then next="1.25" ; fi
    ;;
  "1.75"*)
    if [ "$what" == "increase" ] ; then next="2.0" ; elif [ "$what" == "decrease" ] ; then next="1.5" ; fi
    ;;
  "2"*)
    if [ "$what" == "increase" ] ; then next="2.0" ; elif [ "$what" == "decrease" ] ; then next="1.75" ; fi
    ;;
  *)
    next="1.0"
    ;;
esac
if [ "$what" == "reset" ] ; then next="1.0" ; fi
echo "changing scaling: $current -> $next"
dconf write /org/gnome/desktop/interface/text-scaling-factor "$next"
