# Decisions — Amber's build of runic

This fork is upstream runic 0.8 plus the files that make it buildable today (`amber-0.8`) plus
the generator patches on the branch `amber-patched` (section 4). `README.md` is upstream's.

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

Beyond the faults patched in section 4, runic 0.8 leaves `gchar *` as `^char`, because it recognises a char pointer only when the
pointee is the built-in type and `gchar` is a typedef. The binding repos rewrite that, and
other gaps, in their own `scripts/postprocess.sh`; this fork does not change runic's output.

## 4. The patches on `amber-patched`

Each is one commit on `amber-0.8`, with tests; the first two are also offered upstream. Moving to a newer
upstream tag means rebasing these commits.

- **Declared arrays.** runic writes `[^]T` for any pointer whose C name ends in `s`. With
  `to.detect.parameters: declared` a procedure parameter is `^T` (`T **` is `^^T`) unless
  `to.detect.arrays` lists it. Without the key nothing changes.
- **va_list.** A procedure whose last parameter is a `va_list` is not emitted; the foreign block
  carries a comment naming it. Real `...` procedures are unchanged.
- **Evaluated macros.** runic keeps an object-like macro it cannot parse as one number as its C
  text, which the Odin output writes as a raw string: `(1L << 15)`, `0L` and `((Atom) 31)` become
  strings, not values. A macro that names a built-in type (`#define Bool int`) stays text too,
  and every struct with a member of that type is dropped as unknown. With
  `from.evaluate_macros: true` such a macro is a type alias of the built-in type, and the others
  are evaluated by clang, with the headers included so a cast to their types resolves: an
  integer or float result is the constant's value. A macro that is no constant expression (a
  keyword, an attribute) or an unsigned value past `i64` is dropped, with a line on stderr naming
  it; constants the rune ignores are left alone. A macro naming a built-in type in an included
  header counts as that header's type, so in an extern header it is an extern like a typedef there
  (XTest.h's `Bool` is Xlib.h's, `xlib.Bool`). Without the key nothing changes.
- **Array parameters.** runic types a parameter declared as an array, `char keys[32]`, as the
  array, which an Odin procedure passes by value; C passes a pointer to its elements. The
  outermost dimension loses its size and so is written as a multi-pointer (`[^]i8`; `int m[2][3]`
  is `[^][3]i32`), as a parameter declared without a size (`char keys[]`) already is, in
  procedures and in function-pointer types. Rejected: a pointer to one element (`^i8`), which
  cannot be indexed and changed every binding's `T x[]` parameters.
