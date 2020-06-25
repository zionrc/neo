#!/usr/bin/env bash

##
# neo
# ---
# by Francesco Bianco
# bianco@javanile.org
# MIT License
##

set -e

show=
cache=
debug=
verbose=
registry=https://zionrc.github.io/index/tag/neo
signature=https://raw.githubusercontent.com/zionrc/neo/master/SHA256SUMS
checksum=$(curl -s "${signature}?ts=$(date +%s)" | grep neo.sh || true)
hint="try 'neo --help' for more information"
home=${HOME}/.zionrc/neo
version=0.0.17

info () {
    [[ -z ${verbose} ]] || echo "neo: $1"
    return 0
}

error () {
    echo "neo: $2"
    exit $1
}

warning () {
    echo "WARNING! $1"
    return 0
}

usage () {
    echo "Usage: neo [OPTION]... COMMAND TAG [ARGUMENT]..."
    echo "       neo [OPTION]... COMMAND"
    echo "       neo [OPTION]... -s TAG"
    echo ""
    echo "Run COMMAND and TAG from public registry https://github.com/zionrc/index"
    echo ""
    echo "List of available options"
    echo "  -x          Debug running script"
    echo "  -v          Display log"
    echo "  -c          Use cache"
    echo "  -s TAG      Show script from tag"
    echo "  -h, --help  Display this help and exit"
    echo "  --version   Display neo version"
    echo ""
    echo "Documentation can be found at https://github.com/zionrc/neo"
    exit 1
}

version () {
    echo "neo: (version=${version})"
    exit 1
}

show () {
    cat $1
    exit 0
}

[[ "$1" == "--help" ]] && usage
[[ "$1" == "--version" ]] && version

while getopts "hs:cxv" opt &> /dev/null; do
    last=$(( OPTIND-1 ))
    case "${opt}" in
        "h")
            usage ;;
        "s")
            show=${OPTARG} ;;
        "x")
            debug=-x ;;
        "v")
            verbose=1 ;;
        "c")
            cache=1 ;;
        "?")
            case "${!last}" in
                "-s")
                    error 2 "option '${!last}' require tag name, ${hint}." ;;
                *)
                    error 2 "illegal option '${!last}', ${hint}." ;;
            esac ;;
    esac
done

shift $(( OPTIND-1 ))
if [[ ! -z "${show}" ]]; then
    [[ ${#} -gt 0 ]] && error 2 "option '-s' too many arguments, ${hint}."
    set -- "show" "${show}"
fi

[[ -z "$1" ]] && error 2 "requires command and tag, ${hint}."

if [[ -z "$2" ]]; then
    info "(implicit) $1"
    set -- __implict__ $1
fi

[[ ${#2} -le 1 ]] && error 2 "tag '${2}' is too short, type at least 2 letters."

info "(checksum) ${checksum}"

if [[ -z "${usecache}" ]]; then
    if [[ -z "${checksum}" ]]; then
        error 3 "you are offline, use '-c' option to run from cache."
    else
        if [[ "$(sha256sum $0)" != "${checksum}  $0" ]]; then
            warning "Checksum error, upgrade to latest version."
        fi
    fi
fi

if [[ -f "$2" ]]; then
    matrix=$(cat $2)
elif [[ -z ${cache} ]]; then
    page="${registry}/${2:0:1}/${2:1:1}"
    track="$(curl -s "${page}?ts=$(date +%s)" | grep -m1 "^$2 *" || true)"

    if [[ -z "${track}" ]]; then
        error 3 "tag '$2' not found on '${page}' page."
    fi

    matrix="$(echo ${track} | cut -s -d' ' -f2)"
    checksum="$(echo ${track} | cut -s -d' ' -f3)"
    status=$(curl -sLI "${matrix}?ts=$(date +%s)" | grep "HTTP/1.1" | tail -1 | tr -dc 0-9 | tail -c 3)
    cache="${home}/cache/$2"

    if [[ "${status}" != "200" ]]; then
        error 4 "resource '${matrix}' bad http status ${status} required 200."
    fi

    matrix=$(curl -s "${matrix}?ts=$(date +%s)")

    mkdir -p "$(dirname "${cache}")"
    echo "${matrix}" > "${cache}"

    if [[ "$(sha256sum ${cache})" != "${checksum} ${cache}" ]]; then
        warning "Tag '$2' checksum error."
    fi
else
    cache="${home}/cache/$2"
    [[ -f "${cache}" ]] || error 3 "cache file '${cache}' not found."
    matrix=$(cat "${cache}")
fi

echo "${matrix}" | bash ${debug} -s -- "$1" "${@:3}"
