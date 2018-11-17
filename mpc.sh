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
lazy_declare FMUI_MPC_SH || return
source "$PROJECT_ROOT/defaults.sh"


function Mpc::get_raw_song_info {
    mpc | grep --perl-regexp ']\s*#'
}


function Mpc::get_song_progress {
    Mpc::get_raw_song_info | \
        grep --only-matching --perl-regexp '(?<=\()[0-9]+(?=%)'
}


function Mpc::get_song_duration {
    local duration=`mpc current --format "%time%"`
    local seconds=$(( 
        $(( 10#`grep --only-matching --perl-regexp '([0-9]+)(?=:)' <<< "$duration"` * 60 )) +
        10#`grep --only-matching --perl-regexp '(?<=:)([0-9]+)' <<< "$duration"` ))
    echo -n "${seconds:-1}"
}


function Mpc::get_song_name {
    mpc current --format "${song_format:-${DEFAULT_SONG_FORMAT}}"
}


function Mpc::get_options {
    mpc | grep "volume" | sed 's|:\([^ ]\)|: \1|' | head --lines 1
}


function Mpc::get_playlist {
    mpc playlist --format "%position%. ${song_list_format:-$DEFAULT_SONG_LIST_FORMAT}"
}


function Mpc::get_playlist_filename {
    mpc playlist --format '%file%' | head --lines "$1" | tail --lines 1
}


function Mpc::update-queue {
    # adds every song to the queue if it's not already part of it
    diff --unchanged-group-format="" --new-group-format="%>" \
        <(mpc playlist --format '%file%' | sort) <(mpc ls --format '%file%' | sort) | \
        mpc add &>/dev/null
}


function Mpc::clear-queue {
    mpc clear &>/dev/null
}
