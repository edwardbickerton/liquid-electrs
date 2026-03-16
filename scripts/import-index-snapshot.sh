#!/bin/sh
set -eu

usage() {
  cat <<'EOF'
Usage: import-index-snapshot.sh [--force] <snapshot-tarball>

Imports a previously exported Liquid electrs newindex snapshot when the
compatibility manifest matches this app version and runtime profile.
EOF
}

manifest_value() {
  key="$1"
  manifest_path="$2"
  sed -n "s/^${key}=//p" "$manifest_path" | head -n1
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
archive_path="$1"

if [ ! -f "$archive_path" ]; then
  echo "Snapshot archive not found: ${archive_path}" >&2
  exit 1
fi

expected_app_version="$(sed -n 's/.*"version": "\([^"]*\)".*/\1/p' "${repo_dir}/package.json" | head -n1)"
expected_electrs_ref="$(sed -n 's/^ARG ELECTRS_REF=\(.*\)$/\1/p' "${repo_dir}/electrs/Dockerfile" | head -n1)"
expected_write_buffer_mb="$(sed -n 's/.*ELECTRS_DB_WRITE_BUFFER_SIZE_MB="\${ELECTRS_DB_WRITE_BUFFER_SIZE_MB:-\([0-9][0-9]*\)}".*/\1/p' "${repo_dir}/electrs/entrypoint.sh" | head -n1)"
expected_block_cache_mb="$(sed -n 's/.*ELECTRS_DB_BLOCK_CACHE_MB="\${ELECTRS_DB_BLOCK_CACHE_MB:-\([0-9][0-9]*\)}".*/\1/p' "${repo_dir}/electrs/entrypoint.sh" | head -n1)"
expected_batch_size="$(sed -n 's/.*ELECTRS_INITIAL_SYNC_BATCH_SIZE="\${ELECTRS_INITIAL_SYNC_BATCH_SIZE:-\([0-9][0-9]*\)}".*/\1/p' "${repo_dir}/electrs/entrypoint.sh" | head -n1)"

tmpdir="$(mktemp -d)"
trap 'rm -rf "$tmpdir"' EXIT INT TERM
tar -C "$tmpdir" -xzf "$archive_path"

manifest_path="${tmpdir}/manifest.env"
snapshot_dir="${tmpdir}/newindex"

if [ ! -f "$manifest_path" ] || [ ! -d "$snapshot_dir" ]; then
  echo "Snapshot archive must contain manifest.env and newindex/" >&2
  exit 1
fi

check_manifest() {
  key="$1"
  expected="$2"
  actual="$(manifest_value "$key" "$manifest_path")"
  if [ -z "$actual" ]; then
    echo "Snapshot manifest is missing ${key}" >&2
    exit 1
  fi
  if [ "$actual" != "$expected" ]; then
    echo "Snapshot manifest mismatch for ${key}: expected '${expected}', got '${actual}'" >&2
    exit 1
  fi
}

check_manifest SNAPSHOT_FORMAT 1
check_manifest APP_ID liquid-electrs
check_manifest APP_VERSION "$expected_app_version"
check_manifest ELECTRS_REF "$expected_electrs_ref"
check_manifest NETWORK liquid
check_manifest PARENT_NETWORK bitcoin
check_manifest LIGHTMODE true
check_manifest DB_WRITE_BUFFER_SIZE_MB "$expected_write_buffer_mb"
check_manifest DB_BLOCK_CACHE_MB "$expected_block_cache_mb"
check_manifest INITIAL_SYNC_BATCH_SIZE "$expected_batch_size"

data_root="${LIQUID_ELECTRS_DATA_ROOT:-${UMBREL_ROOT:-/home/umbrel/umbrel}/app-data/liquid-electrs/data/electrs_liquid_db/mainnet}"
dest_dir="${data_root}/newindex"
backup_dir="${data_root}/newindex.backup.$(date +%Y%m%d%H%M%S)"

mkdir -p "$data_root"

if [ -e "$dest_dir" ]; then
  if [ "$force" -ne 1 ]; then
    echo "Destination ${dest_dir} already exists. Rerun with --force to back it up and replace it." >&2
    exit 1
  fi
  mv "$dest_dir" "$backup_dir"
  echo "Backed up existing index to ${backup_dir}"
fi

mv "$snapshot_dir" "$dest_dir"
echo "Imported snapshot into ${dest_dir}"
