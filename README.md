# Ambisonics Plugin for REAPER

A JSFX plugin for REAPER that processes first-order Ambisonics (FOA) microphone signals and synthesizes virtual microphones with multiple output modes, an interactive graphical interface, and real-time binaural rendering via HRTF convolution.

---

## Overview

This plugin takes a four-channel B-Format Ambisonics signal — captured from a tetrahedral microphone array — and decodes it into various output formats using virtual first-order microphone synthesis. It supports mono, stereo, binaural, and quadraphonic outputs, all steerable in real time through azimuth and elevation controls.

---

## Features

### Input: B-Format Encoding

The plugin accepts four input channels corresponding to the capsules of a tetrahedral Ambisonics microphone (LF, RF, LB, RB) and encodes them into the standard B-Format components (W, X, Y, Z) using N3D normalization.

### Output Modes

The output mode is selected via the `Salida` slider:

**Mono** — Synthesizes a single first-order virtual microphone steered toward the azimuth and elevation specified. The polar pattern is continuously variable from figure-of-eight (0) through cardioid (0.5) to omnidirectional (1).

**Stereo** — Synthesizes two virtual microphones separated by a configurable stereo angle (30°–180°). Both microphones share the same elevation and pattern settings, and their directions are offset symmetrically around the main azimuth.

**Binaural** — Renders a mono virtual microphone binaurally using real-time partitioned convolution with Head-Related Impulse Responses (HRIRs). The HRIRs are loaded from WAV files derived from SOFA datasets and pre-processed via FFT for efficient block convolution. An independent gain control (in dB) is provided for the binaural output.

**Quadraphonic** — Decodes the Ambisonics signal into four virtual cardioid/supercardioid microphones arranged for front-left, front-right, surround-left, and surround-right speaker positions, based on the current azimuth and stereo angle settings.

### Virtual Microphone Synthesis

All virtual microphones are synthesized by combining the omnidirectional component (W) and a steered bidirectional component (X, Y, Z) using rotation matrices derived from the azimuth and elevation angles. Parameter changes are smoothly interpolated sample-by-sample to avoid clicks and zipper noise.

### Corrective Shelving Filter

An optional corrective equalization filter can be enabled to compensate for the frequency-dependent encoding artifacts typical of coincident Ambisonics microphones. It applies a +3 dB shelving boost on W and a −3 dB shelving cut on X/Y/Z, both at 4 kHz.

### Binaural Convolution Engine

The binaural rendering engine (`Binaural.jsfx-inc`) implements the **overlap-add** method for partitioned block convolution in the frequency domain. HRIRs for left and right ears are loaded from WAV files at initialization, converted to the frequency domain via FFT, and applied to the virtual microphone signal in real time.

### Graphical Interface

The plugin features an interactive graphical panel (`Graficos.jsfx-inc`) that renders two polar diagrams side by side:

- **Left diagram** — Horizontal plane (azimuth), showing the polar pattern(s) of the synthesized microphone(s).
- **Right diagram** — Vertical plane (elevation), showing the pattern rotated in the elevation axis.

For stereo and quadraphonic outputs, all active virtual microphones are drawn simultaneously, giving an immediate visual representation of the spatial configuration. Attenuation reference rings are also drawn for level reference.

---

## Parameters

| Slider | Range | Description |
|---|---|---|
| Azimuth | −180° to 180° | Horizontal steering angle of the virtual microphone |
| Elevation | −90° to 90° | Vertical steering angle of the virtual microphone |
| Pattern | 0 to 1 | Polar pattern (0 = figure-of-eight, 0.5 = cardioid, 1 = omnidirectional) |
| Stereo angle | 30° to 180° | Angular separation between the two stereo or quadraphonic microphones |
| Output | 0–3 | Output mode: Mono / Stereo / Binaural / Quadraphonic |
| Corrective filter | On / Off | Enables the W/XYZ shelving equalizer |
| Binaural volume | −3 to +50 dB | Output gain for binaural mode |

---

## File Structure

```
AmbisonicsPlugin       # Main JSFX plugin file
Filtros.jsfx-inc       # Shelving filter implementation (W and XYZ correction)
Graficos.jsfx-inc      # Polar diagram rendering
Binaural.jsfx-inc      # HRIR loader and FFT convolution engine
AudioHRTF/             # WAV files containing left and right HRIRs (from SOFA)
Matlab/                # MATLAB scripts used to generate and export the HRIR WAV files
```

---

## Installation

1. Copy `AmbisonicsPlugin`, `Filtros.jsfx-inc`, `Graficos.jsfx-inc`, and `Binaural.jsfx-inc` to your REAPER `Effects` folder (or a subfolder within it).
2. Copy the `AudioHRTF/` folder to the same location so the binaural engine can locate the HRIR WAV files at runtime.
3. In REAPER, insert the plugin on a track receiving a four-channel Ambisonics signal (W, X, Y, Z or raw tetrahedral capsule feeds depending on your microphone).
4. Select the desired output mode and configure the track's output channels accordingly.

---

## Requirements

- [REAPER](https://www.reaper.fm/) (any recent version with JSFX support)
- A first-order Ambisonics microphone or a four-channel B-Format source
- For binaural output: the `AudioHRTF/` WAV files must be present at the expected path

---

## Technical Notes

- The B-Format encoding follows the **N3D** normalization convention.
- The binaural convolution uses **overlap-add** partitioned FFT processing to minimize latency while keeping CPU load manageable.
- All rotation matrices are computed per block and interpolated per sample to ensure artifact-free real-time parameter automation.
- The MATLAB scripts in `Matlab/` were used to extract and export HRIR data from SOFA files into the WAV format consumed by the plugin.
