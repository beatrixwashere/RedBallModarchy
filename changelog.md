# v.1.0003

### pack info
- level mods can now use pack info scenes to display information about the mod
- for more info, see the *pack info* section in the modarchy text tutorial

### pause fixes
- use datahelper to store volume
- preload volume and window text
- add keybinds for toggling pause menu
- turning on fullscreen now consistently works

---

# v.1.0002

### pause menu
- rb1 now has a fully functional pause menu
- this is required for all levels going forward; just copy it from `level_1`

### a ton of bugfixes
- ignore extra .remap extension present in standalone builds
- ignore the _mods folder when making github commits
- use continuous collision detection
- update rapier to latest version
- added audio to the level select buttons
- fixed some texturepolygon processing issues
- add entity enter/exit functionality
- level select forces displaying scene files only

---

# v.1.0001

### global modules
- you can make a `global.tscn` file in your mod to support global loading
- this scene should just be a node with a script attached for `ModAPI` calls
- in standalone builds, click on the module again in the menu to make it global (icon is a yellow star)
- in the editor, add the mod name to the `global_modules` array in `mod_api.gd` (remember to clear it if you're exporting a standalone)

### custom entities
- you can now use `ModAPI.add_entity(entity_name: String, func_name: String)` to scan for custom entities
- entity_name should be the type of entity (parent name), and func_name should be a function added through `add_function`
- the function used must have an `Area2D` argument in it (ex: `entity_func(area: Area2D)`)

### miscellaneous
- added a performance info panel that can be toggled with f1 ingame (warning: can slightly worsen performance when visible)
- fixed an issue with setting the mod folder

---

# v.1.0000

- private release of modarchy!
