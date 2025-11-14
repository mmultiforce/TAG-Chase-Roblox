# Project Structure for Roblox Studio

This document shows exactly where to place each script file in Roblox Studio.

## ServerScriptService Structure

```
ServerScriptService/
└── TagChaseGame/
    ├── MainGameScript.server.lua          (Regular Script)
    ├── TagChaseGameManager.server.lua     (Regular Script)
    ├── RoleManager.module.lua             (ModuleScript)
    ├── SpawnManager.module.lua            (ModuleScript)
    └── UIManager.module.lua               (ModuleScript)
```

## StarterPlayer Structure

```
StarterPlayer/
└── StarterPlayerScripts/
    └── ClientUIHandler.client.lua         (LocalScript)
```

## Step-by-Step Setup Instructions

### 1. Create the ServerScriptService Folder
1. In Roblox Studio, go to the Explorer window
2. Find "ServerScriptService"
3. Right-click on ServerScriptService
4. Select "Insert Object" → "Folder"
5. Name the folder "TagChaseGame"

### 2. Add Server Scripts
Inside the TagChaseGame folder:

1. **MainGameScript.server.lua**
   - Right-click TagChaseGame folder
   - Select "Insert Object" → "Script"
   - Name it "MainGameScript.server.lua"
   - Replace the default code with the contents of `MainGameScript.server.lua`

2. **TagChaseGameManager.server.lua**
   - Right-click TagChaseGame folder
   - Select "Insert Object" → "Script"
   - Name it "TagChaseGameManager.server.lua"
   - Replace the default code with the contents of `TagChaseGameManager.server.lua`

3. **RoleManager.module.lua**
   - Right-click TagChaseGame folder
   - Select "Insert Object" → "ModuleScript"
   - Name it "RoleManager.module.lua"
   - Replace the default code with the contents of `RoleManager.module.lua`

4. **SpawnManager.module.lua**
   - Right-click TagChaseGame folder
   - Select "Insert Object" → "ModuleScript"
   - Name it "SpawnManager.module.lua"
   - Replace the default code with the contents of `SpawnManager.module.lua`

5. **UIManager.module.lua**
   - Right-click TagChaseGame folder
   - Select "Insert Object" → "ModuleScript"
   - Name it "UIManager.module.lua"
   - Replace the default code with the contents of `UIManager.module.lua`

### 3. Add Client Script
1. In the Explorer, find "StarterPlayer"
2. Expand it and find "StarterPlayerScripts"
3. Right-click StarterPlayerScripts
4. Select "Insert Object" → "LocalScript"
5. Name it "ClientUIHandler.client.lua"
6. Replace the default code with the contents of `ClientUIHandler.client.lua`

## Script Types Explained

- **Regular Script (.server.lua)**: Runs on the server
- **ModuleScript (.module.lua)**: Reusable code modules
- **LocalScript (.client.lua)**: Runs on each player's client

## Final Structure Verification

Your Explorer should look like this:

```
📁 ServerScriptService
  └── 📁 TagChaseGame
      ├── 📄 MainGameScript.server.lua
      ├── 📄 TagChaseGameManager.server.lua
      ├── 📄 RoleManager.module.lua
      ├── 📄 SpawnManager.module.lua
      └── 📄 UIManager.module.lua

📁 StarterPlayer
  └── 📁 StarterPlayerScripts
      └── 📄 ClientUIHandler.client.lua
```

## Testing the Setup

1. Click "Play" in Roblox Studio
2. Check the Output window for these messages:
   - "TAG/CHASE GAME STARTING UP"
   - "Game Manager initialized and started!"
   - "TAG/CHASE GAME READY TO PLAY!"

If you see these messages, the setup is successful!

## Common Setup Mistakes

1. **Wrong Script Types**: Make sure ModuleScripts are actually ModuleScript objects
2. **Wrong Locations**: Ensure scripts are in the correct folders
3. **Missing Folders**: Create the TagChaseGame folder first
4. **Naming Issues**: Use exact names including extensions

## Troubleshooting

If the game doesn't start:

1. Check the Output window for errors
2. Verify all scripts are in the correct locations
3. Make sure script types are correct (Script vs ModuleScript vs LocalScript)
4. Ensure no syntax errors in the code
5. Try restarting Roblox Studio

## Ready to Play!

Once setup is complete, the game will:
- Automatically start when 2+ players join
- Create spawn zones and UI elements
- Handle all game mechanics automatically

Enjoy your TAG/CHASE game!