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
    echo "neo: $1"
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
            warning "checksum error, upgrade to latest version."
        fi
    fi
fi

if [[ -f "$2" ]]; then
    cache=$(cat $2)
else
    cache="${HOME}/.zionrc_cache/$2"
    info "(cache) ${cache}"

    if [[ -z ${cache} ]]; then
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

echo "${cache}" | bash ${debug} -s -- "${@:2}"
