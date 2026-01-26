# ACG_Group_Project
**Black hole simulation**

## Demo
**[Demo](<https://minato-w.github.io/ACG_Group_Project/>)**

## Features
### 1. Physical calculation of light paths around a black hole
* **Ray Marching Engine:** Calculates light paths step-by-step.
* **Gravitational Lensing:** Bends ray directions toward the singularity to create the iconic "double-arch" distortion.

### 2. Gas disk graphics
* **Doppler Effect:** Creates a real-time brightness shift based on rotation.
* **Volumetric Accretion Disk:** Accumulates density and color through 3D space.
* **FBM Noise:** Uses procedural textures for a turbulent gas look.
* **Proportion Tuning:** Balances the event horizon shadow and disk size.
* **ACES Tone Mapping:** Preserves deep reds while glowing white-hot.

## Controls
**Control Panel(Top Right)**
* r : Set distance from black hole.
* θ : Move the viewpoint horizontally around the black hole.
* φ : Move the viewpoint up and down around the black hole.
* M : Set the gravitational strength of the black hole.

## Credits

This project incorporates the **Star Nest** shader by **Pablo Roman Andrioli** for its background rendering.

- **Original Work**: [Star Nest on Shadertoy](https://www.shadertoy.com/view/XlfGRj)
- **Author**: Pablo Roman Andrioli
- **License**: MIT

The original code has been adapted to function as a directional background map compatible with the gravitational lensing simulation.
## Members
* 5125A021 Minato Takahashi
* 1W223010 Ko Ishii
* 5125FG25 Wu Huadong
* 1W222118 Kazuki Kammera
