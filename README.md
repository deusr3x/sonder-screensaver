# Sonder Screensaver for macOS

A native macOS Swift animated screensaver that renders the **Sonder logo (emblem + "sonder" wordmark)** in high-DPI Retina typography with glowing brand colors (Sonder blue `#2f5be9`, electric green `#b2ff57`, warm orange `#ff9f6b`, navy, sky, and lime).

It natively implements 11 signature effects:
- **Matrix** — Authentic green digital rain cascading from the top of the screen before deciphering and crystallizing into the glowing Sonder logo.
- **Synthgrid** — Cyberpunk digital grid scanner and decoding matrix with bright gradient lock-in.
- **Pour** — Liquid neon cascade with gravity and spring rebound.
- **Waves** — Harmonic multi-axis sine ripples with chromatic shifts.
- **Smoke** — Atmospheric drifting vapor curling and condensing into place.
- **Slice** — Alternating kinetic horizontal slices sliding in with ease-out damping.
- **Unstable** — Glitch jitter and quantum particle explosion snapping gravitationally back to center.
- **Scattered** — Scattered star particles drawn in along magnetic trajectory paths.
- **Sweep** — Luminous laser/radar sweep beam energizing glyphs in its wake.
- **Rings** — Concentric chromatic ripple rings radiating from the emblem center.
- **Middleout** — Symmetrical column expansion unrolling from the central vertical axis.

---

## 🚀 Quick Start (Native Swift Screensaver)

### 1. Install as macOS Screensaver (`.saver`)

Run the automated installer:

```sh
./install.sh
```

This compiles, signs, and installs `Sonder.saver` to `~/Library/Screen Savers/`.

**To activate in macOS:**
1. Open **System Settings** → **Wallpaper** / **Screen Saver**.
2. Scroll to the **Other** or **Screen Saver** section and select **Sonder**.
3. Click **Options...** to customize the effect rotation, animation speed, hold duration, neon glow, and background color.

### 2. Standalone Preview App

You can also run the screensaver anytime in a native window or fullscreen without waiting for an idle timer:

```sh
./run-preview.sh
```

*(or `swift run SonderPreview`)*

**Preview Keyboard Controls:**
| Key | Action |
|---|---|
| **Space** | Trigger next effect |
| **M** | Jump directly to Matrix effect |
| **1 – 0** | Jump directly to effect (1: Synthgrid, 2: Pour, 3: Waves, 4: Smoke, 5: Slice, 6: Unstable, 7: Scattered, 8: Sweep, 9: Rings, 0: Middleout) |
| **F** | Toggle Full Screen |
| **C** | Open Settings / Configuration Sheet |
| **Esc** / **Q** | Quit preview |

---

## 🛠 Building from Source

### Using Build Script (Fastest)

```sh
./build.sh
```

Outputs:
- `build/Sonder.saver` (macOS Screen Saver bundle)
- `build/SonderPreview.app` (Standalone preview application)

### Using Xcode

Open `SonderScreensaver.xcodeproj` in Xcode:

```sh
open SonderScreensaver.xcodeproj
```

Select the **Sonder** scheme to build the `.saver` bundle, or **SonderPreview** to run the app.

---

## ⚙️ Customization & Settings

The screensaver includes a native SwiftUI preferences sheet accessible via **Options...** in System Settings or by pressing **C** in the preview runner:

- **Effect Mode:** Rotate (Random), Rotate (Sequential), or lock to any individual effect.
- **Animation Speed:** Gentle (0.75x), Normal (1.0x), Fast (1.35x), Rapid (1.75x).
- **Hold Duration:** 2s, 4s (default), 6s, 10s before transitioning.
- **Neon Glow:** Toggle soft luminescence / bloom.
- **Background:** Pure Black (`#000000`) or Deep Navy (`#000f2e`).

---

## 📦 Sharing with Others

To package the screen saver into a zip file that you can send to anyone (via Slack, Email, AirDrop, etc.):

```sh
./package.sh
```

This creates **`dist/Sonder-Screensaver.zip`**, which includes:
- **Universal Binary:** Runs natively on all Apple Silicon (M1/M2/M3/M4) and Intel Macs running macOS 12+.
- **`Install-Sonder.command`:** A one-click installer script that copies the screensaver to `~/Library/Screen Savers`, clears the macOS download quarantine, and launches System Settings.
- **`README.txt`:** Simple setup instructions for the recipient.

---

## 🗑 Uninstall

To remove the screensaver bundle from your system:

```sh
./uninstall.sh
```

---

## 💻 Terminal Version (Original)

The original terminal launcher script is preserved in `sonder-screensaver.sh`:

```sh
./sonder-screensaver.sh
./sonder-screensaver.sh pour   # force specific effect
```
*(Requires `ttfx` or `pipx install terminaltexteffects`)*
