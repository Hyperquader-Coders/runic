# Decisions — Amber's build of runic

This fork carries upstream runic unchanged, plus the files that make tag 0.8 buildable today.
The `amber` branch is upstream tag `0.8` (`9bd8391`) with one commit; `amber-0.8` marks it.
`README.md` and the source are upstream's.

## 1. Tag 0.8, built with Odin dev-2026-05

runic 0.8 does not compile on newer Odin: `odin/codegen/from.odin` names
`runtime.Odin_OS_Type.Haiku`, which Odin removed in dev-2026-06. `mise.toml` pins Odin
dev-2026-05, and `amber-build.sh` builds `build/runic` with it:

```
git checkout amber-0.8
./amber-build.sh
```

It needs `libyaml-dev` and libclang 18; the script links `libclang.so.1` without a system
symlink. The binary prints `runic 0.7`: upstream's `version.odin` was not bumped for the tag.

## 2. Upstream master was not used

`master` is two commits past 0.8; they fix the `Haiku` reference and touch nothing else in
code generation. It was not adopted because 0.8 is the version the Amber bindings were
generated and checked with. A new upstream tag moves the pin deliberately: tag it
`amber-<version>`, update `mise.toml`, regenerate the bindings and compare the output.

## 3. What the bindings still need after runic

runic 0.8 leaves `gchar *` as `^char`, because it recognises a char pointer only when the
pointee is the built-in type and `gchar` is a typedef. The binding repos rewrite that, and
other gaps, in their own `scripts/postprocess.sh`; this fork does not change runic's output.
