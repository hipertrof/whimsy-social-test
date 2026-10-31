#!/usr/bin/env bash
# Usage: scripts/render.sh <YYYY-MM-DD>
# Copies the photos index.html references, checks the composition and renders
# the post into drafts/<date>/out/.
set -euo pipefail
cd "$(dirname "$0")/.."
date="$1"
dir="drafts/$date"
format="$(cat "$dir/format.txt")"
proj="$dir/project"
HF="npx --yes hyperframes@0.8.223"

# Photos are referenced as src="assets/<file>" and looked up in assets/photos/*/.
mkdir -p "$proj/assets"
for f in $(grep -o 'src="assets/[^"]*"' "$proj/index.html" | sed 's/src="assets\///; s/"$//' | sort -u); do
  match=$(ls assets/photos/*/"$f" 2>/dev/null | head -1 || true)
  [ -n "$match" ] || { echo "Photo not found: $f"; exit 1; }
  cp "$match" "$proj/assets/"
done

(cd "$proj" && $HF check) | tail -5
out="$(cd "$dir/out" && pwd)"
rm -f "$out"/*

case "$format" in
  static-carousel)
    n=$(grep -c 'class="slide' "$proj/index.html")
    times=$(seq -s, 0.5 1 $((n - 1)).5)
    rm -rf "$proj/.hyperframes/artifacts/snapshots"
    (cd "$proj" && $HF snapshot --at "$times") > /dev/null
    i=1
    for f in "$proj"/.hyperframes/artifacts/snapshots/*/frame-*.png; do
      [ $i -le $n ] && cp "$f" "$out/slide-$i.png"
      i=$((i + 1))
    done
    ;;
  animated-carousel)
    (cd "$proj" && $HF render --quality looks -o "$out/full.mp4") | grep -E "Render (complete|failed)"
    len=$(grep -o 'data-duration="[0-9.]*"' "$proj/index.html" | head -1 | grep -o '[0-9.]*')
    slides=$(grep -c 'class="slide' "$proj/index.html")
    per=$(awk "BEGIN{print $len/$slides}")
    for i in $(seq 1 "$slides"); do
      ss=$(awk "BEGIN{print ($i-1)*$per}")
      ffmpeg -v error -y -ss "$ss" -i "$out/full.mp4" -t "$per" -c:v libx264 -pix_fmt yuv420p -crf 18 -an "$out/slide-$i.mp4"
    done
    rm "$out/full.mp4"
    ;;
  reel)
    (cd "$proj" && $HF render --quality looks -o "$out/reel.mp4") | grep -E "Render (complete|failed)"
    ;;
esac
ls -la "$out"
