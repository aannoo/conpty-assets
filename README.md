# conpty-assets

An unofficial Rust package containing Microsoft's unmodified, signed ConPTY
redistributable binaries as byte slices. This package is independently maintained
and is not affiliated with or endorsed by Microsoft.

Upstream: [`Microsoft.Windows.Console.ConPTY` **1.25.260930003**](https://www.nuget.org/packages/Microsoft.Windows.Console.ConPTY/1.25.260930003).
Currently includes **x64** only. This is an asset package: it does not create
pseudoterminals, load DLLs, or perform downloads during builds or at runtime.

```rust,no_run
let directory = std::path::Path::new("conpty");
std::fs::create_dir_all(directory)?;
std::fs::write(directory.join("conpty.dll"), conpty_assets::x64::CONPTY_DLL)?;
std::fs::write(directory.join("OpenConsole.exe"), conpty_assets::x64::OPENCONSOLE_EXE)?;
std::fs::write(directory.join("LICENSE"), conpty_assets::MICROSOFT_LICENSE)?;
# Ok::<(), std::io::Error>(())
```

Load the DLL from that directory using your application's PTY backend. Keep the
DLL and EXE together; mixing binaries from different upstream versions is not
supported. The package can be a Windows-only Cargo dependency. Applications
choose which architecture's bytes to embed.

## Provenance and licensing

The binaries come from the official Microsoft NuGet package and are redistributed
under its MIT license; Microsoft's copyright and permission notice are in
`LICENSE-MICROSOFT` and available as `MICROSOFT_LICENSE`. Preserve that notice when
redistributing the binaries. The Rust wrapper is also MIT licensed; see `LICENSE`.

Exact source paths and SHA-256 hashes are recorded in `upstream.json`:

| File | SHA-256 |
|---|---|
| `assets/x64/conpty.dll` | `feeef341d891643c62d30b6b07800bc70f0bc148f44cb8c3bee84aa557ae805a` |
| `assets/x64/OpenConsole.exe` | `3d66b23d0a71bb8eed2b77edc8b9df9bf54ce6c8fb74c863a30e760997f80586` |

## Maintaining this package

The binary assets are included in the published crate, but ignored by Git.
Only maintainers building this crate from its source checkout need to run:

```powershell
pwsh -NoProfile -File ./fetch.ps1
cargo publish --dry-run --allow-dirty   # assets are git-ignored but packaged
```

The script downloads the pinned NuGet package and verifies both extracted files
before putting them in `assets/x64`. An existing matching cache requires no
download. `cargo clean` does not remove those files.

To update, verify Microsoft's new package and signatures, update `upstream.json`,
`VERSION` in `src/lib.rs`, and this README, then bump the crate version and publish.
Consumers of the published crate need no setup script or NuGet installation.
