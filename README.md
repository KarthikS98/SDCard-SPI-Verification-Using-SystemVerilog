# SD Card SPI — SystemVerilog Verification

A SystemVerilog verification project that models an SPI master and a behavioral SD card to simulate and validate SD card initialization and read/write sequences (CMD0, CMD8, CMD17, CMD24) without hardware. Includes testbenches and simulation scripts to reproduce console outputs and waveforms demonstrating correct command-response and data transfer.

Table of contents
- Project overview
- Features
- Repository layout
- Prerequisites
- Quick start (Vivado / simulation)
- Expected output
- Contributing
- License

Project overview
---------------

This project provides a reusable verification environment for an SD card interface implemented over SPI. It contains:

- An SPI Master module (drives SCLK, MOSI, CS) that transmits 48-bit SD commands and receives responses over MISO.
- A behavioral SD Card model that decodes commands, returns R1/R3/R7 responses, serves data tokens and data blocks, and accepts write transactions.
- Testbenches to validate read (CMD17) and write (CMD24) flows, plus SPI master loopback and slave-response tests.
- Simulation scripts and helper tools to run and inspect waveforms and console output.

This environment lets you verify initialization and data transfer sequences (CMD0, CMD8, CMD17, CMD24) entirely in simulation.

Features
--------

- SPI master FSM: IDLE → TRANSFER → DONE; 48-bit transfers; MOSI on falling edge, MISO sampled on rising edge.
- Behavioral SD card supporting core commands (CMD0, CMD8, CMD17, CMD24, CMD55, ACMD41, CMD58).
- Testbenches with clear console logging to demonstrate command/response sequences and read/write verification.
- Simulation helper scripts and Vivado-friendly project structure (files from Vivado project included in the `PBL_NEW` folder).

Repository layout
-----------------

Keep the repository organized for clarity. Suggested layout (the repo already contains similar structure):

- `src/` or `rtl/` — SystemVerilog source modules (suggest moving or copying `PBL_NEW.srcs/new/*.sv` here):
	- `spi_master.sv` — SPI master module
	- `sd_card.sv` — Behavioral SD card model
- `tb/` or `testbench/` — testbenches
	- `sd_card_tb.sv` — SD card verification TB
	- `spi_master_tb.sv` — SPI master TB
- `sim/` — simulation scripts and simulator artifacts (Tcl, `simulate.bat`, `compile.bat`)
- `tools/` — utility scripts (`extract_pptx_text.py`, `extract_pptx_text.ps1`)
- `docs/` — documentation and LaTeX source
- `Results/` — waveform screenshots and console images (optional)
- `PBL_NEW/` — original Vivado project files (ignore bulky intermediate files when committing)

Make sure to add a `.gitignore` to exclude build artifacts and simulator caches (examples: `*.wdb`, `*.xsim`, `PBL_NEW.cache/`, `PBL_NEW.sim/`).

Prerequisites
-------------

- Xilinx Vivado 2020.2 or later (for GUI simulation and project import)
- A SystemVerilog-capable simulator (Vivado XSIM is used by the provided project files)
- Git (for repository management)

Quick start — run simulations
--------------------------------

Option A — using Vivado GUI (recommended)

1. Open Vivado and create a new project or import the existing `PBL_NEW` Vivado project.
2. Add or confirm SystemVerilog sources are present (`spi_master.sv`, `sd_card.sv`) and testbenches under simulation sources.
3. Set `sd_card_tb.sv` as the top-level simulation file for SD card verification, or `spi_master_tb.sv` for SPI master tests.
4. Run simulation for ~1000 ns and open the waveform viewer. Inspect console output for verification messages.

Option B — run provided simulation scripts (if present)

If the repository contains simulation batch files or TCL scripts (check `PBL_NEW.sim/sim_1/behav/`), use them from PowerShell. Example (adjust paths as needed):

```powershell
cd "C:\Users\lenov\Desktop\6th sem\PBL\System Verilog PBL\PBL_NEW\PBL_NEW.sim\sim_1\behav\xsim"
.\simulate.bat
```

Note: exact paths and scripts depend on your Vivado export. Alternatively, use Vivado's Flow → Simulation → Run Simulation menu.

Expected output
---------------

Console/log samples you should see from the SD card testbench (trimmed):

=== WRITE VERIFICATION SEQUENCE ===
Step 1: Reading original data...
CMD sent: 5100000000ff
R1 response: 000000000000
Token: 0000000000fe
Data block: deadbeef1234
...
Step 2: Writing new data...
CMD sent: 5800000000ff
Response received: 000000000000
Data token: 0000000000fe
Data block: cafebabe5678
Write response: 000000000005
...
Step 3: Reading data after write...
Data block: cafebabe5678
=== WRITE VERIFICATION COMPLETE ===

SPI master testbench sample outputs:

=== TEST 1: SPI Loopback ===
Transfer complete:
Data sent: 400000000095
Data received: 400000000095
SUCCESS: Loopback working correctly!

=== TEST 2: Slave Response ===
Transfer complete:
Data sent: 5100000000FF
Data received: 123456789ABC
SUCCESS: Slave response working correctly!

Notes and common clarifications
--------------------------------

- CRC handling: Some testbenches use fixed CRC bytes for known commands in simulation. If you need full CRC7/CRC16 checking, add or enable CRC calculation in `crc` helpers.
- SD memory model: The behavioral SD card stores blocks in-memory for simulation. If persistence or a larger memory is required, modify the model accordingly.
- Simulator logs/waveforms: save large waveform files outside the repo or add them to `.gitignore`.

Contributing
------------

If you want to improve the project:

- Open an issue describing the change or bug.
- Create a feature branch: `git checkout -b feat/crc-improvements`.
- Submit a pull request with a short description and tests (if applicable).

License
-------

This repository is released under the MIT License — include a `LICENSE` file at the project root.

Authors
-------

Karthik S and team (project developed as part of EC362AI — SystemVerilog for Design & Verification).

Contact
-------

For questions and contributions open an issue or contact the authors via the repository profile.
