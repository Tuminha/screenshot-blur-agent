---
name: screenshot-blur
description: Take screenshots of desktop apps (including Electron) and blur sensitive information using AI vision + ImageMagick. Use when creating tutorials, blog posts, tweets, or documentation that needs clean screenshots with private data redacted.
homepage: https://github.com/Tuminha/screenshot-blur-agent
metadata:
  openclaw:
    emoji: "🔒"
    requires:
      bins: ["magick", "screencapture", "osascript"]
---

# Screenshot Blur Agent

Capture screenshots from any macOS app (including Electron apps like Claude, Codex, Tana, Slack, VS Code) and automatically blur sensitive information using AI vision to identify private data and ImageMagick to redact it.

## How It Works

1. **Capture** - Bring app to front, take screenshot with macOS `screencapture`
2. **Identify** - AI vision model analyzes the screenshot and returns pixel coordinates of sensitive areas (names, conversations, emails, project names)
3. **Blur** - ImageMagick applies gaussian blur to those regions
4. **Verify** - Vision model confirms sensitive data is no longer readable

## Quick Start

### Capture a screenshot
```bash
bash {baseDir}/scripts/capture-electron.sh "Claude" /tmp/claude.png
```

### Blur a region
```bash
bash {baseDir}/scripts/blur.sh /tmp/claude.png /tmp/claude-blurred.png 0 680 300 1200 40
```

### Chain multiple blur regions
```bash
# Blur sidebar, then main content
bash {baseDir}/scripts/blur.sh input.png step1.png 0 680 300 1200
bash {baseDir}/scripts/blur.sh step1.png final.png 576 833 1500 500
```

## Agent Workflow (Full Automation)

When an AI agent runs this skill, the workflow is:

```
1. Capture screenshot:
   osascript -e 'tell application "AppName" to activate'
   sleep 1.5
   screencapture -x /tmp/screenshot.png

2. Send to vision model with prompt:
   "Identify all areas with sensitive/private information.
    Return pixel coordinates (x, y, width, height).
    Image is Retina (actual dimensions from `identify`)."

3. Apply blur for each region:
   magick input.png \
     \( +clone -region 'WxH+X+Y' -blur 0x40 \) \
     -compose over -composite \
     output.png

4. Verify with vision model:
   "Can you read any personal names, conversation titles,
    or private data? Confirm the blur is effective."
```

## Retina Display Handling

macOS Retina displays capture at 2x resolution. Vision models typically report coordinates at display scale (1x). Multiply by the scale factor:

```bash
# Get actual dimensions
identify screenshot.png  # → 3456x2234

# Vision model reports at ~1368x880 (display scale)
# Scale factor = 3456/1368 ≈ 2.526

# Multiply all vision coordinates by 2.526 for actual pixel coords
```

## Supported Apps (Tested)

| App | Type | Notes |
|-----|------|-------|
| Claude Desktop | Electron | Sidebar conversations, user identity |
| Codex (OpenAI) | Electron | Project list, conversation history, repo paths |
| Tana | Electron | Nodes, meeting titles, personal names, calendar |
| Slack | Electron | Channels, DMs, usernames |
| VS Code | Electron | File tree, terminal output, extensions |
| Chrome/Safari | Native | Any web content via screencapture |

## Electron CDP Connection (Advanced)

For more precise control, connect to Electron apps via Chrome DevTools Protocol:

```bash
# Quit app first, then relaunch with CDP
open -a "Tana" --args --remote-debugging-port=9228

# Connect with agent-browser or Playwright
# Take viewport-only screenshots via CDP (no macOS dock/menubar)
```

**Port assignments:**
- 9228: Tana
- 9230: Slack
- 9235: Codex

## Requirements

- **macOS** (uses `screencapture` and `osascript`)
- **ImageMagick 7+** (`brew install imagemagick`)
- **AI vision model** (Claude, GPT-4o, Gemini) for coordinate detection
- **OpenClaw** (optional, for agent automation)

## Tips

- Blur strength of 40 makes text completely unreadable to both humans and AI
- Always verify with a vision model after blurring
- For Retina displays, always check actual dimensions with `identify` before applying coordinates
- Chain blur operations sequentially (one region per step) to avoid timeouts on large images
- The vision model sometimes reports coordinates slightly off. Use a test-mark-adjust loop for pixel-perfect results.

## Examples

See the `examples/` directory for before/after screenshots from Claude, Tana, and Codex.
