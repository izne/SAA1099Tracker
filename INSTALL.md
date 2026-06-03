# SAA1099Tracker — Installation

## Prerequisites

- [Node.js](https://nodejs.org/) 18+ (tested with v20 and v22)
- npm (ships with Node.js)

## Setup

```bash
# 1. Install dependencies
# --legacy-peer-deps is required due to a peer dependency conflict
# in fork-ts-checker-notifier-webpack-plugin
npm install --legacy-peer-deps

# 2. Verify correct dependency versions are installed
npm ls jquery bootstrap

# Expected output:
#   jquery@2.2.4
#   bootstrap@3.4.1

# 3. If wrong versions were resolved, pin them manually:
npm install jquery@~2.2.4 bootstrap@~3.4.1 --legacy-peer-deps
```

## Running

### Development server

```bash
npm run dev
```

Then open **http://localhost:3000** in Chrome or Edge (required for Web Serial API).

### Production build (no dev server needed)

```bash
npm run build
python3 -m http.server 3000 --directory build
```

## Notes

- The project was originally built with **jQuery 2.2.4** and **Bootstrap 3.4.1**. Using newer major versions of these dependencies will cause runtime errors (e.g. `Cannot set properties of undefined (setting 'emulateTransitionEnd')`).
- The `--legacy-peer-deps` flag is safe — the conflicting packages (`fork-ts-checker-webpack-plugin` v7 vs the notifier plugin's v6 peer requirement) are compatible in practice.
- If you see `ENOSPC: System limit for number of file watchers reached` on Linux, increase the inotify watcher limit:

  ```bash
  sudo sysctl fs.inotify.max_user_watches=524288
  sudo sysctl -p
  ```
