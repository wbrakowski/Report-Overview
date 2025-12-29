# Changelog

All notable changes to the "Report Overview" extension will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

---

## [1.0.0.0] - 2025-12-29

### Added
- **Report Overview Dashboard**: Centralized page for managing all custom reports (ID range 50000-100000)
- **Favorites System**: Mark and filter reports by favorites with visual highlighting
- **Report Categories**: Organize reports into 9 categories (Sales, Purchase, Finance, Inventory, Manufacturing, Service, HR, Administration, Other)
- **Quick Run Report**: Execute any report directly from the dashboard without navigation
- **Inline Action Buttons**: 
  - ▶ Run Report buttons next to Report ID fields
  - 🔗 Page Link buttons next to List/Card Page No. fields
- **Smart Filtering**: 
  - Filter by favorites (Show Favorites Only toggle)
  - Filter by category (dropdown selection)
  - Show All Reports action to clear all filters
- **Report Overview Subpage**: Editable list of custom reports with metadata management
- **Report Selections Subpage**: Pre-filtered standard BC report selections for Sales & Purchase documents
- **Auto-Discovery**: Automatically populates Report Test table with all custom reports on page open
- **Permission Set**: Complete permission set (50100) for easy deployment and user access management

### Technical Implementation
- NoImplicitWith feature enabled for modern AL coding standards
- Reduced cyclomatic complexity (<8) in all procedures
- FlowFields for dynamic report caption lookup
- Procedure-based filtering architecture for efficient data handling
- Inline button pattern with conditional styling and visual feedback
- Clean compilation with zero warnings or errors

### Documentation
- Comprehensive README with installation guide, usage instructions, and technical details
- Code examples for extending report categories
- Customization guides for object range and configuration

---

**Note**: For detailed feature descriptions and usage instructions, see [README.md](README.md)
