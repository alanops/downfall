# Sky Drop Sound Effects Needed

## Download Links
1. **Sound Effects Pack 2** (OpenGameArt.org - CC0)
   - Link: https://opengameart.org/content/sound-effects-pack-2
   - Contains: Coins, Hit, Jump, Power-up sounds
   - Format: WAV available

2. **Freesound.org Recommendations** (Search for CC0 WAV files)
   - Wind/Whoosh sounds: https://freesound.org/browse/tags/wind/
   - Parachute fabric: https://freesound.org/browse/tags/fabric/
   - Impact sounds: https://freesound.org/browse/tags/impact/

## Sound Categories & File Names

### UI Sounds (/assets/sounds/ui/)
- `menu_click.wav` - Menu selection
- `menu_hover.wav` - Menu hover
- `difficulty_change.wav` - Changing difficulty level
- `game_start.wav` - Starting game
- `game_over.wav` - Game over jingle

### Player Sounds (/assets/sounds/player/)
- `parachute_deploy.wav` - Parachute opening
- `player_hit.wav` - Taking damage from plane
- `player_move.wav` - Horizontal movement swoosh
- `player_land_soft.wav` - Landing with parachute
- `player_land_hard.wav` - Landing without parachute (death)
- `wind_rush.wav` - Continuous falling wind (loop)
- `wind_parachute.wav` - Gentler wind with parachute (loop)

### Environment Sounds (/assets/sounds/environment/)
- `cloud_enter.wav` - Entering cloud
- `cloud_ambient.wav` - Inside cloud ambience (loop)
- `plane_flyby.wav` - Plane passing by
- `altitude_warning.wav` - Low altitude warning

### Collectibles Sounds (/assets/sounds/collectibles/)
- `coin_collect.wav` - Collecting coin
- `powerup_shield.wav` - Shield power-up
- `powerup_magnet.wav` - Magnet power-up
- `powerup_ghost.wav` - Ghost mode power-up
- `powerup_speed.wav` - Speed boost power-up
- `combo_increase.wav` - Combo multiplier increase

## Implementation Priority
1. **Essential**: wind_rush.wav, parachute_deploy.wav, coin_collect.wav, player_hit.wav
2. **Important**: player_land_soft.wav, powerup sounds, menu_click.wav
3. **Nice to have**: cloud sounds, plane_flyby.wav, combo sounds

## Notes
- Keep file sizes small (< 500KB per sound)
- Use 44.1kHz or 48kHz sample rate
- Mono for most SFX, stereo for ambient loops
- Normalize audio levels for consistency