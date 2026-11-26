# torchcraft API — SIF + bind-mounted source

Host source: `/lustre/grp/cmclab/leiy/torchcraft_api/main.py` (bind-mounted to `/api/main.py`).
Image: `/lustre/grp/cmclab/leiy/containers/torchcraft.sif`. Port: `8020`.

Submit from the host after placing this folder at `/lustre/grp/cmclab/leiy/torchcraft_api`:

```bash
mkdir -p /lustre/grp/cmclab/leiy/logs
sbatch /lustre/grp/cmclab/leiy/torchcraft_api/api.sbatch
```

**Prerequisites:** Image must contain Python, FastAPI, Uvicorn, Pydantic, model dependencies, and usable Slurm CLI (`sbatch`, `squeue`, `sacct`) for API endpoints that submit jobs. No `conda activate` is used. GPU inference uses separate Slurm allocations except RFD4, which uses its API GPU allocation. `CONTAINER_PYTHON` defaults to `python`; override if image uses another executable.

**Important:** Existing checkpoint/model directory placeholders from original scripts are retained and must be set to actual compatible paths. No SIF contents were provided, so image Python, installed API dependencies and Slurm client availability cannot be verified here.
