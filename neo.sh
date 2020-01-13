#!/bin/bash

##
# neo
# ---
# by Francesco Bianco
# bianco@javanile.org
# MIT License
##

set -e

debug=
verbose=
usecache=
registry=https://zionrc.github.io/registry/tag
checksum=https://raw.githubusercontent.com/zionrc/neo/master/neo.sig
status=$(curl -s "${checksum}?ts=$(date +%s)" || true)
hint="try 'neo --help' for more information"

echo "S: ${status}"

info () {
    [[ -z ${verbose} ]] || echo -e "\e[33minfo: $1\e[0m"
    return 0
}

error () {
    echo -e "\e[31mneo: $2\e[0m"
    exit $1
}

usage () {
    echo "Usage: neo [OPTION]... COMMAND TAG [ARGUMENT]..."
    echo "Run command and tag from public registry https://github.com/zionrc/registry"
    exit 1
}

[[ "$1" == "--help" ]] && usage

while getopts "hcxv" opt &> /dev/null; do
    last=$(( OPTIND-1 ))
    case "${opt}" in
        h) usage ;;
        x) debug=-x ;;
        v) verbose=1 ;;
        v) usecache=1 ;;
        ?) error 2 "illegal option '${!last}', ${hint}." ;;
    esac
done

shift $(( OPTIND-1 ))

if [[ -z "${usecache}" ]]; then
    if [[ -z "${status}" ]]; then
        error 3 "you are offline, use '-c' option to run from cache."
    else
        if [[ "$(sha256sum $0)" != "${checksum}  $0" ]]; then
            error 4 "neo checksum error, upgrade to latest version."
        fi
    fi
fi

[[ -z "$1" ]] && error 2 "requires command and tag, ${hint}."
[[ -z "$2" ]] && error 2 "requires tag, ${hint}."

[[ ${#2} -le 1 ]] && error 2 "tag '${2}' is too short, type at least 2 letters."

if [[ -f "$2" ]]; then
    script="$2"
    source=$(cat "${script}")
else
    page="${registry}/${2:0:1}/${2:1:1}"
    line="$(curl -s "${page}?ts=$(date +%s)" | grep -m1 "^$2 *" || true)"

    if [[ -z "${line}" ]]; then
        error 3 "tag '$2' not found on '${page}' page."
    fi

    cache="${HOME}/.zionrc_cache/$2"
    script="$(echo ${line} | cut -s -d' ' -f2)"
    hash="$(echo ${line} | cut -s -d' ' -f3)"

    mkdir -p "${HOME}/.zionrc_cache"
    info "curl: ${script}"
    curl -o ${cache} -s "${script}?ts=$(date +%s)"

    if [[ "$(sha256sum ${cache})" != "${hash}  ${cache}" ]]; then
        error 3 "tag '$2' checksum error."
    fi
fi

## Prepare script header
header="set -- \"${script}\" \"$1\""
for arg in "${@:3}"; do header+=" \"${arg}\""; done
info "(header) ${header}"

## Execute script
bash ${debug} - <( echo "${heaeder}"; cat "${cache}" )
