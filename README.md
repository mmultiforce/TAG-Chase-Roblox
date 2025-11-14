# TAG-Chase-Roblox

A complete TAG/CHASE game implementation for Roblox with core gameplay mechanics, role management, and UI systems.

## Game Overview

TAG/CHASE is a multiplayer game where players take turns being the "Chaser" who tries to catch "Runners". When a Chaser catches a Runner, they switch roles. The game features a 5-minute round system with scoring and visual feedback.

## Features

### Core Gameplay
- **Player Role System**: Random player selection as Chaser, others as Runners
- **Spawning System**: Separate spawn zones for Chasers (red) and Runners (blue)
- **Grace Period**: 5-second grace period before Chaser can move
- **Collision Detection**: Automatic role switching when Chaser touches Runner
- **Game Loop**: 5-minute rounds with automatic restart

### Visual Features
- **Role Indicators**: Color-coded players (red for Chaser, blue for Runners)
- **Spawn Zones**: Clearly marked areas with visual boundaries
- **UI Elements**: Real-time role display, timer, and current Chaser information
- **Announcements**: In-game notifications for role changes and game events

### UI System
- **Role Display**: Shows current player role prominently
- **Countdown Timer**: Displays remaining game time
- **Chaser Indicator**: Shows who is currently the Chaser
- **Scoreboard**: End-game statistics showing tags and role changes

## File Structure

```
TAG-Chase-Roblox/
├── MainGameScript.server.lua          # Main game initialization
├── TagChaseGameManager.server.lua     # Core game logic controller
├── RoleManager.module.lua             # Player role management
├── SpawnManager.module.lua            # Spawn point and zone management
├── UIManager.module.lua               # UI system and communication
├── ClientUIHandler.client.lua         # Client-side UI updates
└── README.md                          # This file
```

## Installation & Setup

### 1. Place Scripts in Roblox Studio

1. Open your Roblox Studio project
2. Create a new folder in `ServerScriptService` called "TagChaseGame"
3. Place these scripts in the folder:
   - `MainGameScript.server.lua`
   - `TagChaseGameManager.server.lua`
   - `RoleManager.module.lua`
   - `SpawnManager.module.lua`
   - `UIManager.module.lua`

4. Place this script in `StarterPlayer/StarterPlayerScripts`:
   - `ClientUIHandler.client.lua`

### 2. Script Configuration

The scripts are pre-configured with optimal settings:
- **Game Duration**: 5 minutes (300 seconds)
- **Grace Period**: 5 seconds
- **Minimum Players**: 2
- **Spawn Zone Separation**: 100 studs

### 3. Testing

To test the game:

1. **Single Player Testing**:
   - Start the game in Roblox Studio
   - Add 2+ test players using the Test tab
   - Wait for automatic game start

2. **Multiplayer Testing**:
   - Publish the game to Roblox
   - Invite friends to join
   - Game will start automatically when 2+ players are present

## Game Mechanics

### Starting the Game
- Game automatically starts when 2+ players join
- One random player is selected as the initial Chaser
- 5-second grace period before gameplay begins

### Role Switching
- When Chaser touches a Runner, roles immediately switch
- New Chaser teleports to Chaser spawn zone
- New Runner teleports to Runner spawn zone
- Visual and audio feedback plays for all players

### Scoring System
- **Tags**: Number of players caught as Chaser
- **Tagged**: Number of times caught as Runner
- **Role Changes**: Total times switched roles
- Final scoreboard displays at game end

### Visual Indicators
- **Chaser**: Red color with glowing indicator
- **Runner**: Blue color with distinct indicator
- **Spawn Zones**: Color-coded areas (red/blue)
- **UI Updates**: Real-time role and timer information

## Technical Implementation

### Server Scripts
- **MainGameScript**: Initializes game structure and starts game manager
- **TagChaseGameManager**: Core game logic, collision detection, and state management
- **RoleManager**: Handles role assignment and visual indicators
- **SpawnManager**: Creates spawn zones and manages player spawning
- **UIManager**: Manages RemoteEvents and server-side UI updates

### Client Scripts
- **ClientUIHandler**: Updates player UI based on server events
- Handles role display, timer updates, and announcements

### Communication
- Uses RemoteEvents for client-server communication
- Real-time UI updates for all players
- Efficient event-driven architecture

## Customization

### Game Settings
Edit `GAME_CONFIG` in `MainGameScript.server.lua`:
```lua
local GAME_CONFIG = {
    GAME_DURATION = 300, -- Change game length
    GRACE_PERIOD = 5,     -- Change grace period
    SPAWN_ZONES_SEPARATION = 100, -- Change zone distance
    CHASER_COLOR = BrickColor.new("Bright red"),    -- Change colors
    RUNNER_COLOR = BrickColor.new("Bright blue")
}
```

### Visual Customization
- Modify colors in `RoleManager.module.lua`
- Adjust spawn zone sizes in `SpawnManager.module.lua`
- Customize UI elements in `UIManager.module.lua`

## Troubleshooting

### Common Issues

1. **Game Not Starting**:
   - Ensure at least 2 players are in the game
   - Check that all scripts are in correct locations
   - Look for error messages in Output window

2. **UI Not Displaying**:
   - Verify `ClientUIHandler.client.lua` is in `StarterPlayerScripts`
   - Check that RemoteEvents are being created
   - Ensure PlayerGui is accessible

3. **Spawn Issues**:
   - Make sure `SpawnManager.initialize()` is called
   - Check workspace for spawn zone creation
   - Verify character loading order

### Debugging
- Check Output window for error messages
- Use print statements (already included) to track game state
- Test with multiple players to verify multiplayer functionality

## Performance Considerations

- Optimized collision detection with touch events
- Efficient RemoteEvent communication
- Cleanup functions to prevent memory leaks
- Proper object pooling for UI elements

## Future Enhancements

Potential features to add:
- Power-ups and abilities
- Different game modes
- Leaderboards and statistics
- Customizable characters
- Sound effects and music
- Maps with obstacles
- Team-based variations

## Support

For issues or questions:
1. Check the Output window in Roblox Studio
2. Verify all scripts are correctly placed
3. Ensure game has proper permissions
4. Test with multiple players for multiplayer issues

---

**Game Version**: 1.0.0  
**Last Updated**: 2024  
**Compatible**: Roblox Studio (Latest Version)