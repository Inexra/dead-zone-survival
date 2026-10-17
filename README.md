# Dead Zone: Survival

A lightweight 3D third-person zombie survival prototype for Android, built with Godot 4.4 and GitHub Actions.

## Current prototype
- 3D survival arena with generated environment
- Third-person player movement and camera
- Touch controls for mobile (move, look, fire)
- Zombies chase the player and deal damage
- Shooting, ammo/reload, health, kills and waves
- Android APK build through GitHub Actions

## Build APK
1. Open the **Actions** tab.
2. Select **Build Android APK** and run it, or push a commit to `main`.
3. Open the completed workflow run and download the `Dead-Zone-Survival-Android-APK` artifact.
4. Extract the downloaded ZIP and install the APK on your phone. Android may ask you to allow installs from your browser/file manager.

## Open locally
Install Godot 4.4.x with Android export templates, then import `project.godot`. The GitHub workflow builds the APK in the cloud, so Android Studio is not required.

## Controls
- Desktop: WASD to move, mouse to aim, left mouse button to fire, R to reload.
- Touch: left joystick to move, drag the right side to look, FIRE and RELOAD buttons.

## Notes
This is an early playable prototype, not a finished open-world release. The initial map is a compact test zone; larger streamed terrain, inventory, crafting, vehicles, missions, save/load and more weapons can be added in later versions.
