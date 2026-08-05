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

| Build | What it does | Config size |
|-------|--------------|-------------|
| azazel | builds `vaxis` from source + a consumer; uucode `fields` as data | `project.cue`, 23 lines |
| zaza | consumes `vaxis` via the Zig build graph, runs a consumer | `build.zig`,       28 lines |
| upstream (native) | libvaxis's own full `zig build` | `build.zig`,      161 lines |

### Organizational structure

- **azazel** states the whole target as data, including which uucode tables to
  compile (the `fields` list). It builds the library from source.
- **zaza** consumes the library as a Zig dependency. Its position is that pure
  Zig is a first-class case handled by the standard Zig build graph, so there is
  no separate DSL to learn for a Zig dependency.

See [`zaza/PROOF.md`](zaza/PROOF.md) for the command-for-command zaza proof.
