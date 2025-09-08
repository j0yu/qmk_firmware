#!/bin/bash
set -euf -o pipefail

RUNTIME=podman  # or docker
BOARD=splitkb/kyria/rev1
KEYMAP="${KEYMAP:-exia}"  # Default to exia if not already set by env var
ARGS=(-kb "$BOARD" -km "$KEYMAP")
RUN_ARGS=(
  podman run
  --rm -it --privileged -v /dev:/dev
  -w /qmk_firmware
  -v "$(git rev-parse --show-toplevel)":/qmk_firmware:z
  -e SKIP_GIT=" "
  -e SKIP_VERSION=" "
  -e MAKEFLAGS=" "
  ghcr.io/qmk/qmk_cli
  qmk
)

COMMAND=""
for ARG in "$@"
do
    case "$ARG" in
        --flash) COMMAND=flash;;
        --compile) COMMAND=compile;;
    esac
done

if [ -z "${COMMAND:-}" ]
then
    read -p "flash? [y,n]: " -N 1 flash
    if [ "$flash" = "y" ]
    then COMMAND=flash
    else COMMAND=compile
    fi
fi

if [ "$COMMAND" == flash ]
then
    ARGS+=(-bl avrdude)
fi

set -x
exec sudo "${RUN_ARGS[@]}" "$COMMAND" "${ARGS[@]}"
