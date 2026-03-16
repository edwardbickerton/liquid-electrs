#!/bin/sh
set -eu

usage() {
  cat <<'EOF'
Usage: export-index-snapshot.sh [--force] <output-tarball>

Exports the durable Liquid electrs newindex directory plus a compatibility
manifest. Stop the app first for the safest snapshot, or pass --force to export
even if RocksDB lock files are present.
EOF
}

force=0
while [ "$#" -gt 0 ]; do
  case "$1" in
    --force)
      force=1
      shift
      ;;
    -h|--help)
      usage
      exit 0
      ;;
    *)
      break
      ;;
  esac
done

if [ "$#" -ne 1 ]; then
  usage >&2
  exit 1
fi

script_dir="$(CDPATH= cd -- "$(dirname -- "$0")" && pwd)"
repo_dir="$(CDPATH= cd -- "${script_dir}/.." && pwd)"
output_path="$1"

app_version="$(sed -n 's/.*"version": "\([^"]*\)".*/\1/p' "${repo_dir}/package.json" | head -n1)"
electrs_ref="$(sed -n 's/^ARG ELECTRS_REF=\(.*\)$/\1/p' "${repo_dir}/electrs/Dockerfile" | head -n1)"
write_buffer_mb="$(sed -n 's/.*ELECTRS_DB_WRITE_BUFFER_SIZE_MB="\${ELECTRS_DB_WRITE_BUFFER_SIZE_MB:-\([0-9][0-9]*\)}".*/\1/p' "${repo_dir}/electrs/entrypoint.sh" | head -n1)"
block_cache_mb="$(sed -n 's/.*ELECTRS_DB_BLOCK_CACHE_MB="\${ELECTRS_DB_BLOCK_CACHE_MB:-\([0-9][0-9]*\)}".*/\1/p' "${repo_dir}/electrs/entrypoint.sh" | head -n1)"
batch_size="$(sed -n 's/.*ELECTRS_INITIAL_SYNC_BATCH_SIZE="\${ELECTRS_INITIAL_SYNC_BATCH_SIZE:-\([0-9][0-9]*\)}".*/\1/p' "${repo_dir}/electrs/entrypoint.sh" | head -n1)"

data_root="${LIQUID_ELECTRS_DATA_ROOT:-${UMBREL_ROOT:-/home/umbrel/umbrel}/app-data/liquid-electrs/data/electrs_liquid_db/mainnet}"
source_dir="${data_root}/newindex"

if [ ! -d "$source_dir" ]; then
  echo "Missing source index directory: ${source_dir}" >&2
  exit 1
fi

if [ "$force" -ne 1 ] && find "$source_dir" -name LOCK -type f | grep -q .; then
  echo "RocksDB lock files are present under ${source_dir}. Stop liquid-electrs first or rerun with --force." >&2
  exit 1
fi

tmpdir="$(mktemp -d)"
trap 'rm -rf "$tmpdir"' EXIT INT TERM

mkdir -p "${tmpdir}/snapshot"
cp -a "$source_dir" "${tmpdir}/snapshot/newindex"
cat > "${tmpdir}/snapshot/manifest.env" <<EOF
SNAPSHOT_FORMAT=1
APP_ID=liquid-electrs
APP_VERSION=${app_version}
ELECTRS_REF=${electrs_ref}
NETWORK=liquid
PARENT_NETWORK=bitcoin
LIGHTMODE=true
DB_WRITE_BUFFER_SIZE_MB=${write_buffer_mb}
DB_BLOCK_CACHE_MB=${block_cache_mb}
INITIAL_SYNC_BATCH_SIZE=${batch_size}
EOF

mkdir -p "$(dirname -- "$output_path")"
tar -C "${tmpdir}/snapshot" -czf "$output_path" manifest.env newindex
echo "Wrote snapshot archive to ${output_path}"
