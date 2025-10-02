# Contributing to ds4owd-002 Website

Thank you for contributing to the Data Science for OpenWashData course website!

## Team Roles

- **Maintainer**: @larnsce - Reviews and merges PRs from `dev` to `main`
- **Contributors**: @massarin, @seawaR - Create feature branches and submit PRs to `dev`

## Branching Workflow

We follow a structured Git workflow to maintain code quality:

1. **Main branch** (`main`): Production-ready code, deployed to GitHub Pages
2. **Development branch** (`dev`): Integration branch for all features
3. **Feature branches**: Individual contributions from `dev`

### Contributing Changes

1. **Create a feature branch from `dev`**:
   ```bash
   git checkout dev
   git pull origin dev
   git checkout -b feature-name
   ```

2. **Make your changes** and commit regularly:
   ```bash
   git add .
   git commit -m "Description of changes"
   ```

3. **Push your feature branch**:
   ```bash
   git push origin feature-name
   ```

4. **Open a Pull Request**:
   - Create PR from your feature branch → `dev`
   - Use GitHub CLI: `gh pr create --base dev --title "Your PR title"`
   - @larnsce will review and approve the PR

5. **Share PR link** in Element Chat communication channel for team visibility

6. **After approval**: @larnsce merges the PR into `dev`

7. **Deployment**: @larnsce periodically merges `dev` → `main` for production releases

## Development Environment

### R Package Management with renv

This project uses `renv` for reproducible R package management.

#### First-time Setup

```r
# Install renv if needed
install.packages("renv")

# Restore project dependencies
renv::restore()
```

#### Adding New Packages

When you need a new R package:

```r
# Install the package
install.packages("package_name")

# Update the lockfile
renv::snapshot()

# Commit the updated renv.lock file
git add renv.lock
git commit -m "Add package_name dependency"
```

#### Updating Packages

```r
# Update specific package
renv::update("package_name")

# Update all packages
renv::update()

# Commit changes
git add renv.lock
git commit -m "Update R package dependencies"
```

#### Troubleshooting renv

If you encounter package issues:

```r
# Check project status
renv::status()

# Restore from lockfile
renv::restore()

# Clean and rebuild
renv::clean()
renv::restore()
```
## Communication

- **Element Chat**: Share PR links and coordinate work
- **GitHub Issues**: Track bugs and feature requests
- **PR Comments**: Technical discussion about specific changes

## Questions?

If you have questions about contributing, reach out to @larnsce or ask in the Element Chat channel.
