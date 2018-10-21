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
lazy_declare FMUI_COVER_SH || return
type ueberzug &>/dev/null &&
    source "`ueberzug library`"
source "$PROJECT_ROOT/defaults.sh"


readonly Cover_ID='preview'
readonly Cover_FIFO="${DIR_TMP}/${$}-fmui-ueberzug"


function ffmpeg {
    if type ffmpeg &>/dev/null; then
        command ffmpeg "$@" 
    else
        command avconv "$@"
    fi
}


function ffprobe {
    if type ffprobe &>/dev/null; then
        command ffprobe "$@" 
    else
        command avprobe "$@"
    fi
}


function File::get_mime_type {
    file --brief --mime-type "$@"
}


function Video::extract_random_frame {
    local max_width="$1" path_video="$2" path_image="$3"
    local duration="`ffmpeg -i "$path_video" 2>&1 | grep 'Duration: ' | \
                        grep --only-matching --perl-regexp '(\d+):(\d+):(\d+)'`"
    local hour="${duration:0:2}" minute="${duration:3:2}" second="${duration:6:2}"
    local seconds=$(( second + minute * 60 + hour * 60 * 60 ))
    ffmpeg -y -ss $(( ( (RANDOM<<15) | RANDOM ) % seconds + 0 )) \
           -i "$path_video" -vframes 1 -vf "scale=${max_width}:-1" \
           "$path_image" &>/dev/null
}


function Music::contains_album_cover {
    ffprobe "$@" 2>&1 | grep --ignore-case 'Album cover' &>/dev/null
}


function Music::extract_album_cover {
    local max_width="$1" path_music="$2" path_image="$3"
    ffmpeg -y -i "$path_music" -vf "scale=${max_width}:-1" "$path_image" &>/dev/null
}


function Cover::create_image {
    local max_width="$1" path_file="$2" path_output="$3"

    case "`File::get_mime_type "$path_file"`" in
        video/*)
            Video::extract_random_frame "$max_width" "$path_file" "$path_output"
            ;;
        audio/*)
            Music::contains_album_cover "$path_file" && \
                Music::extract_album_cover "$max_width" "$path_file" "$path_output"
            ;;
    esac
}


function Cover::set_image {
    ImageLayer::add [identifier]="$Cover_ID" [x]="0" [y]="0" \
                    [max_width]="${cover_max_columns:-$DEFAULT_COVER_MAX_COLUMNS}" \
                    [path]="$@" \
                    >"$Cover_FIFO"
}


function Cover::remove_image {
    ImageLayer::remove [identifier]="$Cover_ID" \
                        >"$Cover_FIFO"
}


function Cover::if_running {
    [ $EXISTS "$Cover_FIFO" ] && {
        cmd="$1"; shift
        "Cover::$cmd" "$@"
    }
}


function Cover::on_selection_changed {
    local filename="`Mpc::get_playlist_filename "$1"`"
    local path_file="${DIR_MUSIC}/$filename"
    local width="${cover_max_width:-$DEFAULT_COVER_MAX_WIDTH}"
    local path_output="${DIR_CACHE}/${1}-${width}-${filename//[^0-9a-zA-Z]/}.jpg"

    [ ! $IS_FILE "$path_output" ] && {
        mkdir --parents "$DIR_CACHE"
        Cover::create_image "$width" "$path_file" "$path_output"
    }

    if [ $IS_FILE "$path_output" ]; then
        Cover::set_image "$path_output"
    else
        Cover::remove_image
    fi
}


function Cover::start_ueberzug {
    mkfifo "$Cover_FIFO"
    ImageLayer --silent <"$Cover_FIFO" &
    # prevent EOF
    exec 3>"$Cover_FIFO"
}


function Cover::stop_ueberzug {
    exec 3>&-
    rm "$Cover_FIFO" &>/dev/null
}
