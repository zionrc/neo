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
debug=
verbose=
usecache=
registry=https://zionrc.github.io/registry/tag/neo
signature=https://raw.githubusercontent.com/zionrc/neo/master/neo.sig
checksum=$(curl -s "${signature}?ts=$(date +%s)" || true)
hint="try 'neo --help' for more information"
version=16

info () {
    [[ -z ${verbose} ]] || echo -e "\e[33mneo: $1\e[0m"
    return 0
}

error () {
    echo -e "\e[31mneo: $2\e[0m"
    exit $1
}

warning () {
    echo -e "\e[31mneo: $1\e[0m"
    return 0
}

usage () {
    echo "Usage: neo [OPTION]... COMMAND TAG [ARGUMENT]..."
    echo "       neo [OPTION]... -s TAG"
    echo ""
    echo "Run COMMAND and TAG from public registry https://github.com/zionrc/registry"
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
            usecache=1 ;;
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
[[ -z "$2" ]] && error 2 "requires tag, ${hint}."

[[ ${#2} -le 1 ]] && error 2 "tag '${2}' is too short, type at least 2 letters."

info "(checksum) ${checksum}"

if [[ -z "${usecache}" ]]; then
    if [[ -z "${checksum}" ]]; then
        error 3 "you are offline, use '-c' option to run from cache."
    else
        if [[ "$(sha256sum $0)" != "${checksum}  $0" ]]; then
            warning "checksum error, upgrade to latest version."
        fi
    fi
fi

if [[ -f "$2" ]]; then
    cache="$2"
else
    cache="${HOME}/.zionrc_cache/$2"
    info "(cache) ${cache}"

    if [[ -z ${usecache} ]]; then
        page="${registry}/${2:0:1}/${2:1:1}"
        line="$(curl -s "${page}?ts=$(date +%s)" | grep -m1 "^$2 *" || true)"

        if [[ -z "${line}" ]]; then
            error 3 "tag '$2' not found on '${page}' page."
        fi

        file="$(echo ${line} | cut -s -d' ' -f2)"
        hash="$(echo ${line} | cut -s -d' ' -f3)"

        info "curl: ${file}"
        mkdir -p "${HOME}/.zionrc_cache"
        curl -o ${cache} -s "${file}?ts=$(date +%s)" || true

        if [[ "$(sha256sum ${cache})" != "${hash}  ${cache}" ]]; then
            error 3 "tag '$2' checksum error."
        fi
    fi
fi

## Check cache file
[[ -f "${cache}" ]] || error 3 "cache file '${cache}' not found."
[[ -z "${show}" ]] || show ${cache}

## Prepare script header
header="set -- \"$1\""
for arg in "${@:3}"; do header+=" \"${arg}\""; done
info "(header) ${header}"

## Execute script
bash ${debug} - <( echo "${header}"; cat "${cache}" )
