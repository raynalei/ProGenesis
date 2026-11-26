# Unified ProteinMPNN API (source bundled inside SIF)

Only this directory is required for the API. The official ProteinMPNN Python source is assumed to be packaged in `proteinmpnn.sif`; **do not download or bind-mount the upstream repository**.

## 1. Identify the actual script path inside your SIF

```bash
ROOT=/lustre/grp/cmclab/leiy
singularity exec "$ROOT/containers/proteinmpnn.sif" sh -c 'find /opt /app /workspace /usr/local -name protein_mpnn_run.py 2>/dev/null'
```

Set `PROTEINMPNN_CONTAINER_SCRIPT` in `api.sbatch` to the exact returned path. `/opt/ProteinMPNN/protein_mpnn_run.py` is a **placeholder default**, not a verified path. Check the Python executable inside the image too (`python --version`).

## 2. Weight paths

`api.sbatch` configures three **host-side** checkpoint files:

- `PROTEINMPNN_WEIGHTS`: regular ProteinMPNN
- `SOLUBLEMPNN_WEIGHTS`: SolubleMPNN (`--use_soluble_model`)
- `ABMPNN_WEIGHTS`: AbMPNN

Each selected checkpoint directory is bind-mounted read-only at `/mpnn_weights`, and the upstream script receives `--path_to_model_weights /mpnn_weights --model_name <checkpoint_stem>`. The code checks only the requested model's checkpoint before submission. These paths are configurable and must point to real files. If the checkpoints are *also* inside the SIF, additional modifications would be needed to use those internal paths.

## 3. Run

```bash
mkdir -p /lustre/grp/cmclab/leiy/logs
sbatch /lustre/grp/cmclab/leiy/proteinmpnn_api/api.sbatch
```

API listens on port 8090. The API process runs in the SIF and submits independent Slurm jobs using `apptainer exec --nv`. The API image must contain `fastapi`, `uvicorn`, `pydantic`, `sbatch`, `squeue`, `sacct`, and `apptainer`, or those executables must be made available through the host deployment. If your SIF is inference-only, run the API on the host using an API Python environment instead of trying to launch uvicorn inside it.

## 4. Request

`POST /v1/designs` example:

```json
{"model":"abmpnn","pdb_path":"/lustre/grp/cmclab/leiy/example.pdb","design_chains":["H","L"],"num_seq_per_target":8,"sampling_temp":0.1,"seed":42}
```

`model` is one of `proteinmpnn` (default), `solublempnn`, or `abmpnn`.

`GET /health` checks API-side dependencies and the host checkpoint paths. It cannot directly verify an in-image source script; use the `find` command above and a direct inference smoke test.

`GET /v1/tasks/{task_id}` returns status; `GET /v1/tasks/{task_id}/fasta` returns FASTA when complete.
