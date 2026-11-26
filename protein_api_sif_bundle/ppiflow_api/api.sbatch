#!/bin/bash
#SBATCH --job-name=ppiflow-api
#SBATCH --partition=gpu34,gpu31,gpu3-12,gpu37,gpu39,gpu2
#SBATCH --cpus-per-task=2
#SBATCH --mem=8G
#SBATCH --time=12:00:00
#SBATCH --output=/lustre/grp/cmclab/leiy/logs/ppiflow-api-%j.out
set -euo pipefail
ROOT=/lustre/grp/cmclab/leiy
API_DIR="$ROOT/ppiflow_api"
IMAGE="$ROOT/containers/ppiflow.sif"
CONTAINER_PYTHON="${CONTAINER_PYTHON:-python}"
export PYTHONUNBUFFERED=1
export TMPDIR=/tmp
export PPIFLOW_PARTITION=gpu34,gpu31,gpu3-12,gpu37,gpu39,gpu2
export PPIFLOW_ROOT=/lustre/grp/cmclab/leiy/v3_basic
export PPIFLOW_BINDER_CWD=/lustre/grp/cmclab/share/changdr/Projects/v34_binder_0919
export PPIFLOW_API_WORK=/lustre/grp/cmclab/leiy/ppiflow_api_jobs
export PPIFLOW_SIF="$IMAGE"
export PPIFLOW_PYTHON="$CONTAINER_PYTHON"
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
  --env "PPIFLOW_SIF=$IMAGE" \
  "$IMAGE" "$CONTAINER_PYTHON" -u -m uvicorn main:app --host 0.0.0.0 --port 8010
