# Wine vs Proton Fix - December 25, 2024

## Critical Issue Resolved

### Problem
SAH was launching with **system Wine** instead of **Steam's Proton**, causing:
- ❌ Garbled/scrambled graphics
- ❌ Settings and registration key not found
- ❌ UI elements disappearing
- ❌ `err:d3d:wined3d_context_gl_update_window Failed to get device context` errors

### Root Cause
Scripts used `wine` command which invokes system Wine (wine-10.0), while the working desktop shortcut used `protontricks-launch` which uses Steam's Proton runtime. These are **different Wine environments** with different configurations.

### Solution
Changed all SAH launch methods to use `protontricks-launch --appid 513710` instead of `wine`.

## Files Modified

### scripts/sah-helper.sh
Updated 5 launch methods:
- Line 235: "SAH Only" desktop shortcut generation
- Line 287: "SCUM + SAH" launcher script generation  
- Line 398: "Test Launch SAH" menu option
- Line 453: "Manual Control → Launch SAH" 
- Line 583: "Launch SCUM + SAH" menu option

**Before:**
```bash
export WINEPREFIX="$wine_prefix"
wine "$sah_exe" &
```

**After:**
```bash
protontricks-launch --appid $SCUM_APPID "$sah_exe" &
```

### scripts/sah-env.sh
Disabled problematic environment variables that were added as "fixes" but actually made things worse:
- Commented out: `LIBGL_ALWAYS_SOFTWARE=1` (forced software rendering)
- Commented out: `__GL_SYNC_TO_VBLANK=0` (vsync)
- Commented out: `MESA_GL_VERSION_OVERRIDE=3.3` (GL version)
- Commented out: `__GL_SHADER_DISK_CACHE=0` (shader cache)
- Kept: `WINEDEBUG=-all,err+all` (reduces log spam)

### Documentation
- `README.md` - Added Proton explanation and requirements
- `docs/installation.md` - Clarified protontricks requirement
- `docs/troubleshooting.md` - Added "Garbled Graphics" section

## Results

### ✅ Fixed
- Graphics render properly (Direct3D/OpenGL working correctly)
- Settings and registration key persist between launches
- Consistent behavior across all launch methods
- No more `wined3d_context_gl_update_window` errors

### ⚠️ Harmless Warnings (Still Present)
These Wine warnings are normal and don't affect functionality:
- `err:ole:apartment_add_dll` - UI Automation (not critical)
- `err:quartz:FilterMapper3_RegisterFilter` - DirectShow filters (not needed)

## Key Takeaway

**Always use Steam's Proton for SAH:**
- ✅ `protontricks-launch --appid 513710 "SCUM Admin Helper.exe"`
- ❌ `wine "SCUM Admin Helper.exe"` (wrong environment)

The correct method ensures SAH runs in the same Wine environment as SCUM itself, with properly configured .NET Framework and rendering.
