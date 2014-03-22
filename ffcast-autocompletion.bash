_ffcast()
{
    #defining local vars
    local cur prev words cword
    _init_completion || return

    COMMANDS="ffmpeg byzanz-record recordmydesktop"
    OPTS="-s -w -x -b -m -p -l -q -v -h --"

    #case "${prev}" in
        #pattern1)
           #_filedir
          #return 0 
          #;;
        #pattern2)
            #_filedir
            #return 0
            #;;
    #esac

    #general options
    case "${cur}" in
        -*)
            COMPREPLY=( $( compgen -W "$OPTS" -- $cur ))
            ;;
        *)
            COMPREPLY=( $( compgen -W "$COMMANDS" -- $cur ))
            ;;
    esac
} &&
complete -F _ffcast ffcast ffcast2

#push this file to /usr/share/bash-completion/completions/
#as ffcast and ffcast2

# vim: set ts=8 sw=4 tw=0 ft=sh : 
