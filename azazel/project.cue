// Azazel builds libvaxis's `vaxis` library from src/main.zig (declared as data)
// and a consumer that exercises it. vaxis imports zigimg and uucode; uucode
// compiles only the tables named via pkg_imports `fields`. Source staged by
// ./fetch.sh into vendor/libvaxis (git-ignored). Lane 0.16.
package build

toolchain: zig: {
	lanes: ["0.16"]
	preferred: "0.16"
}

vaxis: #Module & {
	kind: "module"
	root: "vendor/libvaxis/src/main.zig"
	pkg_imports: [
		{alias: "zigimg", package: "zigimg", module: "zigimg"},
		{
			alias:   "uucode"
			package: "uucode"
			module:  "uucode"
			fields: ["east_asian_width", "grapheme_break", "general_category", "is_emoji_presentation"]
		},
	]
}

consumer: #Module & {
	kind: "exe"
	root: "src/consumer.zig"
	deps: ["vaxis"]
}
