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
lazy_declare FMUI_INFO_SH || return
source "$PROJECT_ROOT/mpc.sh"


function Screen::move_cursor {
    tput cup "$@"
}


function Screen::set_foreground {
    tput setaf "$@"
}


function Screen::hide_cursor {
    tput civis
}


function Screen::show_cursor {
    tput cnorm
}


function Screen::new_screen {
    tput smcup
}


function Screen::restore_screen {
    tput rmcup
}


function Screen::enable_echo {
    stty echo
}


function Screen::disable_echo {
    stty -echo
}


function Info::cleanup {
    Screen::enable_echo
    Screen::show_cursor
    Screen::restore_screen
}


function build_ascii_art {
    declare $ARRAY ascii_art_char
    local width=`tput cols`
    local name="$@"
    local last_char='' char
    
    for (( i=0; i<${#song[@]}; i++ )); do
        song[$i]=""
    done

    for (( i=0; i<${#name}; i++ )); do
        char="${name:$i:1}"
        IFS=$'\n' ascii_art_char=($(toilet --font future --width $width <<< "$char" ))

        if ! [[ "$char" =~ [a-zA-Z0-9\ ÄÖÜäöüß\"\$\(\)*+/:\;=@?_\`\|\&{}-] ]] ||
             [[ "$char" == ' ' && ( "$last_char" == ' ' || "$last_char" == '' ) ]]; then
                continue
        fi

        if (( ${#song[0]} + ${#ascii_art_char[0]} > $width )); then
            break
        fi
        
        for (( j=0; j<${#song[@]}; j++ )); do
            song[$j]+="${ascii_art_char[$j]}"
        done
        
        last_char="$char"
    done
}


function Info::main {
    readonly MILLISECS_PER_SECOND=1000
    readonly COLOR_PLAYED=15
    readonly COLOR_OUTSTANDING=8
    readonly COLOR_NORMAL=8
    declare $GLOBAL $ARRAY song=('' '' '')
    local current_song last_song
    local offset_x offset_y offset_x_normal
    local timeout=1 timeout_seconds timeout_millisecs
    local progress
    local timeout=$(( `Mpc::get_song_duration` / 100 ))

    trap "last_song=''" WINCH
    trap "Info::cleanup" EXIT
    Screen::new_screen
    Screen::hide_cursor
    Screen::disable_echo

    while
        # do
        current_song="`Mpc::get_song_name`"

        if [[ ! -z "$current_song" ]]; then
            if [[ "$current_song" != "$last_song" ]]; then
                last_song="$current_song"
                build_ascii_art "$current_song"

                offset_x=$(( `tput cols` / 2 - ${#song[0]} / 2 ))
                offset_y=$(( `tput lines` / 2 - ${#song[@]} / 2 ))
                #offset_x_normal=$(( `tput cols` / 2 - ${#current_song} / 2 ))

                timeout_millisecs=$(( MILLISECS_PER_SECOND * `Mpc::get_song_duration` / ${#song[0]} ))
                timeout_seconds=$(( timeout_millisecs / MILLISECS_PER_SECOND ))
                timeout_millisecs=$(( timeout_millisecs % MILLISECS_PER_SECOND ))
                timeout="${timeout_seconds}.${timeout_millisecs}"

                clear
            fi
        
            progress=$(( ${#song[0]} * `Mpc::get_song_progress` / 100 ))

            for (( y=0; y<${#song[@]}; y++ )); do
                local line="${song[$y]}"
                Screen::move_cursor $(( offset_y + y )) $offset_x

                Screen::set_foreground $COLOR_PLAYED
                echo -n "${line:0:$progress}"
                Screen::set_foreground $COLOR_OUTSTANDING
                echo -n "${line:$progress:${#line}}"
            done
        
            Screen::move_cursor $(( offset_y + ${#song[@]} )) $offset_x
            Screen::set_foreground $COLOR_NORMAL
            echo "$current_song"
        fi

        # while
        read -rsn 1 -t $timeout input_char
        [[ "$input_char" != "q" ]]
    do continue ; done

    Info::cleanup
}
