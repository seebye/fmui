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
lazy_declare FMUI_KEYS_SH || return
source "$PROJECT_ROOT/defaults.sh"
source "$PROJECT_ROOT/actions.sh"

mod="${mod:-$DEFAULT_MOD}"

key_bindings+=(
    [u]="$ACTION_UPDATE_PREVIEW"
    [v]="$ACTION_VISUALIZER"
    [j]="$ACTION_DOWN"
    [k]="$ACTION_UP"
    [down]="$ACTION_DOWN"
    [up]="$ACTION_UP"
#    [g]="$ACTION_SEEK_CUSTOM"
    [h]="$ACTION_SEEK_BACKWARDS"
    [l]="$ACTION_SEEK_FORWARDS"
    [left]="$ACTION_SEEK_BACKWARDS"
    [right]="$ACTION_SEEK_FORWARDS"
    [return]="$ACTION_PLAY_CHOICE"
    [p]="$ACTION_TOGGLE_PLAY"
    ['<']="$ACTION_PREV_SONG"
    ['>']="$ACTION_NEXT_SONG"
    [c]="$ACTION_TOGGLE_CONSUME"
    [s]="$ACTION_TOGGLE_SINGLE"
    [r]="$ACTION_TOGGLE_RANDOM"
    [${mod}-r]="$ACTION_TOGGLE_REPEAT"
    [${mod}-s]="$ACTION_SHUFFLE"
    [${mod}-d]="$ACTION_UPDATE_DB"
    [q]="$ACTION_QUIT"
    [i]="$ACTION_INFO"
)
