# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

This is the **website** for the ds4owd-002 course iteration - the second offering of "Data Science for OpenWashData". This Quarto-based educational website contains 9 progressive modules teaching data science using R with a focus on WASH (Water, Sanitation, Hygiene) data analysis.

## Common Development Commands

### Quarto Website Development
```bash
# Render entire website
quarto render

# Preview website with live reload  
quarto preview

# Render specific document
quarto render filename.qmd

# Render and serve (alternative preview)
quarto preview --serve
```

### Node.js Dependencies
```bash
# Install dependencies (for Puppeteer PDF generation)
npm install

# Update dependencies
npm update
```

## Architecture and Key Patterns

### Website Structure
- **Quarto project** with configuration in `_quarto.yml`
- **Course variables** centralized in `_variables.yml` for easy updates
- **Modular content** organized by progressive modules (md-01 through md-09)
- **Assignment integration** with individual assignment pages per module
- **Responsive design** using custom `theme.scss` and `styles.css`

### Content Organization
- **`modules/`** - Core learning modules with progressive skill building
- **`assignments/`** - Structured by module (`md-XX/`) with individual assignment files
- **`slides/`** - Lecture presentations with reveal.js format
- **`guide/`** - Setup and configuration instructions
- **`project/`** - Capstone project documentation
- **`img/`** - Course assets and diagrams

### Navigation System
- **Sidebar navigation** configured in `_quarto.yml` with collapsible sections
- **Progressive disclosure** - modules unlock sequentially
- **Assignment tracking** integrated into module structure
- **GitHub integration** links to course organization

## Key Configuration Files

### `_quarto.yml`
- Website metadata and navigation structure
- Theme configuration (Litera + custom SCSS)
- Output directory settings (`docs/` for GitHub Pages)
- Analytics integration (Plausible)

### `_variables.yml`
- Course iteration details (ds4owd-002)
- Module dates and titles (2025-09-11 to 2025-12-04)
- Platform URLs (Posit Cloud, GitHub organization)
- Instructor information

### Content Standards
- **Module naming**: `md-XX-` prefix for sequential organization
- **Assignment naming**: `am-XX-N-topic` for module assignments
- **Date formatting**: ISO format (YYYY-MM-DD) in variables
- **Quarto execution**: Freeze mode for reproducible builds

## Deployment Architecture

### GitHub Pages Integration
- **Output directory**: `docs/` (configured in `_quarto.yml`)
- **Freeze execution**: Cached outputs in `_freeze/` directory
- **Site URL**: `https://ds4owd-002.github.io/website/`
- **Repository**: Links to ds4owd-002 GitHub organization

### Course Infrastructure
- **Posit Cloud workspace**: Centralized R environment for students
- **GitHub Classroom**: Assignment distribution and collection
- **Matrix chat**: Course communication platform
- **Plausible analytics**: Privacy-focused website tracking

## File Naming Conventions

### Content Files
- `md-XX.qmd` - Module overview pages
- `am-XX-N-topic.qmd` - Assignment files (N = assignment number)
- `lec-XX-topic.qmd` - Lecture slides
- Complete solutions use `-complete` suffix

### Data Organization
- Course schedule: `tbl-01-ds4owd-002-course-schedule.csv`
- Learning objectives: `tbl-02-ds4owd-002-learning-objectives.csv`
- Project elements: `tbl-03-ds4owd-002-capstone-project-elements`

## Development Workflow

When working with this website:

1. **Content updates**: Modify `.qmd` files and render to test
2. **Variable changes**: Update `_variables.yml` for course-wide changes
3. **Navigation changes**: Modify `_quarto.yml` sidebar structure
4. **Styling**: Edit `theme.scss` or `styles.css` for visual changes
5. **Testing**: Use `quarto preview` for live development
6. **Deployment**: Render creates `docs/` for GitHub Pages

## Course Timeline (ds4owd-002)

The course runs from September 2025 to December 2025:
- Module 01-09: Weekly sessions (Sep 11 - Nov 6)
- Module 10: Graduation event (Dec 4)
- Platform: Posit Cloud workspace with GitHub integration

When modifying content, ensure consistency with the established module progression and maintain the educational scaffolding across the 9-week curriculum.


## Project Management with GitHub CLI

- Commit to `dev`, create branches from `dev` for issues
- List issues: `gh issue list`
- View issue details: `gh issue view 80` (e.g., for issue #80 "Rename geographies parameter")
- Create branch for issue: `gh issue develop 80`
- Checkout branch: `git checkout 80-rename-geographies-parameter-to-entities`
- Create pull request: `gh pr create --title "Rename geographies parameter to entities" --body "Implements #80"`
- List pull requests: `gh pr list`
- View pull request: `gh pr view PR_NUMBER`

## Code Style Guidelines

- Use 2 spaces for indentation (no tabs)
- Maximum 80 characters per line
- Use tidyverse style for R code (`dplyr`, `tidyr`, `purrr`)
- Use snake_case for function and variable names

## Instructional Design Patterns

### Visual Enhancement and Accessibility
- **Highlighting**: Use `[text]{.highlight-yellow}` or `[text]{.highlight-peach}` to draw attention to specific UI elements, buttons, or important text
- **Screenshots**: Include descriptive images with `{width=100%}` for full-width display
- **Icons**: Use Font Awesome icons (e.g., `{{< fa envelope-circle-check >}}`) for visual cues

### Step-by-Step Instructions Structure
1. **Clear numbering**: Use numbered lists for sequential steps
2. **Action-oriented language**: Start with verbs (Click, Open, Navigate, Enter, Select)
3. **Visual references**: Include what learners will see in brackets with highlighting
4. **Contextual information**: Provide the "why" when needed, but keep it brief
5. **Progressive disclosure**: Reduce detail level as course progresses (explicitly noted in module 2+)

### Common Instruction Patterns
- **Navigation**: "Open [URL] in your browser" → "Navigate to..." → "Find the repository..."
- **UI interactions**: "Click on the [Button Name]{.highlight-yellow} button"
- **Form fields**: "In the [Field Name]{.highlight-yellow} field, enter..."
- **Verification**: "You can verify... by looking at..."
- **Success indicators**: "If you see..., then you have successfully..."

### Support Elements
- **Callout boxes** for different purposes:
  - `{.callout-tip}`: Optional information or helpful hints
  - `{.callout-important}`: Critical information learners must know
  - `{.callout-warning}`: Common pitfalls or issues to avoid
  - `{.callout-note}`: Additional context or explanations
- **Troubleshooting**: Include "If you cannot..." sections with solutions
- **Support channels**: Provide email links with pre-filled subjects for specific help

### GitHub Workflow Instructions
- **Repository references**: Always use `USERNAME` placeholder with clear substitution instructions
- **Authentication steps**: Detailed PAT creation and usage with security warnings
- **Commit process**: Explicit staging → commit message → push sequence
- **Issue creation**: Structured format with instructor tagging (@seawaR @massarin @larnsce)

### Progressive Scaffolding
- **Module 1**: Extensive screenshots, detailed explanations, complete step-by-step guidance
- **Module 2+**: Reduced screenshots, assumes familiarity with basic operations, includes notes about reduced detail
- **Cross-references**: Link back to earlier modules for detailed instructions when needed

### Security and Best Practices
- **PAT storage**: Explicit warnings against Word documents, recommend text files or password managers
- **Credential handling**: Clear distinction between GitHub password and PAT
- **Error prevention**: Proactive warnings about common issues (spaces in PAT, wrong workspace)
