# pdfmeta — Recursively extract PDF metadata (with DOI)
# Writes a CSV into EACH directory that contains PDFs
# file = just the filename
# dir  = absolute directory path

# Usage: pdfmeta [ROOTDIR]
# Default ROOTDIR is current directory.
#
# Requires: exiftool, pdftotext (from poppler)

pdfmeta() {
  local ROOT
  ROOT="$(realpath "${1:-.}")"
  export LC_ALL=C

  # --- deps ---
  need() { command -v "$1" >/dev/null 2>&1 || { echo "Missing dependency: $1" >&2; return 1; }; }
  need exiftool || return 1
  need pdftotext || return 1

  local HEADER='file,dir,title,author,subject,keywords,creator,producer,create_date,modify_date,pages,doi'

  csv_escape() {
    local s=${1//\"/\"\"}
    printf '"%s"' "$s"
  }

  process_dir() {
    local dir="$1"
    local out="$dir/pdf_metadata_with_doi.csv"

    # header
    [[ -f "$out" ]] || echo "$HEADER" > "$out"

    # --- seen set (FIXED: no subshell issue) ---
    declare -A seen=()
    while IFS=, read -r file _; do
      [[ $file == "file" ]] && continue
      file="${file#\"}"
      file="${file%\"}"
      seen["$file"]=1
    done < "$out"

    # --- iterate PDFs (FIXED: no pipe subshell) ---
    while IFS= read -r -d '' f; do
      local absf basef
      absf="$(realpath "$f")"
      basef="$(basename "$f")"

      if [[ -n "${seen[$basef]:-}" ]]; then
        echo "Skipping: $basef"
        continue
      fi

      local title author subject keywords creator producer create modify pages doi

      title=$(exiftool -s -s -s -Title "$absf" || true)
      author=$(exiftool -s -s -s -Author "$absf" || true)
      subject=$(exiftool -s -s -s -Subject "$absf" || true)
      keywords=$(exiftool -s -s -s -Keywords "$absf" || true)
      creator=$(exiftool -s -s -s -Creator "$absf" || true)
      producer=$(exiftool -s -s -s -Producer "$absf" || true)
      create=$(exiftool -s -s -s -CreateDate "$absf" || true)
      modify=$(exiftool -s -s -s -ModifyDate "$absf" || true)
      pages=$(exiftool -s -s -s -PageCount "$absf" || true)

      doi=$(
        pdftotext -f 1 -l 2 -q "$absf" - | tr -d '\r' \
          | grep -Eio '10\.[0-9]{4,9}/[[:graph:]]+' \
          | sed 's/[).,;]$//' \
          | head -n1 || true
      )

      printf '%s,%s,%s,%s,%s,%s,%s,%s,%s,%s,%s,%s\n' \
        "$(csv_escape "$basef")" \
        "$(csv_escape "$dir")" \
        "$(csv_escape "${title:-}")" \
        "$(csv_escape "${author:-}")" \
        "$(csv_escape "${subject:-}")" \
        "$(csv_escape "${keywords:-}")" \
        "$(csv_escape "${creator:-}")" \
        "$(csv_escape "${producer:-}")" \
        "$(csv_escape "${create:-}")" \
        "$(csv_escape "${modify:-}")" \
        "$(csv_escape "${pages:-}")" \
        "$(csv_escape "${doi:-}")" \
        >> "$out"

      echo "Added: $basef"
    done < <(find "$dir" -maxdepth 1 -type f -iname '*.pdf' -print0)
  }

  # --- find dirs ---
  mapfile -d '' DIRS < <(
    find "$ROOT" -type f -iname '*.pdf' -printf '%h\0' | sort -z -u
  )

  if (( ${#DIRS[@]} == 0 )); then
    echo "No PDFs found under: $ROOT"
    return 0
  fi

  for d in "${DIRS[@]}"; do
    process_dir "$d"
  done

  echo "Done. CSVs written."
}