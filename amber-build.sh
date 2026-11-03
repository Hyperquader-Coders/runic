#!/usr/bin/env bash
# Builds runic 0.8 with patches: build/runic, or `./amber-build.sh test` for runic's own tests.
# Odin is pinned to dev-2026-05 in mise.toml: 0.8 names runtime.Odin_OS_Type.Haiku, which
# later Odin removed. The binary still prints "runic 0.7", as upstream's version.odin does.
# The patches, each opt-in or a fix: procedures taking a va_list are skipped; procedure
# parameters may keep their declared arrays; macros may be evaluated, and a macro naming a type
# is that type, in an extern header too; array parameters become multi-pointers.
# Needs libyaml-dev and libclang 18; libclang.so has no unversioned symlink on Mint 22, so one
# is made under build/lib.
set -euo pipefail
cd "$(dirname "$0")"
unset DISPLAY
echo "runic: Amber-patched fork, $(git rev-parse --short HEAD); Odin $(mise exec -- odin version 2>/dev/null | tail -1)" >&2
mkdir -p build/lib
ln -sf /usr/lib/llvm-18/lib/libclang.so.1 build/lib/libclang.so
flags=(-vet -warnings-as-errors -error-pos-style:unix -collection:root=. -collection:shared=shared
	-define:YAML_STATIC=true "-extra-linker-flags:-L$PWD/build/lib")
if [ "${1:-}" = test ]; then
	exec mise exec -- odin test . "${flags[@]}" -all-packages -out:build/runic_test -debug \
		-define:ODIN_TEST_THREADS=1 -define:ODIN_TEST_FANCY=false
fi
mise exec -- odin build . "${flags[@]}" -out:build/runic -o:speed
