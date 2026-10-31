#!/usr/bin/env bash
# Usage: scripts/new-draft.sh <YYYY-MM-DD> <reel|animated-carousel|static-carousel>
# Creates drafts/<date>/project from the format's template.
set -euo pipefail
cd "$(dirname "$0")/.."
date="$1"; format="$2"
dir="drafts/$date"
[ -d "templates/$format" ] || { echo "Unknown format: $format"; exit 1; }
[ -e "$dir" ] && { echo "$dir already exists"; exit 1; }
mkdir -p "$dir/project/fonts" "$dir/out"
cp templates/$format/* "$dir/project/"
cp templates/gsap.min.js "$dir/project/"
cp assets/fonts/* "$dir/project/fonts/"
echo "$format" > "$dir/format.txt"
echo "Created $dir/project from templates/$format"
