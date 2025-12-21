# Frequently Asked Questions (FAQ)

## General Questions

### What is SCUM Admin Helper?

**SCUM Admin Helper** (SAH) is a Windows-only application for managing SCUM game servers, developed by community developers and supported through donations. It provides features like player management, server administration, and real-time monitoring.

### What is SAH Helper for Linux?

**SAH Helper for Linux** (this project) is an unofficial community tool that provides automated installation, desktop integration, and management for running the Windows SAH application on Linux using Proton/Wine.

### Why can't SAH run natively on Linux?

SAH is built using .NET Framework (Windows-only technology). While there are Linux alternatives for .NET development (.NET Core), SAH specifically requires Windows .NET Framework.

### Is this official?

No, SAH Helper for Linux is an **unofficial community tool**. SCUM Admin Helper itself is developed and maintained by its respective creators. This project only provides Linux installation automation and integration.

### Does installing SAH help with SCUM multiplayer on Linux?

**Yes, possibly!** The .NET Framework installation required by SAH may also enable SCUM multiplayer functionality on Linux (which is normally broken without .NET). This is an unintended bonus benefit.

**Important**: This multiplayer functionality is not guaranteed and may break with future SCUM updates. It's a side effect of having .NET Framework installed in SCUM's Proton prefix, not an official feature of either SCUM or SAH.

## Installation Questions

### Do I need to install Windows?

No. The scripts use Proton (Wine + compatibility layers) to run SAH within SCUM's existing Windows compatibility environment.

### How long does installation take?

- **With existing .NET**: 5-10 minutes
- **Fresh install**: 20-30 minutes (includes .NET Framework installation)
- Download speed affects total time (~110MB SAH + dependencies)

### Can I install SAH multiple times?

Yes. The installer detects existing installations and offers to:
- Skip if already installed
- Reinstall/repair
- Update (when new versions available)

### What gets installed where?

- **SAH Application**: `$STEAM_LIBRARY/steamapps/compatdata/513710/pfx/drive_c/users/steamuser/AppData/Local/SCUM_Admin_Helper/`
- **.NET Framework**: `$STEAM_LIBRARY/steamapps/compatdata/513710/pfx/drive_c/windows/Microsoft.NET/`
- **Launch Script**: `$STEAM_LIBRARY/steamapps/common/SCUM/launch-sah.sh`
- **Desktop Shortcut**: `~/.local/share/applications/scum-admin-helper.desktop`
- **Backups**: `~/sah-backups/`

### Does this modify SCUM game files?

No. SAH installs into SCUM's Proton prefix (the Windows environment) but doesn't touch SCUM game files. SCUM remains completely unaffected.

## Usage Questions

### How do I launch SAH?

Three methods:
1. **Application Menu** (easiest): Search "SCUM Admin Helper"
2. **Direct**: Run `/path/to/SCUM/launch-sah.sh`
3. **GUI**: `./scripts/sah-gui.sh` → Manual Control → Launch SAH

### Do I need to launch SAH every time I play SCUM?

Only if you want to use SAH features. SAH is for server administration, not regular gameplay. Most players don't need SAH at all.

### Can I use Steam launch options?

Not recommended. SAH cannot run within Steam's runtime environment due to Vulkan/DXVK incompatibility. Desktop shortcut method is more reliable.

### Why does Steam show SCUM as "running" when only SAH is open?

SAH uses SCUM's Proton prefix (App ID 513710). Steam sees Wine/Proton activity and thinks SCUM is running. This is expected behavior and doesn't affect anything. You can:
- Ignore it (recommended)
- Close SAH first, then launch SCUM
- Launch SCUM anyway (both will run fine)

### How do I close SAH?

```bash
# Method 1: Close window normally (X button)

# Method 2: Terminal command
pkill -f "SCUM Admin Helper.exe"

# Method 3: Via GUI
./scripts/sah-gui.sh  # → Manual Control → Stop SAH

# Method 4: Force kill
./scripts/kill-sah.sh
```

### Can SAH and SCUM run simultaneously?

Yes. That's the normal usage pattern:
1. Launch SAH
2. Configure server settings
3. Launch SCUM
4. Play while SAH manages server
5. Close both when done

## Technical Questions

### Which Proton version is used?

Whatever version SCUM uses. SAH runs in SCUM's existing Proton prefix, so it automatically uses the same Proton version.

### Can I use a different Proton version?

Not easily. SAH needs to share SCUM's prefix for .NET compatibility. Using a separate prefix causes .NET Framework incompatibilities.

### What .NET versions are required?

- .NET Framework 4.0 (required)
- .NET Framework 4.8 (required)
- VC++ Runtime 2019 (required)

The installer detects and installs these automatically.

### Can I run multiple SAH instances?

Yes, but each needs a separate Proton prefix. This is complex and not officially supported by this project. For most users, one instance is sufficient.

### Does this work on non-Steam SCUM?

No. This project requires:
- SCUM from Steam
- Steam's Proton compatibility layer
- SCUM's existing Proton prefix

Non-Steam versions would need different setup.

## Backup Questions

### Should I create backups?

**Yes, recommended before:**
- First SAH usage with live server
- Major SAH updates
- Prefix modifications
- Testing new configurations

### What's the difference between backup types?

- **SAH Only** (~100MB): Just SAH application, settings, and .NET info. Quick backup/restore. Use for routine backups.
- **Full Prefix** (~2-5GB): Everything in SCUM's Proton prefix. Slower but includes all modifications. Use before major changes.

### Where are backups stored?

`~/sah-backups/backup-YYYYMMDD-HHMMSS/`

Each backup is timestamped for easy identification.

### How do I restore a backup?

**Via GUI:**
```bash
./scripts/sah-gui.sh
# → Backup Management → Restore Backup
```

**Via CLI:**
```bash
./scripts/restore-sah.sh
```

### Can I delete old backups?

Yes, via GUI (Backup Management → Delete Backups) or manually:
```bash
rm -rf ~/sah-backups/backup-YYYYMMDD-HHMMSS/
```

## Troubleshooting Questions

### SAH won't start. What do I check?

```bash
# 1. Verify installation
find ~/.steam -name "SCUM Admin Helper.exe"

# 2. Check .NET
find ~/.steam -path "*/Microsoft.NET/Framework/v4.0.30319"

# 3. Test launch manually
/path/to/SCUM/launch-sah.sh

# 4. Check logs
cat /tmp/sah-launch.log

# 5. Use GUI diagnostic
./scripts/sah-gui.sh  # → Status
```

### Installation fails. What do I do?

```bash
# 1. Check dependencies
protontricks --version
zenity --version

# 2. Verify SCUM was run once
ls ~/.steam/steam/steamapps/compatdata/513710/pfx/

# 3. Check disk space
df -h ~  # Need at least 5GB free

# 4. Review logs
cat /tmp/sah-install*.log

# 5. Try reinstall
./scripts/install-sah.sh
```

### Where can I get help?

1. **Check documentation**: [troubleshooting.md](troubleshooting.md)
2. **Use GUI**: `./scripts/sah-gui.sh` → Troubleshooting
3. **Check logs**: `/tmp/sah-*.log`
4. **GitHub Issues**: Report bugs with logs
5. **Community**: SCUM forums and Discord

## Performance Questions

### Does SAH affect game performance?

Minimal impact. SAH runs in the background using Wine/Proton, similar to any other background application. SCUM performance should be unaffected.

### How much RAM does SAH use?

Typically 100-300MB including Wine overhead. This is in addition to SCUM's memory usage.

### Does SAH require GPU resources?

No. SAH is primarily CPU/RAM-based for server management. It doesn't render graphics or use GPU significantly.

## Update Questions

### How do I update SAH?

Download the new version and run the installer again. It will:
1. Detect existing installation
2. Offer to reinstall/update
3. Preserve your settings (backed up automatically)

### How do I update this script collection?

```bash
cd /path/to/sah-scripts
git pull  # If using git

# Or download new version and run:
./scripts/install-sah.sh
```

### Do I need to update Proton?

No. SAH uses whatever Proton version SCUM uses. Update SCUM normally via Steam.

## Uninstallation Questions

### How do I uninstall SAH?

**Complete removal:**
```bash
# Remove SAH
find ~/.steam -path "*/SCUM_Admin_Helper" -exec rm -rf {} +

# Remove desktop shortcut
rm ~/.local/share/applications/scum-admin-helper.desktop

# Remove launch script
rm /path/to/SCUM/launch-sah.sh

# Remove backups (optional)
rm -rf ~/sah-backups/
```

**Via backup/restore:**
Use a backup created before SAH installation, or a "clean" prefix backup.

### Does uninstalling affect SCUM?

No. Removing SAH only removes SAH files. SCUM game files and saves remain untouched.

### Can I reinstall after uninstalling?

Yes. Just run `./scripts/install-sah.sh` again. You may need to reinstall .NET dependencies if you removed them.

## Advanced Questions

### Can I modify the launch script?

Yes. It's located at `/path/to/SCUM/launch-sah.sh`. You can:
- Add environment variables
- Modify Wine settings
- Add logging
- Change launch behavior

Just ensure `protontricks-launch --appid 513710` is used to maintain compatibility.

### Can I use winetricks directly?

Yes, but use protontricks instead:
```bash
protontricks 513710 --gui  # GUI mode
protontricks 513710 winecfg  # Wine configuration
```

This ensures you're modifying the correct prefix.

### What if I want to use a custom Wine build?

This project uses Proton (Steam's Wine build). Using custom Wine builds requires:
- Manual WINEPREFIX setup
- Manual .NET installation
- Custom launch scripts

Not officially supported by this project.

### Can I run SAH in a Docker container?

Theoretically possible but complex:
- Needs X11 forwarding
- Requires Wine in container
- GPU passthrough for Vulkan
- Not recommended or supported

## Contributing Questions

### Can I contribute to this project?

Yes! Contributions welcome:
1. Fork the repository
2. Make improvements
3. Test thoroughly
4. Submit pull request

### I found a bug. How do I report it?

1. Collect diagnostic info (see troubleshooting.md)
2. Check if issue already exists
3. Open GitHub Issue with:
   - Your Linux distro and version
   - Error messages and logs
   - Steps to reproduce
   - Expected vs actual behavior

### Can I request features?

Yes! Open a GitHub Issue with "Feature Request" label. Describe:
- What you want
- Why it's useful
- How you envision it working

---

**Still have questions?** 
- Check [installation.md](installation.md) for setup help
- Check [troubleshooting.md](troubleshooting.md) for problem solutions
- Open a GitHub Issue for bugs or feature requests
