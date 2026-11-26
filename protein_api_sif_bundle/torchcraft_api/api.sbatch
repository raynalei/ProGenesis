#!/bin/bash
#SBATCH --job-name=torchcraft-api
#SBATCH --partition=gpu34,gpu31,gpu3-12,gpu37,gpu39,gpu2
#SBATCH --cpus-per-task=2
#SBATCH --mem=8G
#SBATCH --time=12:00:00
#SBATCH --output=/lustre/grp/cmclab/leiy/logs/torchcraft-api-%j.out
set -euo pipefail
ROOT=/lustre/grp/cmclab/leiy
API_DIR="$ROOT/torchcraft_api"
IMAGE="$ROOT/containers/torchcraft.sif"
CONTAINER_PYTHON="${CONTAINER_PYTHON:-python}"
export PYTHONUNBUFFERED=1
export TMPDIR=/tmp
export TORCHCRAFT_PARTITION=gpu34,gpu31,gpu3-12,gpu37,gpu39,gpu2
export TORCHX_ROOT=/lustre/grp/cmclab/leiy/TorchX
export TORCHCRAFT_API_WORK=/lustre/grp/cmclab/leiy/torchcraft_api_jobs
export TORCHCRAFT_ALLOWED_ROOT=/lustre/grp/cmclab
export TORCHCRAFT_MODEL_DIR=/lustre/grp/cmclab/leiy
export TORCHCRAFT_SIF="$IMAGE"
export TORCHCRAFT_CONTAINER_PYTHON="$CONTAINER_PYTHON"
mkdir -p "$ROOT/logs"
test -s "$IMAGE"
test -r "$API_DIR/main.py"
# The image MUST include FastAPI, Uvicorn, Pydantic, Python and Slurm client commands.
# Keep Slurm environment visible for sbatch/squeue/sacct; use image's native Python.
exec apptainer exec \
  --bind /lustre:/lustre \
  --bind "$API_DIR:/api:ro" \
  --pwd /api \
  --env "PYTHONUNBUFFERED=1" \
  --env "TORCHCRAFT_SIF=$IMAGE" \
  "$IMAGE" "$CONTAINER_PYTHON" -u -m uvicorn main:app --host 0.0.0.0 --port 8020
