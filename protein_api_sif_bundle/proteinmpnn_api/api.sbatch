#!/bin/bash
#SBATCH --job-name=proteinmpnn-api
#SBATCH --partition=gpu34,gpu31,gpu37,gpu2,gpu34,gpu3-12,gpu39
#SBATCH --cpus-per-task=2
#SBATCH --mem=8G
#SBATCH --time=12:00:00
#SBATCH --output=/lustre/grp/cmclab/leiy/logs/proteinmpnn-api-%j.out
#SBATCH --error=/lustre/grp/cmclab/leiy/logs/proteinmpnn-api-%j.err
set -euo pipefail
ROOT=/lustre/grp/cmclab/leiy/protein_api_sif_bundle
API_DIR="$ROOT/proteinmpnn_api"
IMAGE="$ROOT/containers/proteinmpnn.sif"
export PROTEINMPNN_SIF="$IMAGE"
export PROTEINMPNN_CONTAINER_SCRIPT="/app/proteinmpnn/protein_mpnn_run.py"
export PROTEINMPNN_WORK="$ROOT/proteinmpnn_api_jobs"
export PROTEINMPNN_PARTITION=gpu34,gpu31,gpu37,gpu2,gpu34,gpu3-12,gpu39
export PROTEINMPNN_INPUT_ROOTS="$ROOT:/lustre/grp/cmclab/share"
export PROTEINMPNN_WEIGHTS="$ROOT/models/proteinMPNN/van_v_48_020.pt"
export SOLUBLEMPNN_WEIGHTS="$ROOT/models/proteinMPNN/sol_v_48_020.pt"
export ABMPNN_WEIGHTS="$ROOT/models/proteinMPNN/abmpnn.pt"
for name in PROTEINMPNN_SIF PROTEINMPNN_CONTAINER_SCRIPT PROTEINMPNN_WORK PROTEINMPNN_PARTITION PROTEINMPNN_INPUT_ROOTS; do
  export "APPTAINERENV_${name}=${!name}"
done
export APPTAINERENV_PROTEINMPNN_WEIGHTS="$PROTEINMPNN_WEIGHTS"
export APPTAINERENV_SOLUBLEMPNN_WEIGHTS="$SOLUBLEMPNN_WEIGHTS"
export APPTAINERENV_ABMPNN_WEIGHTS="$ABMPNN_WEIGHTS"
mkdir -p "$ROOT/logs" "${PROTEINMPNN_WORK}"
test -r "$IMAGE"
test -r "$API_DIR/main.py"
# ProteinMPNN source is already inside the SIF; mount only API code and shared data.
exec apptainer exec \
  --bind /lustre:/lustre \
  --bind "$API_DIR:/api:ro" \
  --pwd /api \
  "$IMAGE" python -u -m uvicorn main:app --host 0.0.0.0 --port 8090
