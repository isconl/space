#!/usr/bin/env bash
# space/install.sh
set -euo pipefail
_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
_BIN="$_ROOT/cli/bin"
_USER_BIN="${HOME}/bin"
_RC="${HOME}/.bashrc"

printf '\n  space install\n  ─────────────────\n\n'
mkdir -p "$_USER_BIN"
chmod +x "$_BIN/"*

if ! grep -qF "$_BIN" "$_RC" 2>/dev/null; then
    printf '\n# isconl/space\nexport PATH="$PATH:%s"\n' "$_BIN" >> "$_RC"
    printf '  +  Added to PATH\n'
else
    printf '  ✓  Already in PATH\n'
fi

for f in "$_BIN/"*; do
    ln -sf "$f" "$_USER_BIN/$(basename "$f")"
    printf '  ~  Linked: %s\n' "$(basename "$f")"
done

printf '\n  Done. Run: source ~/.bashrc\n\n'
