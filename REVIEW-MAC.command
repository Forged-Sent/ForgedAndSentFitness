#!/bin/bash
cd "$(dirname "$0")" || exit 1
echo "Forged & Sent independent pre-push code review"
echo "This uses your signed-in AI CLIs and may count against their usage."
python3 tooling/review/review.py "$@"
status=$?
echo
if [ "$status" -eq 0 ]; then
  echo "Review preparation/verification succeeded."
else
  echo "Review did NOT pass. Read .review/summary.md if generated."
fi
if [ -t 0 ]; then read -r -p "Press Enter to close..." _answer; fi
exit "$status"
