# TAG-Chase-Roblox - Version Progressive Chase

A complete TAG/CHASE game implementation for Roblox with progressive chase mechanics - when a survivor gets caught, they become a chaser too!

## Game Overview

TAG/CHASE Progressive est un jeu multijoueur où un chasseur initial doit attraper les survivants. **La particularité : quand un survivant se fait attraper, il devient chasseur à son tour !** Cela crée une dynamique intense où le nombre de chasseurs augmente progressivement. Le jeu suit le temps de survie de chaque joueur et affiche un classement détaillé à la fin.

## Features

### Core Gameplay
- **Système de Rôles Progressif**: Un chasseur initial sélectionné aléatoirement, tous les autres sont des survivants
- **Mécanique de Contagion**: Quand un survivant se fait attraper, il devient chasseur immédiatement !
- **Système de Spawn**: Zones séparées pour les chasseurs (rouge) et les survivants (vert)
- **Période de Grâce**: 5 secondes avant que le premier chasseur puisse bouger
- **Détection de Collision**: Conversion automatique en chasseur au contact
- **Boucle de Jeu**: Parties de 5 minutes avec fin automatique (quand tous sont attrapés ou temps écoulé)

### Système de Survie
- **Temps de Survie**: Suivi précis du temps de survie de chaque joueur
- **Conversion Progressive**: Les survivants deviennent chasseurs en se faisant attraper
- **Fin Dynamique**: Le jeu se termine quand tous les survivants sont attrapés
- **Classement Détaillé**: Affiche le temps de survie, le rôle final et les statistiques

### Features Visuelles
- **Indicateurs de Rôle**: Joueurs codés par couleur (rouge pour chasseurs, vert pour survivants)
- **Zones de Spawn**: Zones clairement marquées avec bordures visuelles
- **UI Temps Réel**: Affiche le rôle actuel, le timer, et le nombre de chasseurs/survivants
- **Annonces**: Notifications pour les conversions et événements du jeu

### Système UI
- **Affichage de Rôle**: Montre "TU ES LE CHASSEUR!" ou "TU SURVIS!" en français
- **Timer de Partie**: Affiche le temps restant en français
- **Compteur Dynamique**: Montre en temps réel le nombre de survivants et chasseurs
- **Tableau des Scores**: Statistiques finales avec temps de survie et classement

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

### Démarrage du Jeu
- Le jeu démarre automatiquement quand 2+ joueurs rejoignent
- Un joueur aléatoire est sélectionné comme chasseur initial
- Période de grâce de 5 secondes avant le début

### Mécanique de Conversion
- Quand un chasseur touche un survivant, le survivant devient chasseur immédiatement
- Le nouveau chasseur est téléporté dans la zone des chasseurs
- Les annonces en français informent tous les joueurs
- Le nombre de chasseurs augmente progressivement !

### Système de Survie et Scoring
- **Temps de Survie**: Suivi précis pour chaque joueur
- **Rôle Final**: "Winner - Survived!" pour ceux qui restent jusqu'à la fin
- **Attrapé**: Temps de survie enregistré au moment de la conversion
- **Classement**: Les survivants sont classés par temps de survie

### Fin de Partie
- Le jeu se termine quand tous les survivants sont attrapés OU après 5 minutes
- Les survivants restants sont déclarés gagnants
- Tableau des scores affiche le temps de survie de chacun

### Indicateurs Visuels
- **Chasseur**: Couleur rouge avec indicateur lumineux
- **Survivant**: Couleur verte avec indicateur distinct
- **Zones de Spawn**: Zones codées par couleur (rouge/vert)
- **UI en Temps Réel**: Compteurs de survivants/chasseurs et timer

## Technical Implementation

### Server Scripts
- **MainGameScript**: Initialise la structure du jeu et démarre le game manager
- **TagChaseGameManager**: Logique principale avec détection de collision et gestion de la conversion progressive
- **RoleManager**: Gestion des rôles (Chasseur/Survivant) et indicateurs visuels
- **SpawnManager**: Création des zones de spawn et gestion des téléportations
- **UIManager**: Gestion des RemoteEvents et mise à jour UI côté serveur

### Client Scripts
- **ClientUIHandler**: Mise à jour de l'UI joueur basée sur les événements serveur
- Gère l'affichage des rôles, le timer, et les annonces en français

### Communication
- Utilise RemoteEvents pour la communication client-serveur
- Mises à jour UI en temps réel pour tous les joueurs
- Architecture événementielle efficace pour la gestion progressive

## Customization

### Game Settings
Modifiez `GAME_CONFIG` dans `MainGameScript.server.lua`:
```lua
local GAME_CONFIG = {
    GAME_DURATION = 300, -- Durée de la partie en secondes
    GRACE_PERIOD = 5,     -- Période de grâce avant début
    SPAWN_ZONES_SEPARATION = 100, -- Distance entre zones
    CHASER_COLOR = BrickColor.new("Bright red"),    -- Couleur chasseurs
    SURVIVOR_COLOR = BrickColor.new("Bright green")  -- Couleur survivants
}
```

### Visual Customization
- Modifiez les couleurs dans `RoleManager.module.lua` (rouge/vert)
- Ajustez tailles des zones dans `SpawnManager.module.lua`
- Personnalisez les éléments UI dans `UIManager.module.lua`
- Modifiez les textes français dans `ClientUIHandler.client.lua`

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

Fonctionnalités potentielles à ajouter:
- Power-ups et capacités spéciales pour les survivants
- Différents modes de jeu (élimination, points, etc.)
- Tableaux des scores persistants et statistiques détaillées
- Personnalisations avancées des personnages
- Effets sonores et musique dynamique
- Cartes avec obstacles et zones spéciales
- Variations en équipe (chasseurs vs survivants)
- Système de niveaux et progression

## Support

For issues or questions:
1. Check the Output window in Roblox Studio
2. Verify all scripts are correctly placed
3. Ensure game has proper permissions
4. Test with multiple players for multiplayer issues

---

**Version du Jeu**: 2.0.0 - Progressive Chase  
**Dernière Mise à Jour**: 2024  
**Compatible**: Roblox Studio (Dernière Version)  
**Nouvelles Fonctionnalités**: Système de chasse progressive, temps de survie, UI en français