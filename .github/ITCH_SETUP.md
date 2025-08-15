# Setting up itch.io Publishing with GitHub Actions

## Prerequisites

1. Create an itch.io account at https://itch.io
2. Create a new game project on itch.io
3. Install Butler locally (optional, for testing): https://itch.io/docs/butler/

## Required GitHub Secrets

Add these secrets to your repository (Settings → Secrets and variables → Actions):

### 1. `BUTLER_API_KEY`
Get your API key from: https://itch.io/user/settings/api-keys
- Click "Generate new API key"
- Copy the key (it will only be shown once)

### 2. `ITCH_USER`
Your itch.io username (e.g., "yourusername")

### 3. `ITCH_GAME`
Your game's URL slug from itch.io (e.g., "sky-drop")
- This is the part after your username in the URL
- Example: `yourusername.itch.io/sky-drop` → game slug is "sky-drop"

## Usage

### Automatic Publishing
Any push to `main` that changes files in `sky_drop/` will automatically build and publish the HTML5 version.

### Manual Publishing
1. Go to Actions tab
2. Select "Publish to itch.io"
3. Click "Run workflow"
4. Choose the platform (html5, windows, linux, mac)
5. Click "Run workflow"

## Channels

The workflow publishes to different Butler channels:
- `html5` - Web version playable in browser
- `windows` - Windows executable
- `linux` - Linux executable
- `mac` - macOS app bundle

## Version Management

Create a `VERSION` file in the `sky_drop/` directory:
```
1.0.0
```

Butler will use this for version tracking on itch.io.

## Testing Locally

```bash
# Download butler
curl -L -o butler.zip https://broth.itch.ovh/butler/linux-amd64/LATEST/archive/default
unzip butler.zip
chmod +x butler

# Login (first time only)
./butler login

# Push manually
./butler push sky_drop/build/html5 yourusername/sky-drop:html5 --userversion=1.0.0
```

## Troubleshooting

1. **Build fails**: Check Godot export templates match the version
2. **Upload fails**: Verify API key and game slug are correct
3. **Game not visible**: Make sure game visibility is set to "Public" or "Restricted" on itch.io