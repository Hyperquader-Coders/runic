#!/usr/bin/env bash
# Build runic (tag 0.8) with the Odin pinned in mise.toml. Output: build/runic.
# libclang.so has no unversioned symlink on Mint 22, so one is made under build/lib.
set -euo pipefail
cd "$(dirname "$0")"
mkdir -p build/lib
ln -sf /usr/lib/llvm-18/lib/libclang.so.1 build/lib/libclang.so
mise exec -- odin build . -vet -warnings-as-errors -error-pos-style:unix \
	-collection:root=. -collection:shared=shared -out:build/runic -o:speed \
	-define:YAML_STATIC=true "-extra-linker-flags:-L$PWD/build/lib"
