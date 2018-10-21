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
declare -p FMUI_ESSENTIALS_SH &>/dev/null && return
readonly FMUI_ESSENTIALS_SH


readonly GLOBAL='-g'
readonly ARRAY='-a'
readonly MAP='-A'
readonly IS_DIRECTORY='-d'
readonly IS_FILE='-f'
readonly IS_FIFO='-p'
readonly EXISTS='-e'


function lazy_declare {
    # declares a variable name if it does not exists
    # returns true / 0 if the variable was declared
    # (useful to make dependencies clearly visible
    #  without executing scripts multiple times)
    declare -p "$@" &>/dev/null
    local name_exists=$?

    (( $name_exists != 0 )) && {
        readonly "$@"
        return 0
    }

    return 1
}

