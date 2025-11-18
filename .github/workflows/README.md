# GitHub Actions Workflows

This directory contains GitHub Actions workflows for automated building, testing, and releasing of KOverlay.

## Workflows

### 1. CI Build (`ci.yml`)

**Triggers:**
- Push to `main`, `master`, or `develop` branches
- Pull requests to `main` or `master`

**Jobs:**

#### build-fedora
- Builds KOverlay binary on Fedora (latest)
- Verifies build dependencies
- Uploads binary artifact (7-day retention)

#### build-rpm
- Creates RPM package using `build_rpm.sh`
- Runs on Fedora container
- Uploads RPM artifact (30-day retention)
- Shows RPM package contents and metadata

#### lint-shellcheck
- Runs shellcheck on all shell scripts
- Helps catch common shell scripting issues

**Artifacts:**
- `koverlay-binary-fedora` - Compiled binary
- `koverlay-rpm` - RPM package

---

### 2. Release (`release.yml`)

**Triggers:**
- Git tags matching `v*.*.*` (e.g., `v1.0.2`)

**Jobs:**

#### build-and-release
- Builds binary and RPM on Fedora
- Extracts version from git tag
- Creates SHA256 checksums
- Creates GitHub Release with:
  - Binary (renamed with version)
  - RPM package
  - Checksums file
  - Auto-generated release notes

#### build-copr
- Notification step for COPR builds
- Manual trigger reminder for COPR repository

**Release Assets:**
```
koverlay-X.Y.Z-x86_64          # Standalone binary
koverlay-X.Y.Z-1.x86_64.rpm    # RPM package
checksums.txt                   # SHA256 checksums
```

**Creating a Release:**

1. **Update version in CMakeLists.txt:**
   ```cmake
   project(koverlay VERSION X.Y.Z LANGUAGES CXX)
   ```

2. **Commit and tag:**
   ```bash
   git add CMakeLists.txt
   git commit -m "release: vX.Y.Z - description"
   git tag -a vX.Y.Z -m "Release version X.Y.Z"
   git push origin main --tags
   ```

3. **Workflow runs automatically** and creates GitHub Release

---

### 3. PR Checks (`pr-checks.yml`)

**Triggers:**
- Pull requests to `main` or `master`

**Jobs:**

#### check-build
- Verifies code compiles successfully
- Checks binary is created and executable
- Ensures no build regressions

#### code-quality
- Checks file permissions
- Scans for TODO/FIXME comments
- Verifies required files exist

#### documentation
- Checks if README updated with code changes
- Validates markdown syntax
- Ensures documentation stays in sync

**Purpose:** Catch common issues before merge

---

## Workflow Status

[![CI Build](https://github.com/Defiect/koverlay/actions/workflows/ci.yml/badge.svg)](https://github.com/Defiect/koverlay/actions/workflows/ci.yml)
[![Release](https://github.com/Defiect/koverlay/actions/workflows/release.yml/badge.svg)](https://github.com/Defiect/koverlay/actions/workflows/release.yml)

---

## Dependencies

All workflows run in Fedora containers with these dependencies:
- cmake
- gcc-c++
- qt6-qtbase-devel
- qt6-qtdeclarative-devel
- qt6-qtwayland-devel
- layer-shell-qt-devel
- wayland-devel
- rpm-build

---

## Secrets Required

### GITHUB_TOKEN
- **Provided automatically** by GitHub Actions
- Used for creating releases
- No manual configuration needed

### Optional Secrets

For future enhancements:
- `COPR_TOKEN` - For automatic COPR builds
- `GPG_PRIVATE_KEY` - For signing RPMs

---

## Artifacts Retention

| Artifact | Retention | Workflow |
|----------|-----------|----------|
| Binary (CI) | 7 days | ci.yml |
| RPM (CI) | 30 days | ci.yml |
| Releases | Permanent | release.yml |

---

## Troubleshooting

### Build fails on Fedora container

**Problem:** Dependencies not found
**Solution:** Update dependency list in workflow YAML

### Release not created on tag

**Problem:** Tag doesn't match pattern
**Solution:** Ensure tag starts with `v` and follows semver (e.g., `v1.2.3`)

### Artifact upload fails

**Problem:** File not found
**Solution:** Check build script output paths match workflow expectations

---

## Local Testing

You can test workflows locally using [act](https://github.com/nektos/act):

```bash
# Install act
sudo dnf install act  # or: brew install act

# Test CI workflow
act -j build-fedora

# Test PR checks
act pull_request
```

**Note:** Fedora container may not work perfectly with act; prefer testing on actual GitHub Actions.

---

## Future Enhancements

Potential improvements:
- [ ] Add code coverage reporting
- [ ] Implement automatic COPR builds
- [ ] Add static analysis (cppcheck, clang-tidy)
- [ ] Build for multiple distributions (Arch, Ubuntu)
- [ ] Add performance benchmarks
- [ ] Sign RPM packages with GPG

---

## Contributing

When adding new workflows:
1. Test locally if possible
2. Use descriptive job names
3. Add comments for complex steps
4. Update this README
5. Use proper error handling

---

## References

- [GitHub Actions Documentation](https://docs.github.com/en/actions)
- [Workflow Syntax](https://docs.github.com/en/actions/reference/workflow-syntax-for-github-actions)
- [Fedora Container Images](https://hub.docker.com/_/fedora)
- [softprops/action-gh-release](https://github.com/softprops/action-gh-release)
