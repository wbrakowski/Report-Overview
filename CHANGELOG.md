# Changelog

All notable changes to the "Report Overview" extension will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

---

## [Unreleased]

### Changed
- Requires Business Central 29 (platform and application 29.0.0.0, runtime 18.0)
- All objects are in the namespace `ReportOverview`
- The extension moved into the folder `app/`; open `Report-Overview.code-workspace` to work with the extension and its tests
- Quick Run Report only accepts the ID of an existing report. Before, the ID of another object type was accepted and failed when the report was run
- The run button uses stored test parameters and then shows the preview without request page

### Added
- **Test status** per report (Passed, Failed) with date and user of the last test, and the filter **Show Untested Only**
- **Test parameters**: store the request page values and filters of a report with the inline ✎ button, remove them with **Clear Test Parameters**
- **Download**: inline ⬇ button that saves the report output as PDF, Word or Excel file
- **Report settings**: inline ⚙ button that opens the saved request page settings of the report
- **Layout** column with the layout currently used; the value opens the layouts of the report
- **Remove Missing Reports**: entries whose report no longer exists are greyed out and can be removed
- **Favorite Reports** part on the Business Manager and the Administrator role center
- Report selections part: purchase receipts and return shipments, service quotes, orders, invoices, credit memos and shipments, reminders and finance charge memos
- Automated tests as a separate app in `test/` (98 tests for the business logic, the pages and the permission set)
- New screenshots in the README

### Fixed
- Favorite reports are highlighted: the style is on `Report ID` and `Report Caption`. Before it was on the `Is Favorite` checkbox, where the client does not show it

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
