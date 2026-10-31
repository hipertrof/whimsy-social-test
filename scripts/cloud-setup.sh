#!/usr/bin/env bash
# Runs at the start of a cloud session (see .claude/settings.json). Installs what
# the render needs. Does nothing on a local machine.
[ "$CLAUDE_CODE_REMOTE" = "true" ] || exit 0
command -v ffmpeg >/dev/null || (apt-get update -qq && apt-get install -y -qq ffmpeg) >/dev/null 2>&1
npx --yes hyperframes@0.8.223 browser ensure >/dev/null 2>&1 || true
exit 0
