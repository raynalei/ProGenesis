#!/bin/bash
#SBATCH --job-name=af3score-api
#SBATCH --partition=gpu34,gpu31,gpu3-12,gpu37,gpu39,gpu2
#SBATCH --cpus-per-task=2
#SBATCH --mem=8G
#SBATCH --time=12:00:00
#SBATCH --output=/lustre/grp/cmclab/leiy/logs/af3score-api-%j.out
set -euo pipefail
ROOT=/lustre/grp/cmclab/leiy
API_DIR="$ROOT/af3score_api"
IMAGE="$ROOT/containers/af3score.sif"
CONTAINER_PYTHON="${CONTAINER_PYTHON:-python}"
export PYTHONUNBUFFERED=1
export TMPDIR=/tmp
export AF3SCORE_PARTITION=gpu34,gpu31,gpu3-12,gpu37,gpu39,gpu2
export AF3SCORE_ROOT=/lustre/grp/cmclab/leiy/AF3Score
export AF3SCORE_API_WORK=/lustre/grp/cmclab/leiy/af3score_api_jobs
export AF3SCORE_DB_DIR=/lustre/grp/cmclab/share/wangd/af3_data
export AF3SCORE_MODEL_DIR=/lustre/grp/cmclab/leiy
export AF3SCORE_ALLOWED_INPUT_ROOTS=/lustre/grp/cmclab/leiy
export AF3SCORE_WORKER_IMAGE="$IMAGE"
export AF3SCORE_PYTHON="$CONTAINER_PYTHON"
export AF3SCORE_CONTAINER_PYTHON="$CONTAINER_PYTHON"
export PYTHONPATH=/lustre/grp/cmclab/leiy/AF3Score/src
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
  --env "AF3SCORE_SIF=$IMAGE" \
  "$IMAGE" "$CONTAINER_PYTHON" -u -m uvicorn main:app --host 0.0.0.0 --port 8030
