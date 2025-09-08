See default keymap for detailed layout diagram. This layout is basically that plus

- Tab also functions as Windows/Super key when held down
- No Dvorak or Coleman mappings/layers


```bash
#!/bin/bash
set -euf -o pipefail

KEYMAP="${KEYMAP:-exia}"  # Default to exia if not already set by env var
BOARD=splitkb/kyria/rev1
ARGS=(-kb "$BOARD" -km "$KEYMAP")
DOCKER_RUN_ARGS=(
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

read -p "flash? [y,n]: " -N 1 flash
if [ "$flash" = "y" ]
then
  COMMAND=flash
  ARGS+=(-bl avrdude)
else
  COMMAND=compile
fi

set -x
exec "${DOCKER_RUN_ARGS[@]}" "$COMMAND" "${ARGS[@]}"
```
