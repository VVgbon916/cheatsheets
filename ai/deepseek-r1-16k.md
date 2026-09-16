# 🐋 DeepSeek-R1:14b @ 16K / 32K context — VERIFIED RECIPE
For `VVgBazz` · RTX 3060 12GB · Bazzite DX NVIDIA 44

## ⚠ The single most-common mistake

**`OLLAMA_CONTEXT_LENGTH` is an environment variable on `ollama serve`,
NOT a flag on `ollama run`.** If the server is already running with a
different context, setting the env var before `ollama run` does nothing.

**Your own log proves this:** `ollama.log` shows `-c 4096`, not `-c 16384`.

---

## ✅ The correct sequence (16K — daily driver)

```bash
pkill -f "ollama serve" || true
sleep 1

OLLAMA_CONTEXT_LENGTH=16384 nohup ollama serve > ~/.ollama/serve.log 2>&1 &

until curl -fsS http://127.0.0.1:11434/api/tags >/dev/null; do sleep 1; done
echo "Ollama ready"

cd ~/ollama-agent
ollama create deepseek-r1-tool-14b-16k -f Modelfile
ollama run deepseek-r1-tool-14b-16k

✅ Verify
bash

pgrep -af llama-server | grep -o '\-c [0-9]*'
# Want: -c 16384
# Got:  -c 4096  → env var didn't apply

Or use make ctx-16k / make ctx-32k.
📊 VRAM budget on RTX 3060 12GB

Model: DeepSeek-R1:14b Q4_K_M ≈ 8.4 GB weights.
Context KV cache        Weights Total   Verdict
4096    ~0.75 G 8.4 G   ~9.2 G  default, small
8192    ~1.5 G  8.4 G   ~9.9 G  comfy, small
16384   ~3 G    8.4 G   ~11.4 G ✅ recommended
32768   ~6 G    8.4 G   ~14.4 G ⚠ tight but fits if KV spills to CPU
65536   ~12 G   8.4 G   ~20.4 G ❌ will spill, very slow
⚠ On the 32768 row

    3060 has 12 GB VRAM

    Desktop + browser overhead: ~0.6 GB

    Available: ~11.4 GB

    Model weights: 8.4 GB

    Leaves: ~3.0 GB for KV cache

    Need for 32K: ~6 GB

    Over budget by ~3 GB → KV spills to system RAM

Effect: model stays on GPU, KV partially on GPU+RAM. Prompt eval stays
fast (~8-15 tok/s), but token generation drops from ~1.7 tok/s to ~0.5-0.9
tok/s once KV spills. Fine for one-off long jobs, painful as a daily driver.
How to run 32K

Option A — accept the slowdown:
bash

make ctx-32k

Option B — free VRAM aggressively first:
bash

pkill -f steamwebhelper
pkill -f firefox
pkill -f obs
make ctx-32k

Option C — use a smaller model for long context:
bash

ollama pull qwen2.5-coder:7b     # ~4.7 GB, fits 32K easily

VRAM recommendation
Use case        Context
Daily coding, quick questions   16384
Long single-shot analysis (repo, big doc)       32768
Multi-turn agent with tool calls        16384
Chained "read this, refactor this"      32768 (accept slow)
If it OOMs or falls back to CPU

Symptoms in ~/.ollama/serve.log:

    "disabling mmap" with reason=cpu

    "offloaded 0/N layers to GPU"

    Time-to-first-token > 60 s

Fixes in order:

    Close GPU apps

    Drop context one tier

    ollama stop all models, reload just this one

    Switch to qwen2.5-coder:7b

Reference numbers (from your logs)

Your ollama.log (Sept 11) shows 14B Q4_K_M at 4096 context:

    Load: 26.9 s

    Prompt eval: 8.71 tok/s

    Generation: 1.72 tok/s

    VRAM used: ~8.7 GB

At 16384 expect: load ~30 s, gen ~1.5-1.7 tok/s.
At 32768 expect: load ~45-60 s, gen ~0.7-1.0 tok/s.
