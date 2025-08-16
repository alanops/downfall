# Controller Support Documentation

## Overview
Sky Drop now includes full game controller support with automatic detection, vibration feedback, and dynamic control prompts.

## Supported Controllers
- **Xbox Controllers**: Xbox One, Xbox Series X/S
- **PlayStation Controllers**: DualShock 4, DualSense (PS5)
- **Nintendo Controllers**: Switch Pro Controller
- **Generic Gamepads**: Most USB/Bluetooth controllers

## Control Mapping

### Movement
- **Left Analog Stick**: Move left/right (analog control)
- **D-Pad Left/Right**: Move left/right (digital)
- **Left Analog Stick Up/Down**: Control dive speed

### Actions
- **A/X Button** (Xbox/PlayStation): Deploy parachute
- **Right Trigger** (R2/RT): Alternative parachute button
- **Y/Triangle Button**: Reset game
- **Select/Share Button**: Alternative reset
- **Guide/PS Button**: Open dev console

### Dive Control
- **Left Stick Down**: Fast dive
- **Left Stick Up**: Normal dive speed
- **D-Pad Down**: Fast dive
- **D-Pad Up**: Normal dive
- **Right Trigger** (RT/R2): Fast dive

## Features

### Automatic Detection
- Controllers are detected automatically when connected
- Visual notification shows controller name and status
- HUD updates with controller-specific button prompts

### Analog Control
- Left stick provides smooth analog movement
- Deadzone filtering prevents drift (configurable)
- Dive speed controlled by vertical stick position

### Vibration Feedback
- **Parachute Deployment**: Medium vibration (0.2s)
- **Collision/Damage**: Strong vibration (0.3s)
- **Power-up Collection**: Light vibration (0.1s)
- **Landing**: Vibration intensity based on speed

### Dynamic UI
- Control prompts change based on controller type
- Shows Xbox/PlayStation/Nintendo specific button names
- Falls back to keyboard prompts when disconnected

## Controller Manager API

### Singleton Access
```gdscript
# Check if controller is connected
if ControllerManager.controller_connected:
    print("Controller: ", ControllerManager.controller_name)
```

### Vibration Control
```gdscript
# Vibrate for duration with weak/strong motors
ControllerManager.vibrate(duration, weak_magnitude, strong_magnitude)

# Examples:
ControllerManager.vibrate(0.1, 0.3, 0.3)  # Light feedback
ControllerManager.vibrate(0.3, 0.8, 0.8)  # Strong impact
```

### Input Helpers
```gdscript
# Get analog stick vectors (with deadzone applied)
var move = ControllerManager.get_left_stick_vector()
var look = ControllerManager.get_right_stick_vector()

# Get trigger values (0.0 to 1.0)
var left_trigger = ControllerManager.get_trigger_value(true)
var right_trigger = ControllerManager.get_trigger_value(false)
```

### Button Prompts
```gdscript
# Get controller-specific button name
var button_name = ControllerManager.get_button_prompt("parachute")
# Returns "A" for Xbox, "×" for PlayStation, etc.
```

## Settings

### Vibration
- **Enable/Disable**: Toggle all vibration
- **Strength**: Scale vibration intensity (0-100%)
- **Test**: Button to test current settings

### Deadzone
- **Adjustable**: 0-50% stick deadzone
- **Default**: 20% deadzone
- **Per-stick**: Applied to all analog inputs

## Implementation Details

### Input Mapping Structure
```
project.godot:
- Each action includes keyboard + controller inputs
- Joypad buttons use standard indices
- Analog axes support positive/negative values
```

### Controller Detection
- Uses Godot's `Input.joy_connection_changed` signal
- First connected controller becomes active
- Identifies controller type by name parsing

### Button Index Reference
```
0: Bottom face button (A/Cross/B)
1: Right face button (B/Circle/A)
2: Left face button (X/Square/Y)
3: Top face button (Y/Triangle/X)
4: Left shoulder (LB/L1/L)
5: Right shoulder (RB/R1/R)
6: Select/Back/Share/Minus
7: Start/Options/Plus
8: Left stick click (L3)
9: Right stick click (R3)
10: Guide/Home/PS
11-14: D-Pad directions
```

## Testing Controllers

### Quick Test
1. Connect controller via USB or Bluetooth
2. Check for connection notification
3. Test movement with left stick
4. Press A/X to deploy parachute
5. Verify vibration on collision

### Debug Commands
```
# In dev console (` key or Guide button)
controller status  # Show connection info
controller test    # Test vibration
controller info    # Detailed controller data
```

## Troubleshooting

### Controller Not Detected
- Ensure controller is properly connected
- Check Godot has gamepad permissions
- Try different USB port or re-pair Bluetooth
- Some controllers need to be in specific modes

### No Vibration
- Check vibration is enabled in settings
- Verify controller supports vibration
- Some controllers need drivers on PC

### Incorrect Button Prompts
- Controller type detection is name-based
- Generic controllers show numbered buttons
- Can be overridden in settings (future feature)

### Analog Stick Issues
- Adjust deadzone if experiencing drift
- Calibrate controller in OS settings
- Check for worn analog sticks

## Platform Notes

### Windows
- Xbox controllers work natively
- PS4/PS5 need DS4Windows for best support
- Most controllers work via XInput

### Linux
- Most controllers work via SDL2
- May need to install gamepad drivers
- Steam Input can help with compatibility

### Web Export
- Limited controller support in browsers
- Vibration may not work
- Best with Chrome/Edge

## Future Enhancements
- Button remapping UI
- Multiple controller support
- Profile saving per controller type
- Gyro/motion control support
- Adaptive triggers (PS5)