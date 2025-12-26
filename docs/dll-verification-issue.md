# .NET DLL Verification Issue - Root Cause Analysis

## Issue Summary

**Error:** "DLL not verified" when launching SCUM after using SCUM Admin Helper

**Date Discovered:** December 26, 2024

**Affected Component:** .NET Framework 4.8 in SCUM's Proton prefix (AppID 513710)

## Technical Details

### What Happened

The .NET Framework 4.8 package appeared to be installed correctly (visible in `wine uninstaller --list`), but critical registry entries required for assembly verification were missing or corrupted.

**Symptoms:**
- "DLL not verified" error when launching SCUM
- .NET assembly strong-name verification failures
- Global Assembly Cache (GAC) unable to verify DLLs

### Root Cause

The issue occurred because .NET Framework registry entries in the Wine prefix became corrupted or incomplete. Specifically:

```
Registry Key Missing:
HKLM\Software\Microsoft\.NETFramework\v4.0.30319\InstallPath
```

This registry key is essential for:
1. .NET runtime locating framework assemblies
2. Global Assembly Cache (GAC) verification
3. Strong-name signature validation
4. Assembly loader finding core .NET DLLs

### Why This Happens

Several factors can cause .NET Framework registry corruption in Wine/Proton:

1. **Incomplete Initial Installation**
   - Network interruption during download
   - Insufficient disk space during installation
   - MSI installation errors that went unnoticed
   - Race conditions in winetricks installation process

2. **Wine/Proton Version Changes**
   - Switching between different Proton versions
   - Proton updates that change registry handling
   - Compatibility issues between Wine versions
   - Registry format changes in newer Wine releases

3. **File System Issues**
   - Power loss during installation
   - Disk errors affecting registry hive files
   - Permissions issues on prefix directories
   - Antivirus interference (on some systems)

4. **Wine-Mono vs .NET Framework Conflicts**
   - Wine-Mono and .NET Framework both present
   - Conflicting assembly registrations
   - GAC conflicts between implementations
   - DLL override configuration issues

5. **Proton Prefix Corruption**
   - Steam client crashes during prefix updates
   - Multiple simultaneous prefix access
   - Shader cache corruption affecting prefix integrity

### Why It Appeared "Fixed" Previously

The issue was "fixed" before by installing .NET runtimes, which worked because:
- Fresh installation created proper registry entries
- Assembly cache was rebuilt cleanly
- Strong-name verification database was recreated

However, the underlying vulnerability remained, causing the issue to recur when:
- Proton was updated
- Prefix was modified by other operations
- Registry experienced any corruption

## The Solution

### Force Reinstallation of .NET Framework 4.8

```bash
protontricks 513710 --force dotnet48
```

**What This Does:**
1. **Removes** existing broken installation markers
2. **Downloads** fresh .NET Framework installers
3. **Reinstalls** all .NET components from scratch
4. **Recreates** all registry entries including critical InstallPath
5. **Re-verifies** all assemblies in Global Assembly Cache
6. **Configures** mscoree (runtime loader) native DLL override
7. **Creates** installation marker file for future reference

**Why --force is Required:**
- Without `--force`, winetricks sees .NET as "already installed"
- Installation marker file exists: `dotnet48.installed.workaround`
- Registry check passes (basic check, not detailed)
- Winetricks skips installation, leaving corruption in place

### Automated Solution Created

We created `scripts/reinstall-dotnet.sh` which:
- Detects SCUM Proton prefix automatically
- Shows current .NET Framework status
- Verifies registry entries before/after
- Provides detailed logging
- Offers to test SAH after completion
- Gives clear feedback on success/failure

Also integrated into GUI helper:
- `./scripts/sah-helper.sh` → Troubleshooting → Reinstall .NET

## Prevention

### Best Practices

1. **Keep Backups**
   ```bash
   ./scripts/backup-sah.sh  # Choose option 2 for full prefix backup
   ```

2. **Avoid Proton Downgrades**
   - Stick with one Proton version once .NET is installed
   - Don't switch between Experimental/Stable unnecessarily

3. **Verify After Steam Updates**
   ```bash
   protontricks -c 'wine reg query "HKLM\\Software\\Microsoft\\.NETFramework\\v4.0.30319" /v InstallPath' 513710
   ```

4. **Monitor Disk Health**
   ```bash
   df -h  # Check disk space
   smartctl -a /dev/sdX  # Check disk health (if available)
   ```

5. **Use Stable Wine Versions in Production**
   - wine-10.0 (CachyOS) is a testing version
   - Consider stable Wine releases for critical prefixes
   - Check Wine changelog for registry-affecting changes

### Detection Script

Can add to startup checks:

```bash
#!/bin/bash
# Quick .NET health check
APPID=513710
if ! protontricks -c 'wine reg query "HKLM\\Software\\Microsoft\\.NETFramework\\v4.0.30319" /v InstallPath' $APPID 2>&1 | grep -q "InstallPath"; then
    echo "WARNING: .NET Framework registry entries missing!"
    echo "Run: ./scripts/reinstall-dotnet.sh"
fi
```

## Long-term Considerations

### Wine/Proton Improvements Needed

1. **Better .NET Framework Support**
   - More complete registry emulation
   - Improved GAC implementation
   - Better strong-name verification support

2. **Installation Verification**
   - Post-install registry validation
   - Assembly cache integrity checks
   - Automatic corruption detection

3. **Prefix Migration Tools**
   - Safe Proton version upgrades
   - Registry structure migration
   - Component verification after updates

### Alternative Approaches (Future)

1. **Wine-Mono Improvements**
   - Better Windows Forms compatibility
   - Complete API compatibility with .NET Framework
   - Would eliminate need for .NET Framework installation

2. **Native Linux SAH Port**
   - Best long-term solution
   - Eliminate Wine/Proton dependencies
   - Direct Linux compatibility

3. **Containerized Prefix**
   - Isolated .NET installation
   - Protected from system changes
   - Reproducible environments

## Documentation Added

1. **Troubleshooting Guide** (`docs/troubleshooting.md`)
   - New section: "DLL Not Verified / .NET Assembly Errors"
   - Detailed explanation of issue
   - Multiple solution options
   - Verification steps

2. **Reinstall Script** (`scripts/reinstall-dotnet.sh`)
   - Automated .NET Framework reinstallation
   - Status checking before/after
   - Detailed logging
   - User-friendly prompts

3. **GUI Integration** (`scripts/sah-helper.sh`)
   - Added to Troubleshooting menu
   - One-click .NET reinstall
   - Terminal launch for progress viewing

## References

- Wine Bug Tracker: .NET Framework registry issues
- Proton GitHub: Known .NET Framework limitations
- winetricks: dotnet48 installation details
- Microsoft Docs: .NET Framework registry structure

## Lessons Learned

1. **Registry verification is essential** - Package appearance != full functionality
2. **Force reinstall is sometimes necessary** - Marker files can be misleading
3. **Wine testing versions have risks** - wine-10.0 is experimental
4. **Good logging is critical** - Detailed logs helped identify the issue
5. **User-friendly tools matter** - Automated scripts make fixes accessible

---

**Documented by:** SAH Helper Development Team  
**Last Updated:** December 26, 2024  
**Status:** Resolved with automated fix script
