#!/usr/bin/env sh
#
# FFcast, http://github.com/chilicuil/ffcast
# Copyright (C) 2011  lolilolicon  <lolilolicon@gmail.com>
# Copyright (C) 2014  Javier Lopez <m@javier.io>
#
# This program is free software: you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation, either version 3 of the License, or
# (at your option) any later version.
#
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License
# along with this program.  If not, see <http://www.gnu.org/licenses/>.

cast_cmd_pattern="ffmpeg,byzanz-record,recordmydesktop"
modulus=2; borderless=1; verbosity=0

#---
# Functions

__msg() {
    __msg_var_prefix=$1
    shift || return 0
    __msg_var_fmt=$1
    shift || return 0
    printf '%s' "$__msg_var_prefix"
    printf -- "$__msg_var_fmt\n" "$@"
}

_isnum() {
    [ -z "$1" ] && return 1
    printf "%s\\n" "$@" | grep -v "[^0-9]" >/dev/null
}

_quote_cmd_line() {
    _quote_cmd_line_var_prefix=$1
    shift || return 0
    _quote_cmd_line_var_cmd=$1
    shift || return 0
    printf '%s' "$_quote_cmd_line_var_prefix"
    printf '%s' "$_quote_cmd_line_var_cmd"
    expr $# + 0 >/dev/null 2>/dev/null && printf ' %s' "$@"
    printf '\n'
}

_debug_dryrun() {
    [ $verbosity -ge 2 ] || return 0
    _quote_cmd_line 'debug: command: ' "$@" >&2
}

_debug_run() {
    _debug_dryrun "$@" && sh -c "$*"
}

_debug() {
    [ $verbosity -ge 2 ] || return 0
    __msg 'debug: ' "$@" >&2
}

_verbose() {
    [ $verbosity -ge 1 ] || return 0
    __msg 'verbose: ' "$@" >&2
}

_msg() {
    [ $verbosity -ge 0 ] || return 0
    __msg ':: ' "$@" >&2
}

_warn() {
    [ $verbosity -ge -1 ] || return 0
    __msg 'warning: ' "$@" >&2
}

_error() {
    [ $verbosity -ge -1 ] || return 0
    __msg 'error: ' "$@" >&2
    exit 1
}

_format_to_string() {
    _format_to_string_var_fmt=$1
    _format_to_string_f=0

    if printf "%s" "$_format_to_string_var_fmt" | grep "%" >/dev/null; then
        while [ "$_format_to_string_var_fmt" ]; do
            _format_to_string_c=$(printf "%s" "$_format_to_string_var_fmt" | cut -c1)
            _format_to_string_var_fmt=$(printf "%s" "$_format_to_string_var_fmt" | cut -c2-)
            case $_format_to_string_c in
                '%') _format_to_string_f=1 ;;
                'd') [ $_format_to_string_f -eq 1 ] && {
                     _format_to_string_var_result="$_format_to_string_var_result""$DISPLAY";
                     _format_to_string_f=0; } ||
                     _format_to_string_var_result="$_format_to_string_var_result""$_format_to_string_c" ;;
                'h') [ $_format_to_string_f -eq 1 ] && {
                     _format_to_string_var_result="$_format_to_string_var_result""$h"; 
                     _format_to_string_f=0; } ||
                     _format_to_string_var_result="$_format_to_string_var_result""$_format_to_string_c" ;;
                'w') [ $_format_to_string_f -eq 1 ] && {
                     _format_to_string_var_result="$_format_to_string_var_result""$w";
                     _format_to_string_f=0; } ||
                     _format_to_string_var_result="$_format_to_string_var_result""$_format_to_string_c" ;;
                'x') [ $_format_to_string_f -eq 1 ] && {
                     _format_to_string_var_result="$_format_to_string_var_result""$_x";
                     _format_to_string_f=0; } ||
                     _format_to_string_var_result="$_format_to_string_var_result""$_format_to_string_c" ;;
                'y') [ $_format_to_string_f -eq 1 ] && {
                     _format_to_string_var_result="$_format_to_string_var_result""$_y";
                     _format_to_string_f=0; } ||
                     _format_to_string_var_result="$_format_to_string_var_result""$_format_to_string_c" ;;
                'X') [ $_format_to_string_f -eq 1 ] && {
                     _format_to_string_var_result="$_format_to_string_var_result""$x_";
                     _format_to_string_f=0; } ||
                     _format_to_string_var_result="$_format_to_string_var_result""$_format_to_string_c" ;;
                'Y') [ $_format_to_string_f -eq 1 ] && {
                     _format_to_string_var_result="$_format_to_string_var_result""$y_";
                     _format_to_string_f=0; } ||
                     _format_to_string_var_result="$_format_to_string_var_result""$_format_to_string_c" ;;
                *)   _format_to_string_var_result="$_format_to_string_var_result""$_format_to_string_c" ;;
            esac
        done
    fi
    printf "%s" "$_format_to_string_var_result"
}

_list_cast_cmds() {
    while [ "$cast_cmd_pattern" ]; do
        cast_cmd_pattern_option=${cast_cmd_pattern%%,*}
        printf "%s\n" "$cast_cmd_pattern_option"
        [ X"$cast_cmd_pattern" = X"$cast_cmd_pattern_option" ] && cast_cmd_pattern='' || cast_cmd_pattern="${cast_cmd_pattern#*,}"
    done
}

_select_region_get_corners() {
    _notify "[+] Select" "a region to save"
    # Note: requires xrectsel 0.3
    xrectsel "%x,%y %X,%Y"
}

_select_window_get_corners() {
    _notify "[+] Select" "a target window"

    _select_window_get_corners_var_output=$(LC_ALL=C xwininfo)
    _select_window_get_corners_var_output_corners=$(printf "%s\\n" "$_select_window_get_corners_var_output" \
        |  awk '/Corners/ {for (i=2; i<NF; i++) printf $i " "; print $NF}')
    _select_window_get_corners_var_x=$(printf "%s\\n" "$_select_window_get_corners_var_output_corners" \
        | awk '{print $1}' | cut -d'+' -f2)
    _select_window_get_corners_var_y=$(printf "%s\\n" "$_select_window_get_corners_var_output_corners" \
        | awk '{print $1}' | cut -d'+' -f3)
    _select_window_get_corners_var_x_=$(printf "%s\\n" "$_select_window_get_corners_var_output_corners" \
        | awk '{print $3}' | cut -d'-' -f2)
    _select_window_get_corners_var_y_=$(printf "%s\\n" "$_select_window_get_corners_var_output_corners" \
        | awk '{print $3}' | cut -d'-' -f3)
    printf '%d,%d %d,%d\n' $_select_window_get_corners_var_x $_select_window_get_corners_var_y $_select_window_get_corners_var_x_  $_select_window_get_corners_var_y_
}

_xdpyinfo_list_heads() {
    xdpyinfo -ext XINERAMA | awk '/head #/ { sub(/^[ \t]+/, ""); print }'
}

_kill() {
    for supported_program in $(_list_cast_cmds); do
        if command -v "$supported_program" >/dev/null; then
            _kill_var_pid=$(ps -aef | awk -v patt=${supported_program} '$0 ~ patt {if ($0 !~ "awk|sh" ) a[i++]=$2} END {print a[i-1]}')
            [ -z "$_kill_var_pid" ] || kill -2 "$_kill_var_pid" >/dev/null 2>&1
            _kill_var_pid=""
        fi
    done
}

_notify ()
{
    if ! command -v "notify-send" >/dev/null; then _msg "%s %s" "${@}"; fi
    [ X"$TERM" = X"linux" ] && notify-send -t 1000 "${@}" || _msg "%s %s" "${@}"
}

_usage()
{
    printf "%s\\n" "Usage:"
    printf "  %s\\n" "$(expr "$0" : '.*/\([^/]*\)') [options] % [command [args]]"
    printf "  %s\\n" "$(expr "$0" : '.*/\([^/]*\)') [options] [command [args] [--] [args]]"
    printf "\\n"
    printf "  %s\\n" "Options:"
    printf "    %s\\n" "-s           select a rectangular region by mouse"
    printf "    %s\\n" "-w           select a window by mouse click"
    printf "    %s\\n" "-x <n|list>  select the Xinerama head of id n"
    printf "    %s\\n" "-b           include window borders hereafter"
    printf "    %s\\n" "-m <n>       trim region to be divisible by n"
    printf "    %s\\n" "-p           print region geometry only"
    printf "    %s\\n" "-l           list recognized screencast commands"
    printf "    %s\\n" "-q           be less verbose"
    printf "    %s\\n" "-v           be more verbose"
    printf "    %s\\n" "-h           print this help and exit"
    printf "\\n"
    printf "  %s\\n" "If no region-selecting argument is passed, select fullscreen."
    exit 0
}

#---
# Process arguments passed to ffcast

for var in "$@"; do #parse options
    case "${var}" in
        -h)  _usage ;;
        -l)  _list_cast_cmds; exit 0;;
        -k)  _kill; exit 0;;
        -m)  if [ $# -gt 1 ]; then
                 modulus=$(printf "%s " "$@" | awk '{print $2}')
                 shift 2
                 if ! _isnum "$modulus" ; then
                     _error "invalid modulus: \`%s'" "$OPTARG"
                 fi
             else
                 _error "Option $var requires a modulus number"
             fi
             ;;
        -s)  shift; region_select_action='s,'"$region_select_action" ;;
        -w)  shift; region_select_action='w,'"$region_select_action" ;;
        -b)  shift; region_select_action='b,'"$region_select_action" ;;
        -p)  shift; print_geometry_only=1 ;;
        -q*) shift; verbosity=$(expr $verbosity - $(expr ${#var} + 1) ) || : ;;
        -v*) shift; verbosity=$(expr $verbosity + $(expr ${#var} - 1) ) || : ;;
        -x)  if [ $# -gt 1 ]; then
                 OPTARG=$(printf "%s " "$@" | awk '{print $2}')
                 shift 2
                 if [ X"$OPTARG" = X'list' ]; then
                     _xdpyinfo_list_heads
                     exit
                 fi
             else
                 _error "Option $var requires a Xinerama id n"
             fi
             ;;
        -*)  _error "Unrecognized option: $var" ;;
        *)   break;
    esac
done

if ! command -v "xrectsel" >/dev/null; then
    _error "xrectsel not found!, $ sudo apt-get install ffcast"
elif ! command -v "xdpyinfo" >/dev/null; then
    _error "xdpyinfo not found!, $ sudo apt-get install x11-utils"
elif ! command -v "xwininfo" >/dev/null; then
    _error "xwininfo not found!, $ sudo apt-get install x11-utils"
fi

_notify "[+] Screencast" "in 3.., 2.., 1.., smile =)!"; sleep 3
kill $(ps -aef | awk '/notify-osd/ {if ($0 !~ "awk") print $2}') >/dev/null 2>/dev/null; sleep .5

#---
# Process region geometry

xwininfo_output=$(LC_ALL=C xwininfo -root)
rootw=$(printf "%s\\n" "$xwininfo_output" | awk '/Width/  {print $2}')
rooth=$(printf "%s\\n" "$xwininfo_output" | awk '/Height/ {print $2}')

if [ -z "$rootw" ] || [ -z "$rooth" ]; then
    _error 'failed to get root window dimensions'
fi

for i in $*; do
    if [ X"$i" = X"%" ]; then
        use_format_string=1
        shift
        break
    else
        for supported_program in $(_list_cast_cmds); do
            if [ X"$1" = X"$supported_program" ]; then
                if ! command -v "$supported_program" >/dev/null; then
                    _error "$supported_program not found!"
                else
                    supported_program=1
                    break
                fi
            fi
        done
        [ X"$supported_program" = X"1" ] && break
    fi
done

while [ "$region_select_action" ]; do
    region_select_action_option=${region_select_action%%,*}
    case $region_select_action_option in
        's') corners_list="$(_select_region_get_corners)""-""$corners_list"
             _debug "corners: %s" "$(printf "%s" "${corners_list}" | cut -d'-' -f1)"
             break ;;
        'w') corners_list="$(_select_window_get_corners)""-""$corners_list"
             _debug "corners: %s" "$(printf "%s" "${corners_list}" | cut -d'-' -f1)"
             break ;;
        'b') borderless=0
             _verbose "windows: now including borders" ;;
    esac
    [ X"$region_select_action" = X"$region_select_action_option" ] && region_select_action='' || region_select_action="${region_select_action#*,}"
done

#full screen mode
[ -z "$corners_list" ] && corners_list="0,0 0,0"

_x=$(printf "%s" "$corners_list" | awk 'BEGIN {FS="-"} {split($1, i, " "); split(i[1], j, ","); print j[1]}')
_y=$(printf "%s" "$corners_list" | awk 'BEGIN {FS="-"} {split($1, i, " "); split(i[1], j, ","); print j[2]}')
x_=$(printf "%s" "$corners_list" | awk 'BEGIN {FS="-"} {split($1, i, " "); split(i[2], j, ","); print j[1]}')
y_=$(printf "%s" "$corners_list" | awk 'BEGIN {FS="-"} {split($1, i, " "); split(i[2], j, ","); print j[2]}')
w=$(expr $rootw - $(expr $_x + $x_))
h=$(expr $rooth - $(expr $_y + $y_))

[ $w -lt 0 ] && _error 'region: invalid width: %d'  "$w"
[ $h -lt 0 ] && _error 'region: invalid height: %d' "$h"

if [ -n "$print_geometry_only" ]; then
    printf "%dx%d+%d+%d\n" $w $h $_x $_y
    exit
fi

#---
# Post-process region geometry

if [ $modulus -gt 1 ]; then
    w_old=$w; w=$(expr $modulus \* $(expr $w / $modulus))
    h_old=$h; h=$(expr $modulus \* $(expr $h / $modulus))

    if ! expr $w + 0 >/dev/null 2>/dev/null; then
        _error 'region: width too small for modulus %d: %d' $modulus $w_old
    fi
    if ! expr $h + 0 >/dev/null 2>/dev/null; then
        _error 'region: height too small for modulus %d: %d' $modulus $h_old
    fi

    if [ $w -lt $w_old ]; then
        _verbose 'region: trim width from %d to %d' $w_old $w
        x_=$(expr $x_ + $(expr $w_old - $w))
    fi
    if [ $h -lt $h_old ]; then
        _verbose 'region: trim height from %d to %d' $h_old $h
        y_=$(expr $y_ + $(expr $h_old - $h))
    fi
fi

#---
# Inject selection geometry into cast command line and execute

cast_cmd=$1

if [ ! -z "$1" ]; then
    shift
    if [ ! -z "$use_format_string" ]; then
        while [ $# -gt 0 ]; do
            cast_args="$cast_args"" ""$(_format_to_string "$1")"
            shift
        done
    else
        case $cast_cmd in
            byzanz-record)   x11grab_opts="--x="$_x" --y="$_y" --width="$w" --height="$h" --display="$DISPLAY"" ;;
            ffmpeg)          x11grab_opts="-f x11grab -s "${w}x$h" -i "$DISPLAY+$_x,$_y"" ;;
            recordmydesktop) x11grab_opts="-display "$DISPLAY" -width "$w" -height "$h""
                             # As of recordMyDesktop 0.3.8.1, x- and y-offsets default to 0,
                             # but -x and -y don't accept 0 as an argument. #FAIL
                             expr $_x + 0 >/dev/null 2>/dev/null && x11grab_opts="$x11grab_opts"" ""-x "$_x""
                             expr $_y + 0 >/dev/null 2>/dev/null && x11grab_opts="$x11grab_opts"" ""-y "$_y"" ;;
            *) _error "invalid cast command: \`%s'" "$cast_cmd" ;;
        esac

        while [ $# -gt 0 ] && [ X"$1" != X"--" ]; do
            cast_args="$cast_args"" ""$1"
            shift
        done
        if shift; then
            cast_args="$cast_args"" ""$x11grab_opts"" ""$@"
        else
            cast_args="$x11grab_opts"" ""$cast_args"
        fi
    fi
else
    for supported_program in $(_list_cast_cmds); do
        if command -v "$supported_program" >/dev/null; then
            cast_cmd=$supported_program
            break
        fi
    done
    [ -z "$cast_cmd" ] && _error "none supported front-ends found!, install at least one of the following: $cast_cmd_pattern"
    cast_file=$HOME/$(</dev/urandom tr -dc A-Za-z0-9 | head -c 8).mkv
    cast_args="-r 25 -f x11grab -s "${w}x$h" -i "$DISPLAY+$_x,$_y" -vcodec libx264 "$cast_file""
fi

_debug_run "$cast_cmd" $cast_args
[ -z "$cast_file" ] && _notify "[+] Done" "$cast_cmd $cast_args" || _notify "[+] Done" "$cast_file"

# vim: set ts=8 sw=4 tw=0 ft=sh : 
