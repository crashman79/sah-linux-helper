# Contributing to SAH Helper for Linux

Thank you for considering contributing! This project helps Linux users run SCUM Admin Helper via Proton.

## How to Contribute

### Reporting Bugs

1. Check if the issue already exists in [Issues](https://github.com/crashman79/sah-linux-helper/issues)
2. Use the bug report template
3. Include:
   - Linux distro and version
   - Complete error messages and logs
   - Steps to reproduce
   - System information (see template)

**Note**: Only report bugs related to the installer/scripts. For SAH app issues, contact the SAH developers.

### Suggesting Features

1. Use the feature request template
2. Explain the use case
3. Describe the expected behavior
4. Consider implementation complexity

### Submitting Code

1. **Fork** the repository
2. **Create a branch**: `git checkout -b feature/your-feature-name`
3. **Make changes**:
   - Follow existing code style
   - Use bash best practices
   - Add comments for complex logic
   - Test on at least one Linux distro
4. **Update documentation**:
   - Update README.md if needed
   - Update relevant docs/ files
   - Add entry to CHANGELOG.md
5. **Test thoroughly**:
   - Test installation on clean system
   - Test all GUI functions
   - Test backup/restore
   - Check for edge cases
6. **Commit**: Use clear, descriptive commit messages
7. **Push**: `git push origin feature/your-feature-name`
8. **Pull Request**: Open PR with clear description

## Code Style

### Bash Scripts

- Use `#!/bin/bash` shebang
- Indent with 4 spaces (not tabs)
- Quote variables: `"$variable"` not `$variable`
- Use `[[ ]]` for conditionals, not `[ ]`
- Function names: `lowercase_with_underscores`
- Constants: `UPPERCASE_WITH_UNDERSCORES`
- Local variables in functions: `local var_name`
- Check errors: Use `|| { error handling; }`

### Example:
```bash
#!/bin/bash

CONSTANT_VALUE=513710

function check_status() {
    local status_file="$1"
    
    if [[ -f "$status_file" ]]; then
        echo "Status file found"
        return 0
    else
        echo "ERROR: Status file not found" >&2
        return 1
    fi
}
```

### Documentation

- Use Markdown for all docs
- Keep line length reasonable (~80-100 chars)
- Use code blocks with language tags
- Include examples
- Cross-reference other docs
- Keep CHANGELOG.md updated

### Zenity (GUI)

- Always redirect stderr: `2>/dev/null`
- Use `--no-wrap` for info dialogs
- Set appropriate widths/heights
- Provide clear button labels
- Show progress for long operations

## Testing Checklist

Before submitting PR, verify:

- [ ] Scripts are executable (`chmod +x`)
- [ ] No syntax errors (`bash -n script.sh`)
- [ ] Works on at least one distro
- [ ] GUI functions work (if modified)
- [ ] Installation succeeds on clean system
- [ ] Backup/restore functions work
- [ ] Error handling works
- [ ] Logs are written correctly
- [ ] Documentation updated
- [ ] CHANGELOG.md updated

## Distribution Testing

If possible, test on multiple distros:
- Ubuntu/Debian-based
- Fedora/RHEL-based  
- Arch-based

## Project Structure

```
sah-scripts/
├── scripts/          # Main scripts
│   ├── sah-gui.sh   # GUI (primary interface)
│   ├── install-sah.sh  # Installer
│   └── *.sh         # Utility scripts
├── docs/            # Documentation
│   ├── installation.md
│   ├── troubleshooting.md
│   └── FAQ.md
├── examples/        # Example configs
└── .github/         # GitHub templates
```

## What We're Looking For

### High Priority
- Bug fixes
- Platform compatibility improvements
- Documentation improvements
- Performance optimizations
- Error handling improvements

### Medium Priority
- New utility features
- GUI enhancements
- Better logging
- Additional distro support

### Low Priority
- Code refactoring (if justified)
- Style improvements
- Minor convenience features

## What We're NOT Looking For

- Changes to SCUM Admin Helper itself (that's a separate project)
- Features unrelated to Linux installation/management
- Breaking changes without discussion
- Unnecessary complexity
- Platform-specific hacks that break other platforms

## Communication

- **Issues**: For bugs and feature requests
- **Pull Requests**: For code contributions
- **Discussions**: For questions and ideas

## Code of Conduct

- Be respectful and professional
- Help others learn
- Accept constructive criticism
- Focus on the project goals
- Remember this is volunteer work

## License

By contributing, you agree that your contributions will be licensed under the MIT License.

## Questions?

Open an issue or discussion if you have questions about contributing!

---

**Thank you for contributing to SAH Helper for Linux!** 🎉
