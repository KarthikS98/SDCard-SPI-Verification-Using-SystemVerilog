
# SD Card SPI — SystemVerilog Verification

Short description
-----------------

Compact verification suite that models an SPI master and a behavioral SD card in SystemVerilog. The repository focuses on the smallest set of sources and testbenches required to reproduce and verify SD card initialization, single-block read (CMD17) and write (CMD24) operations over SPI.

Design goals
------------

- Minimal, readable SystemVerilog RTL and testbench code optimized for simulation.
- Deterministic testbenches that log command/response sequences and verify data integrity.
- Easy-to-run simulations using Vivado/XSIM or provided batch scripts.

Professional repo layout (minimal)
---------------------------------

This is the recommended directory structure for the GitHub repository. Only include the files listed here.

Root files (required)
- `README.md`             — this file (project summary + run instructions)
- `LICENSE`               — e.g., MIT license text
- `.gitignore`            — ignore build and simulator artifacts

Source code (required)
- `rtl/`                  — SystemVerilog design sources
	- `spi_master.sv`       — SPI master implementation
	- `sd_card.sv`          — Behavioral SD card model (in-memory block storage)

Testbenches (required)
- `tb/`                   — verification testbenches
	- `sd_card_tb.sv`       — full read/write verification (top for SD test)
	- `spi_master_tb.sv`    — SPI master unit tests (loopback + slave-response)

Simulation scripts (recommended)
- `sim/`                  — small helper scripts and run files (optional)
	- `run_sd_tb.tcl`       — simple XSIM/Tcl script that runs `sd_card_tb.sv`
	- `run_spi_tb.tcl`      — simple XSIM/Tcl script that runs `spi_master_tb.sv`
	- `README_SIM.md`       — short notes how to run the TCL scripts in Vivado

Utilities and docs (optional)
- `docs/`                 — one-page PDF or Markdown documentation (project report)
- `tools/`                — small utility scripts (only if they are useful: `extract_pptx_text.py`)

Files and folders to exclude (do NOT commit)
-------------------------------------------

These are generated files, simulator caches, and Vivado project cruft that should be kept out of Git:

- `PBL_NEW.cache/`, `PBL_NEW.hw/`, `PBL_NEW.sim/` (Vivado project intermediate files)
- `*.wdb`, `*.xsim`, `*.pb`, `*.log`, `*.jou`, `*.db` (simulator artifacts)
- `*.wpc`, `*.wdf`, `*.mem` and large waveform dumps
- `*.bit`, `*.bin`, `*.elf` (binaries)
- `Results/` (large screenshots or exports) — keep only a few small example images if needed

Suggested `.gitignore` starter (add at repo root)
----------------------------------------------

Add these lines to `.gitignore`:

```
# Vivado / Xilinx
PBL_NEW.cache/
PBL_NEW.sim/
PBL_NEW.hw/

# Simulator outputs
*.wdb
*.xsim
*.pb
*.log
*.db
*.jou
*.mem

# Build artifacts
*.bit
*.bin
*.elf

# Results / large files
Results/
```

How to prepare the repo for GitHub (recommended steps)
----------------------------------------------------

1. Create a new, empty repository on GitHub (do not initialize with README if you will push local files).
2. Locally, create the minimal layout above and copy only the required files into it.
3. Add `.gitignore` and `LICENSE`.
4. Commit and push:

```powershell
cd "C:\Users\lenov\Desktop\6th sem\PBL\System Verilog PBL"
git init
git add .
git commit -m "Initial minimal import: RTL + testbenches"
git branch -M main
git remote add origin <your-repo-url>
git push -u origin main
```

Quick run (Vivado / XSIM)
-------------------------

1. Open Vivado, create a new project and add `rtl/*.sv` and `tb/*.sv` as simulation sources.
2. Use `sd_card_tb.sv` as simulation top for the SD verification sequence. Run for ~1000 ns.
3. Alternatively run the provided `sim/*.tcl` scripts in the Vivado Tcl console:

```
# inside Vivado Tcl console
source run_sd_tb.tcl
```

What I will not include for you
------------------------------

- I will not include Vivado project caches, simulator binary blobs, or huge waveform files in the repository. These are environment-specific and inflate repo size.

Next steps (pick one)
---------------------

- I can create a ready-to-commit `.gitignore` and `LICENSE` for you.
- I can generate the two minimal `run_*.tcl` simulation scripts and a short `README_SIM.md`.
- I can scan your `PBL_NEW.srcs/new/` folder and suggest which `*.sv` files to copy into `rtl/` and `tb/`.

Choose which of the three tasks above you'd like me to do next.

