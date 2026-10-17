# Dead Zone: Survival

A lightweight, low-poly 3D third-person zombie survival game for Android, built with Godot 4.4. The project is designed for mobile controls and lower-powered phones, with APK builds handled by GitHub Actions so Android Studio is not needed on your PC.

## Playable systems currently in the project
- Third-person 3D movement and follow camera
- Touch movement buttons, touch camera drag, fire and reload
- Keyboard and mouse controls for desktop testing
- Zombie chase and melee attacks
- Hitscan shooting, magazine/reserve ammo and reload
- Health, consumable first-aid kits, waves, kills and ammo rewards
- Persistent best-wave and total-kill records using the device's local save file
- Procedurally generated test-zone props and lighting
- Android APK export workflow

## Build and download the Android APK
1. Open the [Actions page](https://github.com/Inexra/dead-zone-survival/actions).
2. Select the latest **Build Android APK** workflow run.
3. Wait until it finishes successfully.
4. Under **Artifacts**, download **Dead-Zone-Survival-Android-APK**.
5. Extract the ZIP and install the APK on your Android phone. If Android asks, allow your file manager/browser to install unknown apps.

Each push to `main` starts a cloud build. You do not need Android Studio installed.

## Controls
- Desktop: **WASD** to move, mouse to look, left mouse button to shoot, **R** to reload.
- Touch: on-screen directional buttons to move, drag the right side to look, **FIRE**, **RELOAD**, and **MEDKIT** buttons.

## Project status
This is an actively developed early-access prototype, not yet a finished open-world release. The current playable area is a compact survival test zone. The long-term game plan is to add a larger explorable map, loot and inventory, crafting, weapon variety, quests, safe zones, vehicles, more zombie types, audio, settings and a polished title/pause flow. Those features should only be marked complete after they are implemented and tested.

## Local development
Install Godot 4.4.x and its Android export templates, then import `project.godot`. The cloud workflow installs Android SDK prerequisites and export templates automatically.
