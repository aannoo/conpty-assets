//! Microsoft's redistributable ConPTY binaries, embedded as byte slices.
//!
//! This is an unofficial asset package, not a PTY implementation or a Microsoft
//! product. Write both files from the same architecture module into one directory
//! before loading `conpty.dll`; it launches the adjacent `OpenConsole.exe`.
//! Applications must retain [`MICROSOFT_LICENSE`] when redistributing the files.
//!
//! No build script, runtime download, or native linking is performed.

#![no_std]

/// Version of the upstream `Microsoft.Windows.Console.ConPTY` NuGet package.
pub const VERSION: &str = "1.25.260930003";

/// Microsoft's copyright notice and MIT license for the embedded binaries.
pub const MICROSOFT_LICENSE: &str = include_str!("../LICENSE-MICROSOFT");

/// Binaries for x86-64 Windows. Both files are from the same upstream package.
pub mod x64 {
    /// Microsoft ConPTY DLL, unmodified and Authenticode-signed.
    pub const CONPTY_DLL: &[u8] = include_bytes!("../assets/x64/conpty.dll");

    /// Console host launched by [`CONPTY_DLL`], unmodified and signed.
    pub const OPENCONSOLE_EXE: &[u8] = include_bytes!("../assets/x64/OpenConsole.exe");
}
