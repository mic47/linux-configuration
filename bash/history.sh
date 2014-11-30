#!/bin/bash

hcmnt() {
    # adds comments to bash history entries (or logs them)

    # by Dennis Williamson - 2009-06-05 - updated 2009-06-19
    # http://stackoverflow.com/questions/945288/saving-current-directory-to-bash-history
    # (thanks to Lajos Nagy for the idea)

    # the comments can include the directory
    # that was current when the command was issued
    # plus optionally, the date or other information

    # set the bash variable PROMPT_COMMAND to the name
    # of this function and include these options:

    # -e - add the output of an extra command contained in the hcmntextra variable
    # -i - add ip address of terminal that you are logged in *from*
    #      if you're using screen, the screen number is shown
    #      if you're directly logged in, the tty number or X display number is shown
    # -l - log the entry rather than replacing it in the history
    # -n - don't add the directory
    # -t - add the from and to directories for cd commands
    # -y - add the terminal device (tty)
    # text or a variable

    # Example result for PROMPT_COMMAND='hcmnt -et $LOGNAME'
    #     when hcmntextra='date "+%Y%m%d %R"'
    # cd /usr/bin ### mike 20090605 14:34 /home/mike -> /usr/bin

    # Example for PROMPT_COMMAND='hcmnt'
    # cd /usr/bin ### /home/mike

    # Example for detailed logging:
    #     when hcmntextra='date "+%Y%m%d %R"'
    #     and PROMPT_COMMAND='hcmnt -eityl ~/.hcmnt.log $LOGNAME@$HOSTNAME'
    #     $ tail -1 ~/.hcmnt.log
    #     cd /var/log ### dave@hammerhead /dev/pts/3 192.168.1.1 20090617 16:12 /etc -> /var/log


    # INSTALLATION: source this file in your .bashrc

    # will not work if HISTTIMEFORMAT is used - use hcmntextra instead
    export HISTTIMEFORMAT=

    # HISTTIMEFORMAT still works in a subshell, however, since it gets unset automatically:

    #   $ htf="%Y-%m-%d %R "    # save it for re-use
    #   $ (HISTTIMEFORMAT=$htf; history 20)|grep 11:25

    local script=$FUNCNAME

    local hcmnt=
    local cwd=
    local extra=
    local text=
    local logfile=

    local options=":eil:nty"
    local option=
    OPTIND=1
    local usage="Usage: $script [-e] [-i] [-l logfile] [-n|-t] [-y] [text]"

    local newline=$'\n' # used in workaround for bash history newline bug
    local histline=     # used in workaround for bash history newline bug

    local ExtraOpt=
    local LogOpt=
    local NoneOpt=
    local ToOpt=
    local tty=
    local ip=

    # *** process options to set flags ***

    while getopts $options option
    do
        case $option in
            e ) ExtraOpt=1;;        # include hcmntextra
            i ) ip="$(who -m)" # include the terminal's ip address
                ip=($ip)
                ip="${ip[4]}"
                if [[ -z $ip ]]
                then
                    ip=$(tty)
                fi;;
            l ) LogOpt=1            # log the entry
                logfile=$OPTARG;;
            n ) if [[ $ToOpt ]]
                then
                    echo "$script: can't include both -n and -t."
                    echo $usage
                    return 1
                else
                    NoneOpt=1       # don't include path
                fi;;
            t ) if [[ $NoneOpt ]]
                then
                    echo "$script: can't include both -n and -t."
                    echo $usage
                    return 1
                else
                    ToOpt=1         # cd shows "from -> to"
                fi;;
            y ) tty=$(tty);;
            : ) echo "$script: missing filename: -$OPTARG."
                echo $usage
                return 1;;
            * ) echo "$script: invalid option: -$OPTARG."
                echo $usage
                return 1;;
        esac
    done

    text=($@)                       # arguments after the options are saved to add to the comment
    text="${text[*]:$OPTIND - 1:${#text[*]}}"

    # *** process the history entry ***

    hcmnt=$(history 1)              # grab the most recent command

    # save history line number for workaround for bash history newline bug
    histline="${hcmnt%  *}"

    hcmnt="${hcmnt# *[0-9]*  }"     # strip off the history line number

    if [[ -z $NoneOpt ]]            # are we adding the directory?
    then
        if [[ ${hcmnt%% *} == "cd" ]]    # if it's a cd command, we want the old directory
        then                             #   so the comment matches other commands "where *were* you when this was done?"
            if [[ $ToOpt ]]
            then
                cwd="$OLDPWD -> $PWD"    # show "from -> to" for cd
            else
                cwd=$OLDPWD              # just show "from"
            fi
        else
            cwd=$PWD                     # it's not a cd, so just show where we are
        fi
    fi

    if [[ $ExtraOpt && $hcmntextra ]]    # do we want a little something extra?
    then
        extra=$(eval "$hcmntextra")
    fi

    # strip off the old ### comment if there was one so they don't accumulate
    # then build the string (if text or extra aren't empty, add them plus a space)
    if [[ $LogOpt ]]
    then
        # Save it as csv file
        hcmnt="${text:+$text},${tty:+$tty},${ip:+$ip},${extra:+$extra},$cwd,${hcmnt% ### *}"
    else
        hcmnt="${hcmnt% ### *} ### ${text:+$text }${tty:+$tty }${ip:+$ip }${extra:+$extra }$cwd"
    fi

    if [[ $LogOpt ]]
    then
        # save the entry in a logfile
        echo "$hcmnt" >> $logfile || echo "$script: file error." ; return 1
    else

        # workaround for bash history newline bug
        if [[ $hcmnt != ${hcmnt/$newline/} ]] # if there a newline in the command
        then
            history -d $histline # then delete the current command so it's not duplicated
        fi

        # replace the history entry
        history -s "$hcmnt"
    fi

} # END FUNCTION hcmnt

