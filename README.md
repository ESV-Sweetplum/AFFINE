# AFFINE v1.0.0

AFFINE (pronounced aff-een) is a [Quaver](https://www.quavergame.com) plugin designed to simplify map making. In particular, AFFINE assists with the creation of static and dynamic timing lines.

## Features

- ***(Standard > Spread)*** Place a gradient of timing lines over a selected region
- ***(Standard > At Notes)*** Place timing lines at selected notes  
⠀
- The following can be done on a still frame (0.0x SV):
    - ***(Fixed > Manual)*** Place timing lines at desired height
    - ***(Fixed > Automatic)*** Place a gradient of timing lines between designated heights
    - ***(Fixed > Random)*** Place a random amount of timing lines within a region  
⠀
- ***(Animation > Static (Polynomial))*** Hide and show backdrop timing lines using an imaginary boundary
- ***(Animation > Dynamic (Polynomial))*** Scale backdrop timing lines with a polynomial temporal boundary
- ***(Animation > Glitch)*** Create an animation with constantly changing random notes 

## Basic Tutorial

- Select the primary line placement type (`Standard`, `Fixed`, `Animation`).
- Select the secondary line placement type. This is the second dropdown below the primary line placement dropdown.
- Adjust settings as desired.
- Press `Place Lines` or press the `A` key.

## Installation:

1. Go to the [latest release](https://www.github.com/ESV-Sweetplum/AFFINE/releases/latest) and download `AFFINE.zip`.
2. Inside the zip folder will be a folder called `AFFINE`. Place this into your Quaver plugin folder. 

    2a. If you're having trouble finding the plugin folder, go to the song selection menu. Then, right-click any map, and select the `Open Folder` option. In your file explorer, backtrack to the `Quaver` folder. Inside the `Quaver` folder will be a folder called `Plugins`. Place AFFINE here.
3. Done!

## Building and Modifying:

### DO NOT EDIT THE `PLUGIN.LUA` FILE.

All files necessary are contained within the `src` directory. When you're finished editing, run `src/compiler.js` to compile all files into `plugin.lua`. Note: compilation is only possible with [Node.js](https://nodejs.org/en/download) installed.

## Special thanks to:

- [amoguSV](https://github.com/kloi34/AmoguSV): The internal logic for displacements, increments, and teleportation was taken from this plugin. Highly recommended to use this plugin alongside AFFINE.
