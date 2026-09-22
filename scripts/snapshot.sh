#!/bin/bash
~/ai-snapshot.sh > ~/system-snapshot-ai.json
~/human-snapshot.sh > ~/system-snapshot-human.txt
echo "✅ Snapshots saved:"
ls -lh ~/system-snapshot-ai.json ~/system-snapshot-human.txt
