# DeepSeek-R1 14B -- 16K / 32K Context (Container Flow)

For: VVgBazz / RTX 3060 12GB / Bazzite DX NVIDIA 44
Historical note: the old host-install recipe used pkill and env vars
at serve time. That flow is gone. In the current setup, context is set
in the Quadlet.

## The Rule (Still True)

OLLAMA_CONTEXT_LENGTH is an environment variable on the Ollama process,
not a flag on "ollama run".

In the container world, you set it in:
  ~/.config/containers/systemd/ollama.container

    Environment=OLLAMA_CONTEXT_LENGTH=16384
    Environment=OLLAMA_NUM_GPU=999

Then:
  systemctl --user daemon-reload
  systemctl --user restart ollama.service

The helper script does this for you:
  ollama-ctx 16384

## Verify

    systemctl --user show ollama.service --property=Environment | tr ' ' '\n' | grep OLLAMA

    # Or check the API after starting a model
    ollama run avalhla "say hi"

    # Look at the process arguments
    pgrep -af llama-server | grep -o '\-c [0-9]*' | head -1
    # Expected: -c 16384

## VRAM Budget on RTX 3060 12GB (DeepSeek-R1 14B Q4_K_M)

    Weights       ~8.4 GB
    Desktop       ~0.6 GB
    Total usable  ~11.4 GB
    Leaves        ~3.0 GB for KV cache

Context   KV cache   Total      Verdict
-------   --------   -------    -------------------------------------
4096      ~0.75 GB   ~9.2 GB    default, small
8192      ~1.5 GB    ~9.9 GB    comfy
16384     ~3.0 GB    ~11.4 GB   recommended
32768     ~6.0 GB    ~14.4 GB   tight; KV spills to system RAM
65536     ~12 GB     ~20.4 GB   way over budget, do not try

At 32K: model stays on GPU, but KV partially spills to RAM.
Generation drops from ~1.7 t/s to ~0.5-0.9 t/s. Fine for one-off long
prompts. Painful as a daily driver.

## Model Comparison (RTX 3060 12GB)

| Model                 | VRAM     | Speed      | Notes                        |
|-----------------------|----------|------------|------------------------------|
| qwen2.5-coder:7b      | ~5.5 GB  | 60+ t/s    | Daily driver, base for Ava   |
| qwen2.5-coder:14b     | ~9.5 GB  | 30-40 t/s  | Complex architecture         |
| deepseek-r1:14b       | ~8.4 GB  | 1.5-1.7 t/s| Slow reasoning, use rarely   |

Recommendation: stick to qwen2.5-coder:7b for Ava. DeepSeek-R1 is for
one-off reasoning tasks where the slowness is worth it.

## How To Change Context

    # Show current
    ollama-ctx

    # Change to 8192 (faster, less memory)
    ollama-ctx 8192

    # Change to 16384 (recommended)
    ollama-ctx 16384

    # Change to 32768 (accept slowdown)
    ollama-ctx 32768

The helper edits the Quadlet, reloads systemd, restarts the container.

## If It OOMs Or Falls Back To CPU

Symptoms in the container log:

    podman logs ollama | tail -50

Look for:

    "disabling mmap" with reason=cpu
    "offloaded 0/N layers to GPU"
    time-to-first-token > 60s

Fixes in order:

  1. Close GPU apps (Firefox, OBS, games).
  2. Drop context one tier: ollama-ctx 8192
  3. Restart: systemctl --user restart ollama.service
  4. Switch to a smaller model: ollama run qwen2.5-coder:7b

## Historical Note

The pre-container recipe (which this file used to teach) was:

    pkill -f "ollama serve"
    OLLAMA_CONTEXT_LENGTH=16384 nohup ollama serve > ~/.ollama/serve.log 2>&1 &

That is no longer correct. Do not use it. Ollama runs in the container
managed by systemd.

## Signature

    Dawa > AwA < Avalhla.
    (^.-)
