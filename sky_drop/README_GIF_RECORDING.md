# GIF Recording Feature

## Overview
The Sky Drop game now includes a built-in GIF recording feature that captures 5 seconds of gameplay and provides tools to convert it into an animated GIF.

## How to Use

### Start Recording
- **Hotkey**: Press `F12` during gameplay
- **Console Command**: Type `gif` in the dev console (press ` or F1 to open)

### Recording Process
1. Recording starts immediately when triggered
2. A red "🎬 Recording: X.Xs" indicator appears on screen
3. Recording automatically stops after 5 seconds
4. Frames are captured at 15 FPS for optimal GIF quality

### Output Files
After recording, the following files are created in `user://gifs/` folder:

#### Frame Files
- `sky_drop_YYYYMMDD_HHMMSS_frames/` - Directory containing individual PNG frames
- `frame_001.png`, `frame_002.png`, etc. - Individual frame files

#### Conversion Scripts
- `create_gif_YYYYMMDD_HHMMSS.bat` - Windows batch file for GIF conversion
- `create_gif_YYYYMMDD_HHMMSS.sh` - Linux/Mac shell script for GIF conversion

## Converting to GIF

### Requirements
You need **FFmpeg** installed on your system:
- **Windows**: Download from https://ffmpeg.org/download.html
- **Linux**: `sudo apt install ffmpeg` (Ubuntu/Debian) or equivalent
- **Mac**: `brew install ffmpeg` (with Homebrew)

### Conversion Process
1. Navigate to the `user://gifs/` folder (usually in your Godot user data directory)
2. Run the appropriate script:
   - **Windows**: Double-click `create_gif_TIMESTAMP.bat`
   - **Linux/Mac**: Run `bash create_gif_TIMESTAMP.sh` in terminal

### Output
- Creates `sky_drop_TIMESTAMP.gif` in the same directory
- GIF is optimized with a color palette for best quality/size ratio
- 15 FPS playback rate for smooth animation

## File Locations

### Godot User Directory Locations
- **Windows**: `%APPDATA%/Godot/app_userdata/sky_drop/gifs/`
- **Linux**: `~/.local/share/godot/app_userdata/sky_drop/gifs/`
- **Mac**: `~/Library/Application Support/Godot/app_userdata/sky_drop/gifs/`

## Technical Details

### Recording Specifications
- **Duration**: 5 seconds fixed
- **Frame Rate**: 15 FPS (75 frames total)
- **Resolution**: Matches game viewport (360x640)
- **Format**: PNG frames → GIF conversion

### Performance Impact
- Minimal impact during recording
- Frame capture uses viewport texture reading
- No blocking operations during gameplay

## Troubleshooting

### Recording Not Starting
- Check if another recording is already in progress
- Ensure sufficient disk space in user directory
- Verify GifRecorder node is present in Main scene

### Conversion Issues
- Ensure FFmpeg is installed and in system PATH
- Check file permissions in gifs directory
- Verify all frame files were created successfully

### Large File Sizes
- GIFs are optimized but may still be large for action-heavy scenes
- Consider using shorter clips or lower frame rates if needed
- FFmpeg parameters can be adjusted in conversion scripts

## Tips for Best Results

### Recording Timing
- Start recording just before interesting gameplay moments
- 5 seconds is enough to capture key actions (parachute deployment, hazard avoidance)
- Use dev console `gif` command for precise timing

### Gameplay Suggestions
- Record spectacular fails (hard landings)
- Capture close calls with hazards
- Show off combo scoring sequences
- Demonstrate power-up effects

### Sharing
- Generated GIFs are perfect for social media sharing
- Standard format compatible with all platforms
- Optimized file size for web use