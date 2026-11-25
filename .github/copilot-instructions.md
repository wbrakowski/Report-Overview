# Report Overview - AI Agent Instructions

## Working Rules (always)
1. **Branch first.** Before changing any file, create a new branch from the up-to-date `master` (`git switch master`, `git pull`, `git switch -c <name>`). Never change files on `master`. Names: `feature/<topic>`, `fix/<topic>`, `docs/<topic>`, or the BC version for upgrades (`bc29`).
2. Commit, push, pull request and merge only when the user asks for it.
3. After every change both apps must build without errors, warnings or info messages, and all tests must pass in the local container (see "Build, Publish, Test").
4. **Always test automatically.** Every new or changed behavior gets automated tests in `test/` for everything that can be automated: logic, pages through `TestPage`, permissions. Run the whole suite in the container yourself, never hand untested work to the user. Never weaken a test to make it pass: first find out whether the test or the app is wrong.
5. What cannot be automated (see "Not automatable") is listed for the user at the end of the task as concrete steps for his manual test.
6. Keep `README.md` (features, object table) and `CHANGELOG.md` (section `[Unreleased]`, released versions below) in sync with the code. Never document planned features.

## Project
Business Central extension that lists custom reports (object IDs 50000..100000) on a dashboard with favorites, categories and inline buttons to run a report or open its list/card page. Target: Cloud, platform and application 29.0, runtime 18.0, feature `NoImplicitWith`.

## Repo Layout
| Path | Content |
| --- | --- |
| `app/` | Main app `Report-Overview`, IDs 50100..50149, namespace `ReportOverview` |
| `test/` | Test app `Report-Overview Tests`, IDs 50150..50199, namespace `ReportOverview.Test`, depends on the main app and the Microsoft apps `Library Assert` and `Permissions Mock` |
| `Report-Overview.code-workspace` | Multi-root workspace for both apps. Always open this file, not the repo root |
| `resources/` | Screenshots used by `README.md` |

`app/` and `test/` must stay siblings. A test folder nested inside the app folder gets compiled into the main app.
With the repo root open, object-ID tools resolved a file in `test/` to the main app (range 50100..50149) or to no project at all. Open the workspace file and check the returned app name and range before using an ID.

## Objects (app)
| Object | Purpose |
| --- | --- |
| Table 50100 `Report Test` | One row per custom report: `Is Favorite`, `Category`, `List Page No.`, `Card Page No.`, `Test Information`. FlowField `Report Caption` (from `AllObjWithCaption`). The FlowFilters `Is Favorite Filter` and `Category Filter` are currently unused |
| Enum 50100 `Report Category` | Extensible, value 0 is the blank value |
| Codeunit 50100 `Report Overview Mgt.` | All business logic: `FillTestTable`, `GetListPageNo`, `GetCardPageNo`, `GetCustomReportCaption`, `OpenReportSettings` (not called by any page yet) |
| Page 50100 `Report Overview` | Dashboard, Card page **without** SourceTable: filters, Quick Run Report, both parts |
| Page 50102 `Report Overview Subpage` | ListPart on `Report Test` with inline buttons and the favorites actions |
| Page 50101 `Report Selections Subpage` | ListPart on standard `Report Selections`, limited to sales and purchase document usages |
| PermissionSet 50100 `Report Overview` | Covers every object of the app |

## Patterns to Keep
**Dashboard filters.** The dashboard has no record. A filter field calls the local `ApplyFilters()`, which calls `CurrPage.ReportOverviewSubpage.Page.SetFilters(ShowFavoritesOnly, CategoryFilter)`. The subpage applies `Rec.SetRange()` and `CurrPage.Update(false)`. Add new filters as a parameter of `SetFilters`.

**Inline buttons instead of row actions.** Running a report or opening a page for a line is an inline field, not a page action:
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
Page actions exist only for commands that are not tied to one inline target: filter shortcuts and links to setup pages on the dashboard, `Add to Favorites` and `Remove from Favorites` on the subpage.

**Favorite highlight.** A favorite line has `Style = Attention` with `StyleExpr = Rec."Is Favorite"` on `Report ID` and `Report Caption`. The client does not render a style on a Boolean field (checkbox), so never put it on `Is Favorite`.

**Report discovery.** `FillTestTable()` runs when the dashboard opens and inserts a row for every report in 50000..100000 that has none. It never changes or deletes existing rows. The range is set in that procedure.

**Document pages for report selections.** `GetListPageNo` and `GetCardPageNo` delegate to one `case` procedure per area (`GetPurchaseListPageNo`, `GetSalesListPageNo`, ...). A new usage goes into the matching procedure and into `SourceTableView` of page 50101, a new area gets its own procedure.

## Code Conventions
- Every file starts with `namespace ReportOverview;` (tests: `namespace ReportOverview.Test;`), followed by the `using` lines in alphabetical order. With a namespace, every referenced standard object needs its `using` (for example `System.Reflection` for `AllObjWithCaption`, `Microsoft.Foundation.Reporting` for `Report Selections`).
- Business logic in the codeunit, pages only call it.
- Guard clauses and early `exit` instead of nesting. Cyclomatic complexity below 8, cognitive complexity below 15.
- Captions, ToolTips and labels in English only. This repo has no translation comments or translation files.
- ToolTip and Caption on the table field, not repeated on the page field. Page fields based on a variable or expression need both. ToolTips start with "Specifies", end with a dot, at most 200 characters.
- FlowFields are `Editable = false`. `DataClassification` only at table level. Tables have `DropDown` and `Brick` field groups.
- Explicit `RunTrigger` on `Insert`, `Modify`, `Delete`, `DeleteAll`. Check the result of `Get()`. Built-in methods with parentheses (`CompanyName()`, `UserId()`). `IsEmpty()` instead of `Count() = 0`.
- Enums instead of options, `CopyStr` for shorter targets, labels for `Error` and `Message`, `Confirm Management` instead of `Confirm()`.
- Every new object goes into the permission set of its app. Entry order: table, tabledata, codeunit, page, query, report, xmlport.
- Never guess names of standard objects, fields or enum values: look them up in the symbols or the BC source.
- Analyzers in use: CodeCop, UICop and the ALCops analyzers (ApplicationCop, FormattingCop, LinterCop, TestAutomationCop). A warning that cannot be fixed gets a one-line comment with the reason.

## Build, Publish, Test
- Local test environment: Docker container `bc29` (BC 29.0 DE, `https://bc29`, instance `BC`, tenant `default`, user and password authentication). Start it with `docker start bc29` and wait until it is healthy. The launch configuration is `Local container bc29` in `app/.vscode/launch.json` and `test/.vscode/launch.json` (both are local files and not in Git).
- The test app needs `Library Assert` and `Permissions Mock` installed. `Permissions Mock` is published in the container but not installed by default: `Sync-NAVApp` and `Install-NAVApp -ServerInstance BC -Tenant default -Name 'Permissions Mock'` inside the container.
- Order: download symbols for both apps, build `app`, build `test`, publish `app`, publish `test`, run the tests.
- In VS Code: download symbols and build both projects, publish each project, then run the tests in the Test Explorer.
- From PowerShell: `Publish-BcContainerApp -containerName bc29 -appFile <file> -useDevEndpoint -credential <credential> -syncMode Add -skipVerification`, then `Run-TestsInBcContainer -containerName bc29 -credential <credential> -extensionId 10ed9cc9-71f9-4f51-ad65-41d62c632576 -detailed -usePublicWebBaseUrl -returnTrueIfAllPassed`.
- Never write credentials into a file of this repo.

## Tests (`test/`)
| Object | Content |
| --- | --- |
| Codeunit 50150 `Report Overview Mgt. Test` | Page mapping per usage, report caption, `FillTestTable`, FlowField `Report Caption`, numbers of the `Report Category` values, filters of `OpenReportSettings` |
| Codeunit 50151 `Report Overview Page Test` | Dashboard through `TestPage`: discovery on open, filters and filter actions, Quick Run Report, inline buttons, editing and adding lines, favorites actions, report selections part with all ten usages, navigation actions |
| Codeunit 50153 `Report Overview Perm. Test` | Permission set `Report Overview`: the dashboard works with it and cannot be opened without it |
| Report 50150 `Report Overview Test Report` | Custom report inside the scanned range. It has no request page and counts its runs |
| Report 50151 `Test Report With Request Page` | Same with a request page |
| Codeunit 50152 `Test Report Run Counter` | Single instance counter that the test reports increment |
| PermissionSet 50150 `Report Overview Test` | Covers the test objects |

Rules for tests:
- `Subtype = Test`, `TestPermissions = Disabled`, comments `// [GIVEN]`, `// [WHEN]`, `// [THEN]`, assertions with `Library Assert`. After `asserterror` always `Assert.ExpectedError('<text>')`.
- The test runner rolls data back per test **codeunit**, not per test. Every test starts with `Initialize()`, which removes the rows and resets the counters earlier tests left behind. `Initialize()` deletes all rows of `Report Test`: run the tests only with the default runner (isolation per codeunit) and never in an environment with real data.
- The environment can contain other custom reports. Assert on specific rows (`FindReportLine`), never on totals. Rows 50197 to 50199 are entries without a report object, used for filter tests.
- Never assert on translatable captions: the language of the test session depends on the environment (the container is a DE localization). The caption of the test report is locked for that reason.
- Running a report without request page: use `Report Overview Test Report` and check `TestReportRunCounter.GetRunCount()`. A `ReportHandler` is not called for a report without request page.
- Running a report with request page: use `Test Report With Request Page` with a `[RequestPageHandler]`. The test needs `[TransactionModel(TransactionModel::AutoCommit)]` and a call of `CommitPageTriggers()` right before the drilldown. Without the commit `Report.RunModal` fails with "An error occurred and the transaction is stopped", because the test has an open write transaction. The runner still rolls the committed data back at the end of the codeunit (checked in `bc29`). `Commit()` is allowed only through `CommitPageTriggers()`.
- Opening a page from an inline button or a navigation action: `[PageHandler]` with a `TestPage` of the opened page and a counter. Use a small standard page (`Payment Terms`) where the page number is test data.
- Actions of a ListPart are invoked through the part of the dashboard (`ReportOverview.ReportOverviewSubpage.AddToFavorites.Invoke()`), not on the ListPart opened on its own (TA0002).
- A `TestPage` returns option filters as ordinal value (`3` for object type Report), other filters as text. Read enum fields with `AsInteger()`.
- A value rejected by a `TableRelation`: `asserterror` on `SetValue`, then `Assert.ExpectedErrorCode('TestValidation')`. Use `GetUnusedObjectId()`: the Quick Run field only rejects an ID that no object of any type uses, the table fields `List Page No.` and `Card Page No.` also reject the ID of another object type.
- Permissions: `StartWithBasicPermissions()` sets `D365 BASIC` through `Permissions Mock`, `Assign` adds a permission set. Stop the mock before the assertions, otherwise a failed assertion leaves it running for the following tests. A missing table permission has the error code `DB:ClientReadDenied`.

## Not automatable
List these for the user as manual test steps whenever a change touches them:
- Look: `Style` and `StyleExpr` (favorite line, colored inline buttons), column widths, symbols, promoted actions and their categories.
- Finding the dashboard through the search (`UsageCategory`).
- Real report output: preview, print and download of a report with layout.
- Deleting a line (a `TestPage` cannot delete), lookups of the ID fields, the filter pane of the parts.
- Refresh behavior in the client (`UpdatePropagation`, enabled state of the favorites actions after a click).
- Upgrade of an environment that already has data of an older version.
