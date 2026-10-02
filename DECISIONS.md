# Decisions — Amber's build of runic

This fork is upstream runic 0.8 plus the files that make it buildable today (`amber-0.8`) plus
two generator patches on the branch `amber-patched` (section 4). `README.md` is upstream's.

## 1. Tag 0.8, built with Odin dev-2026-05

runic 0.8 does not compile on newer Odin: `odin/codegen/from.odin` names
`runtime.Odin_OS_Type.Haiku`, which Odin removed in dev-2026-06. `mise.toml` pins Odin
dev-2026-05, and `amber-build.sh` builds `build/runic` with it:

```
git checkout amber-patched
./amber-build.sh          # build/runic;  ./amber-build.sh test  runs runic's tests
```

It needs `libyaml-dev` and libclang 18; the script links `libclang.so.1` without a system
symlink. The binary prints `runic 0.7`: upstream's `version.odin` was not bumped for the tag.

## 2. Upstream master was not used

`master` is two commits past 0.8; they fix the `Haiku` reference and touch nothing else in
code generation. It was not adopted because 0.8 is the version the Amber bindings were
generated and checked with. A new upstream tag moves the pin deliberately: tag it
`amber-<version>`, update `mise.toml`, regenerate the bindings and compare the output.

## 3. What the bindings still need after runic

Beyond the two faults patched in section 4, runic 0.8 leaves `gchar *` as `^char`, because it recognises a char pointer only when the
pointee is the built-in type and `gchar` is a typedef. The binding repos rewrite that, and
other gaps, in their own `scripts/postprocess.sh`; this fork does not change runic's output.

## 4. The two patches on `amber-patched`

Each is one commit on `amber-0.8`, with tests, and is also offered upstream; moving to a newer
upstream tag means rebasing the two commits.

- **Declared arrays.** runic writes `[^]T` for any pointer whose C name ends in `s`. With
  `to.detect.parameters: declared` a procedure parameter is `^T` (`T **` is `^^T`) unless
  `to.detect.arrays` lists it. Without the key nothing changes.
- **va_list.** A procedure whose last parameter is a `va_list` is not emitted; the foreign block
  carries a comment naming it. Real `...` procedures are unchanged.
