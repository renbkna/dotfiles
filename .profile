# User binaries for the graphical session (greetd sources this) and bash login shells.
export PATH="$HOME/.local/bin:$HOME/.npm-global/bin:$PATH"

# Build acceleration for every build in the session: terminals, agents and GUI-launched tools.
# Projects that own their toolchain (ash&oat's native build) strip these. Cargo's compiler cache
# and build directory are in ~/.cargo/config.toml.
#
# sccache finds its config, and from it its cache, through the XDG_CONFIG_HOME and
# XDG_CACHE_HOME of whichever client starts its shared server. Pinning the config keeps a build
# under a sandboxed XDG environment (test harnesses) from moving every later build's cache into a
# throwaway directory.
export SCCACHE_CONF="$HOME/.config/sccache/config"
export CC=clang CXX=clang++
export CMAKE_C_COMPILER_LAUNCHER=sccache CMAKE_CXX_COMPILER_LAUNCHER=sccache
# One linker for C, C++ and Rust: mold linked Crabling's test binaries about twice as fast as
# rustc's default rust-lld (30 Oct 2026).
linker=mold
export LDFLAGS="-fuse-ld=$linker"
export CARGO_TARGET_X86_64_UNKNOWN_LINUX_GNU_LINKER=clang
export CARGO_TARGET_X86_64_UNKNOWN_LINUX_GNU_RUSTFLAGS="-Clink-arg=-fuse-ld=$linker"
unset linker
