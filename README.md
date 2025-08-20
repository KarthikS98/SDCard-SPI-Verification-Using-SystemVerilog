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

-You said you'll upload only these items to GitHub:

- `RTL_codes/` — a folder containing the four SystemVerilog files:
	- `sd_card.sv`
	- `sd_card_tb.sv`
	- `spi_master.sv`
	- `spi_master_tb.sv`
- `Results/` — waveform screenshots and console images that show expected outputs (small images are fine; large files should be kept out or added as a release asset).

If later you want to include helper scripts or documentation, add them under `tools/` or `docs/`.

Prerequisites
-------------

- Xilinx Vivado 2020.2 or later (for GUI simulation and project import)
- A SystemVerilog-capable simulator (Vivado XSIM is used by the provided project files)
- Git (for repository management)


Quick start — run simulations
--------------------------------

Because you'll upload the four SV files inside `RTL_codes/`, here's the minimal flow to simulate them in Vivado or any SystemVerilog-capable simulator:

1. Open Vivado and create a new project (empty project).
2. Add the four files from your uploaded `RTL_codes/` folder as sources and simulation sources:
	- Add `RTL_codes/sd_card.sv` and `RTL_codes/spi_master.sv` as design sources.
	- Add `RTL_codes/sd_card_tb.sv` and `RTL_codes/spi_master_tb.sv` as simulation sources.
3. For SD card verification, set `sd_card_tb.sv` as the top-level simulation file and run simulation (set stop time ≈ 1000 ns).
4. For SPI master unit tests, set `spi_master_tb.sv` as top-level and run its simulation.



Uploading only these files to GitHub (web UI)
-------------------------------------------

1. Create a new repository on github.com (name + description + visibility).
2. On the new repo page click Add file → Upload files.
3. Drag the local `RTL_codes/` folder (containing the four `.sv` files) and the `Results/` folder into the upload area.
4. Commit the upload with message "Initial import: source files + results".


Notes and common clarifications
--------------------------------

- CRC handling: Some testbenches use fixed CRC bytes for known commands in simulation. If you need full CRC7/CRC16 checking, add or enable CRC calculation in `crc` helpers.
- SD memory model: The behavioral SD card stores blocks in-memory for simulation. If persistence or a larger memory is required, modify the model accordingly.

Contributing
------------

If you want to improve the project:

- Open an issue describing the change or bug.
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
