#!/bin/bash
#SBATCH --job-name=rfd4-api
#SBATCH --partition=gpu34,gpu31,gpu37,gpu2,gpu34,gpu3-12,gpu39
#SBATCH --cpus-per-task=2
#SBATCH --mem=8G
#SBATCH --time=12:00:00
#SBATCH --output=/lustre/grp/cmclab/leiy/logs/rfd4-api-%j.out
#SBATCH --gres=gpu:1
set -euo pipefail
ROOT=/lustre/grp/cmclab/leiy/protein_api_sif_bundle
API_DIR="$ROOT/rfd4_api"
IMAGE="$ROOT/containers/rfd4.sif"
CONTAINER_PYTHON="${CONTAINER_PYTHON:-python}"
export PYTHONUNBUFFERED=1
export TMPDIR=/tmp
export RFD4_PARTITION=gpu34,gpu31,gpu3-12,gpu37,gpu39,gpu2
export RFD4_SIF="$IMAGE"
export RFD4_WEIGHTS=/lustre/grp/cmclab/leiy/models/rfd4/model.safetensors
export RFD4_INPUTS=/lustre/grp/cmclab/leiy/rfd4_api_inputs
export RFD4_JOBS=//lustre/grp/cmclab/leiy/protein_api_sif_bundle/rfd4_api_jobs
mkdir -p "$ROOT/logs" "$RFD4_INPUTS" "$RFD4_JOBS"
test -s "$IMAGE"
test -r "$API_DIR/main.py"
# The image MUST include FastAPI, Uvicorn, Pydantic, Python and Slurm client commands.
# Keep Slurm environment visible for sbatch/squeue/sacct; use image's native Python.
exec apptainer exec \
  --bind /lustre:/lustre \
  --bind "$API_DIR:/api:ro" \
  --pwd /api \
  --env "PYTHONUNBUFFERED=1" \
  --env "RFD4_SIF=$IMAGE" \
  "$IMAGE" "$CONTAINER_PYTHON" -u -m uvicorn main:app --host 0.0.0.0 --port 8080
