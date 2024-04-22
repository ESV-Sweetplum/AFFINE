# AFFINE v1.1.2

![GitHub commit activity](https://img.shields.io/github/commit-activity/w/ESV-Sweetplum/AFFINE)
![GitHub commits since latest release](https://img.shields.io/github/commits-since/ESV-Sweetplum/AFFINE/latest)
![GitHub License](https://img.shields.io/github/license/ESV-Sweetplum/AFFINE)

AFFINE (pronounced aff-een) is a [Quaver](https://www.quavergame.com) plugin designed to simplify map making. In particular, AFFINE assists with the creation of static and dynamic timing lines.

## Features:

- Automatically place no-SV timing line batches.
- Place frames of timing lines.
- Create versatile timing line animations.
- Automatically update with `affine-updater.exe`.

## Menus:

- **_(Standard > Spread)_** Place a gradient of timing lines over a selected region.
- **_(Standard > At Notes)_** Place timing lines at selected notes.
- **_(Standard > Rainbow_)** Select a group of notes to apply the given colors to the notes, cycling when the end of the list is reached.
- **_(Fixed > Manual)_** Place still timing lines at desired height.
- **_(Fixed > Automatic)_** Place a gradient of still timing lines between designated heights.
- **_(Fixed > Random)_** Place a random amount of still timing lines within a region, at random locations.
- **_(Animation > Manual (Basic))_** Set up keyframes for individual timing lines to move from one MSX to another.
- **_(Animation > Increment)_** Setup a base manual frame. For each note present within the animation boundary, a new frame is generated, progressively forming the base manual frame.
- **_(Animation > Boundary (Static))_** Hide and show backdrop timing lines using a boundary.
- **_(Animation > Boundary (Dynamic))_** Scale backdrop timing lines with a boundary.
- **_(Animation > Glitch)_** Create an animation with constantly changing random notes.
- **_(Animation > Spectrum)_** Create an animation with a spectrum with variable height.
- **_(Animation > Expansion / Contraction)_** Create an animation with expanding / contracting timing lines.
- **_(Deletion)_** Easily delete all timing lines and scroll velocities within a certain range.

## Basic Tutorial:

- Select the primary line placement type (`Standard`, `Fixed`, `Animation`).
- Select the secondary line placement type. This is the second dropdown below the primary line placement dropdown.
- Adjust settings as desired.
- Press `Place Lines` or press the `A` key.
- If the effect does not look correct, adjust the `MS Spacing` setting until it does. Ideally, this number should be as low as possible.

## Installation:

1. Go to the [latest release](https://www.github.com/ESV-Sweetplum/AFFINE/releases/latest) and download `AFFINE.zip`.
2. Inside the zip folder will be a folder called `AFFINE`. Place this into your Quaver plugin folder.

   2a. If you're having trouble finding the plugin folder, go to the song selection menu. Then, right-click any map, and select the `Open Folder` option. In your file explorer, backtrack to the `Quaver` folder. Inside the `Quaver` folder will be a folder called `Plugins`. Place AFFINE here.

3. Done!

## Building and Modifying:

### DO NOT EDIT THE `PLUGIN.LUA` FILE.

All files necessary are contained within the `src` directory. When you're finished editing, run `src/compiler.js` to compile all files into `plugin.lua`. Note: compilation is only possible with [Node.js](https://nodejs.org/en/download) installed.

## TO DO (before v1.2):

- Add documentation to all helper functions

## Special thanks to:

- [amoguSV](https://github.com/kloi34/AmoguSV): The internal logic for displacements, increments, and teleportation was taken from this plugin. Highly recommended to use this plugin alongside AFFINE.
- [IceDynamix' Plugin Guide](https://github.com/IceDynamix/QuaverPluginGuide/blob/master/quaver_plugin_guide.md): All `imgui` documentation was from this document. This is almost necessary for new plugin developers.
