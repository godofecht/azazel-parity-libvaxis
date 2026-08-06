# azazel-parity-libvaxis

[libvaxis](https://github.com/rockorager/libvaxis) built two ways, to prove and
compare [azazel](https://github.com/godofecht/azazel) and
[zaza](https://github.com/godofecht/zaza) against a real upstream project.

libvaxis is pure Zig with two package dependencies: `zigimg` and `uucode`.
`uucode` compiles only the Unicode data tables a consumer names, so both builds
select the same four: `east_asian_width`, `grapheme_break`,
`general_category`, `is_emoji_presentation`.

- **azazel** builds the `vaxis` library from source (declared as a CUE model,
  with the uucode `fields` as data) and a consumer that calls
  `vaxis.gwidth.gwidth`.
- **zaza** consumes `vaxis` through the standard Zig build graph it is built on,
  and runs the same `gwidth` consumer. libvaxis has no C/C++, so zaza's C/C++
  target DSL does not apply here; the Zig build system it provides does.

Neither vendors upstream sources.

## Pinned upstream

| | |
|---|---|
| Repository | https://github.com/rockorager/libvaxis |
| Commit | `5ca495f09f413c66789d9c5061359b941a8d82c2` (vaxis 0.6.0) |
| Zig | 0.16.0; deps `zigimg` + `uucode` (pinned) |

## Build it

```sh
# azazel: build vaxis from source and run a gwidth consumer
cd azazel && ./fetch.sh && sh gen_build_spec.sh && zig build && ./zig-out/bin/consumer

# zaza: consume vaxis via the Zig build graph and run the same consumer
cd zaza && zig build run
```

Both print `gwidth ascii=1 wide=2 combining=1` and `generated Unicode table OK`,
which means vaxis, zigimg, and the build-time uucode tables all compiled.

## Comparison

Clean-cache builds with dependencies pre-fetched, Apple Silicon, fastest of two runs.
`native` is the upstream's own `zig build`.

| Build | Clean build | Config |
|-------|-------------|--------|
| azazel | 6.7 s | `project.cue` — 23 lines · 768 B |
| zaza | 6.5 s | `build.zig` — 28 lines · 1135 B |
| native (the upstream's own `zig build`) | 7.7 s | — |

**Both build the vaxis library (and the uucode Unicode tables) faster than libvaxis builds itself.**


## Build process & what can be optimized

Both build roots stage the pinned upstream with `fetch.sh` into a git-ignored
`vendor/` (a `curl` for single-file slices, a shallow clone for source trees) —
no upstream sources are committed. Then:

- **azazel**: `sh gen_build_spec.sh` runs CUE and emits `build_spec.zig` (the
  build declared as data), then `zig build` compiles it. The CUE step is
  memoized — it re-runs only when the model changes (~0.20s → ~0.01s otherwise).
- **zaza**: `zig build` drives the standard Zig build graph directly.

### What actually makes it faster

Measured across the corpus (clean vs warm builds):

| Lever | Speedup | Note |
|-------|---------|------|
| Content-addressed cache (rebuild) | **89×** | 14.2s → 0.16s; Zig has it, both inherit it |
| Incremental (edit one file) | **10.8×** | 14.2s → 1.32s; deps stay cached |
| CI dependency cache | **2×** | cold 13.3s → warm 6.6s; this repo's CI caches `~/.cache/zig` |
| Memoized CUE codegen | **20×** | azazel's only overhead, gone |
| Parallelism (many cores) | **1.1×** | marginal — shared `std` + startup dominate |
| GPU | none | compilation is branchy, sequential, dependency-ordered |

The instinct to parallelize like a C++ build doesn't transfer: Zig is one
mostly-single-threaded compile per artifact with a fast self-hosted backend and a
shared `std` that caches. **For Zig, caching is the lever, not parallelism.**

The real frontier is *residency*: a resident compile server that keeps the
InternPool hot and recompiles only changed declarations, plus in-place binary
patching (Zig's roadmap) and a shared content-addressed cache. azazel's
build-as-data is positioned for it — the build is a query, and the cache key is
computable from the pinned model without running the compiler. Full write-up and
the cross-repo comparison: the [corpus dashboard](https://claude.ai/code/artifact/8c37ee83-b358-4351-a1e0-eb02ec0aedd4).
