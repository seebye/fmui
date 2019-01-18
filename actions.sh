# This file is part of fzf mpd user interface (FMUI).
#
# FMUI is free software: you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation, either version 3 of the License, or
# (at your option) any later version.
#
# Foobar is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License
# along with Foobar.  If not, see <http://www.gnu.org/licenses/>.
source "$PROJECT_ROOT/essentials.sh"
lazy_declare FMUI_ACTIONS_SH || return
source "$PROJECT_ROOT/defaults.sh"


function ord {
  LC_CTYPE=C printf '%d' "'$1"
}


function key_hook {
    INPUT_SHELL_PID=$!

    while read -rsn 1 c &>/dev/null ; do
        cmd=`printenv key_bindings_global_$(ord $c)`

        if (( $? == 0 )); then
            eval "${cmd}" &> /dev/null

            if (( $# > 0 )); then
                echo -n "$@"
            fi
        else
            echo -n "$c"

            if [[ $c == 'q' ]]; then
                # Without process substitution
                # the output of the visualizer corrupts
                # as soon as a key was pressed.
                # However with process substitution we need to press
                # another key after pressing q so we need to kill
                # the created input shell to avoid this bug.
                [[ "$INPUT_SHELL_PID" != "" ]] && 
                    kill $INPUT_SHELL_PID &> /dev/null
                break
            fi
        fi
    done
}


readonly ACTION_QUIT='abort'
readonly ACTION_RESTART='accept'
readonly ACTION_UPDATE_PREVIEW="toggle-preview+toggle-preview"
readonly ACTION_HIDE_COVER="execute-silent(Cover::if_running remove_image)"
readonly ACTION_UPDATE_DB="execute-silent(mpc update --wait)+$ACTION_RESTART"
readonly ACTION_UP='up'
readonly ACTION_DOWN='down'
readonly ACTION_SHUFFLE="execute(mpc shuffle)+$ACTION_RESTART"
readonly ACTION_SEEK_BACKWARDS="execute-silent:mpc seek -${seek_step:-${DEFAULT_SEEK_STEP}}"
readonly ACTION_SEEK_FORWARDS="execute-silent:mpc seek +${seek_step:-${DEFAULT_SEEK_STEP}}"
readonly ACTION_SEEK_CUSTOM="execute:clear 1>&2; read step <`tty` ; mpc seek \$step"
readonly ACTION_PREV_SONG='execute-silent:mpc prev'
readonly ACTION_NEXT_SONG='execute-silent:mpc next'
readonly ACTION_PLAY_CHOICE='execute-silent:mpc play {1}'
readonly ACTION_TOGGLE_PLAY='execute-silent:mpc toggle'
readonly ACTION_TOGGLE_CONSUME="execute-silent(mpc consume)+$ACTION_UPDATE_PREVIEW"
readonly ACTION_TOGGLE_SINGLE="execute-silent(mpc single)+$ACTION_UPDATE_PREVIEW"
readonly ACTION_TOGGLE_RANDOM="execute-silent(mpc random)+$ACTION_UPDATE_PREVIEW"
readonly ACTION_TOGGLE_REPEAT="execute-silent(mpc repeat)+$ACTION_UPDATE_PREVIEW"
readonly ACTION_VISUALIZER="$ACTION_HIDE_COVER+execute({ key_hook < <(<`tty`) | ${visualizer:-$DEFAULT_VISUALIZER}; } 1>&2)+$ACTION_UPDATE_PREVIEW"
# key_hook n # -> print n on executing a command, read a key -> redraw info
readonly ACTION_INFO="$ACTION_HIDE_COVER+execute({ key_hook n | Info::main; } <`tty` 1>&2)+$ACTION_UPDATE_PREVIEW"
