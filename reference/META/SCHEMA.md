# Avalhla Reference Schema

## Object record
id: OBJECT-0001
name: Example Object
type: OBJECT
status: STORY
source:
  kind: file
  ref: path/to/source
reflections:
  color: []
  road: []
  dream: []
  map: []
  memory: []
  chapter: []
  place: []
  sound: []
traces: []
relations: []

## Reflection record
object_id: OBJECT-0001
kind: color|road|dream|map|memory|chapter|place|sound|trace
target_id: TARGET-0001
relation: reflects
evidence: STORY
source: path/to/source
notes: Human-readable explanation

## Rules
- IDs are stable anchors.
- Names can change.
- Reflections are relationships, not copies.
- Presentation color never changes stored meaning.
- STORY never silently becomes IMPLEMENTED.
