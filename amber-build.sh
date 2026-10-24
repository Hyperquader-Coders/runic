#!/usr/bin/env bash
# Build runic from the Amber-patched fork: branch amber-patched (upstream 0.8 plus the
# patches, see DECISIONS.md) with the Odin pinned in mise.toml (dev-2026-05). Output: build/runic.
# `./amber-build.sh test` runs runic's own tests with the same Odin instead.
# libclang.so has no unversioned symlink on Mint 22, so one is made under build/lib.
set -euo pipefail
cd "$(dirname "$0")"
unset DISPLAY
echo "runic: Amber-patched fork, branch $(git branch --show-current), $(git rev-parse --short HEAD); Odin $(mise exec -- odin version 2>/dev/null | tail -1)" >&2
mkdir -p build/lib
ln -sf /usr/lib/llvm-18/lib/libclang.so.1 build/lib/libclang.so
flags=(-vet -warnings-as-errors -error-pos-style:unix -collection:root=. -collection:shared=shared
	-define:YAML_STATIC=true "-extra-linker-flags:-L$PWD/build/lib")
if [ "${1:-}" = test ]; then
	exec mise exec -- odin test . "${flags[@]}" -all-packages -out:build/runic_test -debug \
		-define:ODIN_TEST_THREADS=1 -define:ODIN_TEST_FANCY=false
fi
mise exec -- odin build . "${flags[@]}" -out:build/runic -o:speed
