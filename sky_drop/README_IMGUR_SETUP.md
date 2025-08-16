# Imgur API Setup for GIF Sharing

## Overview
The Sky Drop game now includes web sharing functionality that uploads gameplay GIFs directly to Imgur. This guide explains how to set up the Imgur API integration.

## Setting Up Imgur API

### 1. Register Your Application
1. Go to https://api.imgur.com/oauth2/addclient
2. Fill in the application details:
   - **Application name**: Sky Drop Game
   - **Authorization type**: Select "Anonymous usage without user authorization"
   - **Authorization callback URL**: Can be left blank for anonymous uploads
   - **Description**: Sky Drop gameplay GIF sharing

### 2. Get Your Client ID
After registration, you'll receive:
- **Client ID**: A string like `a1b2c3d4e5f6789`
- **Client Secret**: Not needed for anonymous uploads

### 3. Configure the Game
Edit `/scripts/GifSharer.gd` and replace the placeholder:
```gdscript
const IMGUR_CLIENT_ID = "YOUR_CLIENT_ID_HERE"  # Replace with your actual client ID
```

## API Limits

### Anonymous Upload Limits
- **Daily limit**: 50 uploads per IP address
- **Rate limit**: 1250 requests per hour
- **File size**: 10MB max per image (our GIFs are typically < 1MB)

### With User Authentication (Future Enhancement)
- **Daily limit**: 12,500 uploads
- **Rate limit**: 12,500 requests per hour
- **File size**: 20MB max per image

## How It Works

### Upload Flow
1. Player records 5-second gameplay (F12 or 'gif' command)
2. After recording, share dialog appears
3. Player chooses "Share Online 🌐"
4. Game converts frames to single image (proof of concept)
5. Image uploaded to Imgur via API
6. Share link returned and copied to clipboard

### Current Implementation
- Uses anonymous uploads (no user login required)
- Tracks daily upload count locally
- Shows remaining uploads in share dialog
- Handles rate limiting gracefully

### Security Considerations
- Client ID is safe to embed in game (designed for client-side use)
- No user data is sent to Imgur
- All uploads are anonymous
- No personal information included in uploads

## Testing the Integration

### Test Upload
1. Start the game
2. Press F12 to record 5 seconds
3. Choose "Share Online" in dialog
4. Check console for upload status
5. Verify link is copied to clipboard

### Debugging
Check the Godot console for:
- Upload request details
- Response codes (200 = success)
- Error messages from Imgur API

### Common Issues
- **"Daily upload limit reached"**: Wait 24 hours or use different IP
- **"Failed to start upload"**: Check Client ID is set correctly
- **"Upload failed with code 403"**: Client ID invalid or rate limited
- **"Invalid response from server"**: Network issues or API changes

## Future Enhancements

### Planned Features
1. **Proper GIF encoding**: Currently uploads single frame PNG
2. **OAuth2 integration**: Allow users to upload to their Imgur account
3. **Album creation**: Group multiple GIFs from same session
4. **Social sharing**: Direct share to Twitter/Discord with game hashtags
5. **Custom branding**: Add game logo watermark to GIFs

### GIF Encoding Options
- **Option 1**: Use GDExtension for native GIF encoding
- **Option 2**: Server-side conversion service
- **Option 3**: WebAssembly GIF encoder
- **Option 4**: Animated WebP as alternative format

## Privacy Policy Considerations

When releasing the game, include in your privacy policy:
- Game can upload gameplay recordings to Imgur
- Uploads are anonymous (no user data attached)
- Players must opt-in to share (not automatic)
- Imgur's terms of service apply to uploaded content

## Alternative Services

If Imgur doesn't meet your needs, consider:
- **Giphy**: More complex API, better for game GIFs
- **Cloudinary**: Full media management, requires account
- **Firebase Storage**: Google integration, more control
- **Custom backend**: Full control but higher maintenance