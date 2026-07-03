# MediaHub

A modern menu-bar companion to Get iPlayer Automator: it keeps your series
links downloading automatically in the background, with zero queue management.

MediaHub is Phase 1 of a personal "hub" app. It wraps get_iplayer's built-in
PVR (series link) engine in a small SwiftUI menu-bar app:

- **Series links** — add a show once ("Doctor Who"); every new episode is
  downloaded automatically.
- **Scheduled checks** — runs the PVR every 1–24 hours (configurable), so
  episodes arrive overnight without you doing anything.
- **Glanceable status** — the menu-bar dropdown shows what downloaded
  recently, with one-click Show in Finder, plus the last run's log.
- **Notifications** — a macOS notification when new episodes land.

Unlike the original app, MediaHub does not reimplement searching, caching, or
series matching — it delegates all of that to get_iplayer's own `--pvr`
machinery, which keeps the Swift side tiny.

## Requirements

- macOS 13 Ventura or later
- Xcode command line tools (`xcode-select --install`)
- get_iplayer: `brew install get-iplayer` (MediaHub auto-detects the
  Homebrew install; any other location can be set in Settings, including a
  raw `get_iplayer.pl` script, which is run through perl)

## Running

```sh
cd MediaHub
swift run
```

A TV icon appears in the menu bar. Add a series, hit **Check & Download
Now**, and new episodes are saved to `~/Movies` (change the folder in
Settings).

MediaHub keeps its own get_iplayer profile in
`~/Library/Application Support/MediaHub`, so its series links and download
history never interfere with an existing Get iPlayer Automator or
command-line get_iplayer setup.

## How it works

| Action | get_iplayer invocation |
| --- | --- |
| List series links | `--pvr-list` |
| Add a series | `--type=tv --pvr-add=<name> "<search>"` |
| Remove a series | `--pvr-del=<name>` |
| Scheduled/manual check | `--pvr --output=<folder>` |

Every invocation includes `--nocopyright --profile-dir=<app support>` and the
`PERL_UNICODE=AS` environment, mirroring how Get iPlayer Automator has always
driven get_iplayer.

## Prototype limitations

- Built as a Swift Package executable, not a signed .app bundle yet — so
  notifications go through `osascript` and there's no login-item support.
  Packaging it as a proper bundle is the first follow-up.
- TV only for now (`--type=tv`); radio is a one-line change.
- Download progress isn't streamed live; the menu shows the result when the
  run finishes.

## Roadmap

1. Package as a signed .app with launch-at-login and native notifications.
2. Stream per-episode progress into the menu.
3. Post-download hooks: auto-add to the TV app, or move into a Plex/Jellyfin
   library folder.
4. **Phase 2 — morning briefing pane**: calendar, actionable email, and
   overnight downloads in the same dropdown.
