# Report Overview - AI Agent Instructions

## Project Overview
Business Central AL extension (ID range 50100-50149) for managing custom reports with favorites, categorization, and inline navigation. Target: BC Cloud, Platform 27.0, Runtime 16.0.

## Architecture & Core Components

### Data Model (Table 50100 "Report Test")
- **Primary Key**: Report ID (Integer)
- **FlowFields**: Report Caption (dynamic lookup from AllObjWithCaption)
- **FlowFilters**: Is Favorite Filter, Category Filter (for main page filtering)
- **User Data**: Is Favorite (Boolean), Category (Enum), List/Card Page No., Test Information
- **Auto-Population**: `FillTestTable()` scans AllObjWithCaption for reports 50000-100000 on page open

### UI Architecture - Dashboard Pattern
**Main Page (50100)**: Card page WITHOUT SourceTable (pure dashboard, no record context)
- Filter controls trigger `ApplyFilters()` → calls `CurrPage.SubpageName.Page.SetFilters(params)`
- Two ListPart subpages embedded with `UpdatePropagation = Both`

**Subpage Pattern**: Public `SetFilters()` procedure receives parameters, applies `Rec.SetRange()` locally
```al
procedure SetFilters(ShowFavoritesOnly: Boolean; CategoryFilter: Enum "Report Category")
begin
    Rec.Reset();
    if ShowFavoritesOnly then
        Rec.SetRange("Is Favorite", true);
    if CategoryFilter <> CategoryFilter::" " then
        Rec.SetRange(Category, CategoryFilter);
    CurrPage.Update(false);
end;
```

### Inline Button Pattern (Critical UX Design)
**DO NOT** use Page Actions for navigation. Use inline button fields:
- Small-width fields (Width=1) with symbols: ▶ (Run), 🔗 (Link)
- Non-editable with DrillDown triggers
- Conditional styling: `StyleExpr = FieldValue <> 0` for visual feedback
- Always include Caption + ToolTip (e.g., 'Run Report', 'Open List Page') to satisfy AA0218/AA0225

Example:
```al
field(RunReportLink; '▶')
{
    Caption = 'Run Report';
    ToolTip = 'Specifies the action to run the selected report.';
    Editable = false;
    Width = 1;
    Style = Favorable;
    StyleExpr = Rec."Report ID" <> 0;
    trigger OnDrillDown()
    begin
        if Rec."Report ID" <> 0 then
            Report.RunModal(Rec."Report ID");
    end;
}
```

### Report Selections Integration
Page 50101 reads standard BC "Report Selections" table, calculates List/Card Page No. via `ReportOverviewMgt.GetListPageNo/GetCardPageNo()` in `OnAfterGetRecord()`. These procedures split Purchase/Sales logic into sub-procedures to keep cyclomatic complexity <8.

## Code Quality Standards

### NoImplicitWith Enabled
Always use explicit `Rec.` prefix or `with` declarations.

### ToolTips Required
- All fields/actions MUST have ToolTips starting with "Specifies"
- Empty captions on inline buttons need Caption + ToolTip (not `Locked = true`)

### Cyclomatic Complexity <8
Split large case statements into separate procedures (see `GetPurchaseListPageNo/GetSalesListPageNo`).

### Permissions
- Codeunit 50100: `Permissions = tabledata "Report Test" = ri;`
- PermissionSet 50100 grants RIMD to tabledata, X to codeunits/pages

## Extension Points

### Report Category Enum (50100)
Marked `Extensible = true`. Add custom categories via enumextension:
```al
enumextension 50100 "My Categories" extends "Report Category"
{
    value(50100; "Custom Category") { Caption = 'Custom Category'; }
}
```

### Object Range Customization
Modify `FillTestTable()` line 21: `SetRange("Object ID", YourStartID, YourEndID);`

## Development Workflow

### No Tests/Builds in Project
Pure AL extension - compile via BC AL Language extension (Ctrl+Shift+B). No custom build scripts.

### Key Files to Review
- `src/page/ReportOverview.Page.al`: Filter architecture, inline button implementation
- `src/codeunit/ReportOverviewMgt.Codeunit.al`: Business logic, cyclomatic complexity patterns
- `src/table/ReportTest.Table.al`: Data model, FlowFields/FlowFilters usage
- `CHANGELOG.md`: Version history (do NOT add planned features)

## Common Tasks

### Adding New Features
1. Update `ReportTest` table if new fields needed
2. Add to appropriate subpage (50102 for custom reports, 50101 for BC selections)
3. Use inline buttons for actions - NEVER add to Page Actions area
4. Update PermissionSet 50100 if new objects added

### Filter Implementation
Always use procedure-based pattern:
1. Main page field OnValidate calls local `ApplyFilters()`
2. `ApplyFilters()` calls `CurrPage.SubpageName.Page.SetFilters(params)`
3. Subpage public procedure applies `Rec.SetRange()` and `CurrPage.Update(false)`

### Avoiding Warnings
- LC0041: Empty captions need Caption + ToolTip (inline buttons)
- AA0218/AA0225: All fields need ToolTip and Caption
- LC0077: Use `CompanyName()` and `UserId()` with parentheses

### Critical LC Rules to Avoid
**FlowFields & Properties**
- LC0001: FlowFields must be Editable = false
- LC0019: Don't duplicate DataClassification on fields if set on table
- LC0042: Only use AutoCalcFields for FlowFields or Blob fields
- LC0064: All table fields must have ToolTip property
- LC0066: Don't duplicate ToolTip on both page and table fields
- LC0074: Set FlowFilter fields using filtering methods, not direct assignment

**Code Syntax & Best Practices**
- LC0004: Set DrillDownPageId and LookupPageId on tables used in list pages
- LC0005: Variable/method casing must match definition
- LC0010: Keep cyclomatic complexity < 8, maintainability > 20
- LC0015: All objects must be covered by permission sets
- LC0021: Use ConfirmManagement.GetResponseOrDefault() instead of Confirm()
- LC0023: Always provide DropDown and Brick fieldgroups on tables
- LC0024: Procedure declarations must not end with semicolon
- LC0031: Use ReadIsolation instead of deprecated LockTable()
- LC0035: Explicitly set AllowInCustomizations for fields omitted on pages
- LC0040: Explicitly set RunTrigger parameter on Insert/Modify/Delete
- LC0051: Don't assign text to target with smaller size (use CopyStr)
- LC0077: Always call methods with parentheses, even when no parameters
- LC0084: Check Get() return values: `if not Rec.Get(...) then Error(...)`
- LC0090: Keep Cognitive Complexity below threshold (typically 15)

**Data Operations**
- LC0008: Don't use filter operators in SetRange (use SetFilter instead)
- LC0032: Clear(All) doesn't affect single instance codeunit globals
- LC0044: Tables coupled with TransferFields must have matching fields
- LC0050: SetFilter with unsupported operator in filter expression
- LC0068: Missing permission to access tabledata (add to Permissions property)
- LC0075: Correct number/type of arguments in .Get() method
- LC0078: Temporary records should not trigger table triggers
- LC0081: Use Rec.IsEmpty() instead of Rec.Count() = 0

**Labels & Text**
- LC0016: All objects/fields need Caption property
- LC0026: ToolTip must end with a dot
- LC0036: ToolTip should start with "Specifies"
- LC0037: Don't use line breaks in ToolTip
- LC0038: ToolTip should not exceed 200 characters
- LC0041: Empty Captions should be Locked
- LC0046: Labels with suffix Tok must be locked
- LC0047: Locked labels must have suffix Tok

**Modern AL Features**
- LC0043: Use SecretText for credentials and sensitive values
- LC0083: Use new Date/Time/DateTime methods for extracting parts
- LC0086: Use PageStyle datatype instead of string literals
- LC0087: Use IsNullGuid() to check for empty GUID values
- LC0088: Use enum instead of Option types when applicable

**Handling Warnings**
- Use get_errors tool to check for warnings after making changes
- If a warning cannot be resolved immediately, add a comment explaining why
- Example of documented exception:
  ```al
  // LC0001: Empty procedure kept for future implementation as per design spec XYZ-123
  procedure PlaceholderForFutureFeature()
  begin
  end;
  ```

### Code Structure and Readability
- Use early exits (exit statements) whenever possible to avoid deep nesting
- Guard clauses should be at the beginning of procedures to handle edge cases
- Prefer flat code structure over deeply nested if-then-else blocks
- Example:
  ```al
  // BAD - Nested conditions
  procedure ProcessSalesLine(var SalesLine: Record "Sales Line")
  begin
      if SalesLine.Type <> SalesLine.Type::" " then begin
          if SalesLine.Quantity > 0 then begin
              if SalesLine."Location Code" <> '' then begin
                  // Main logic here
                  UpdateInventory(SalesLine);
              end;
          end;
      end;
  end;

  // GOOD - Early exits with guard clauses
  procedure ProcessSalesLine(var SalesLine: Record "Sales Line")
  begin
      if SalesLine.Type = SalesLine.Type::" " then
          exit;
      
      if SalesLine.Quantity <= 0 then
          exit;
      
      if SalesLine."Location Code" = '' then
          exit;
      
      // Main logic here - no nesting needed
      UpdateInventory(SalesLine);
  end;
  ```

## Project Conventions

- **No example reports**: Project removed sample reports, focuses on management tool only
- **No SourceTable on dashboard**: Main page is pure dashboard without record context
- **Favorites over search**: User prefers favorites/categories over full-text search
- **Clean documentation**: README for features, CHANGELOG for releases, no planned features mentioned
- **Screenshot placeholders**: README has 7 image placeholders in `resources/` folder
