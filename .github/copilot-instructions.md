# Report Overview - AI Agent Instructions

## Working Rules (always)
1. **Branch first.** Before changing any file, create a new branch from the up-to-date `master` (`git switch master`, `git pull`, `git switch -c <name>`). Never change files on `master`. Names: `feature/<topic>`, `fix/<topic>`, `docs/<topic>`, or the BC version for upgrades (`bc29`).
2. **Finish with Git after the release.** Do not commit before the user has released the work ("Test OK" or an explicit go-ahead). After the release finish without asking again: commit, push the branch, create a pull request to `master`, merge it with a merge commit, delete the branch on GitHub and locally, then `git switch master` and `git pull`. Unrelated changes (for example a version upgrade and new features) get their own branch and pull request each. Never push to `master` directly and never force push.
3. After every change both apps must build without errors, warnings or info messages, and all tests must pass in the local container (see "Build, Publish, Test").
4. **Always test automatically.** Every new or changed behavior gets automated tests in `test/` for everything that can be automated: logic, pages through `TestPage`, permissions. Run the whole suite in the container yourself, never hand untested work to the user. Never weaken a test to make it pass: first find out whether the test or the app is wrong.
5. What cannot be automated (see "Not automatable") is listed for the user at the end of the task as concrete steps for his manual test.
6. Keep `README.md` (features, object table) and `CHANGELOG.md` (section `[Unreleased]`, released versions below) in sync with the code. Never document planned features.

## Project
Business Central extension that lists custom reports (object IDs 50000..100000) on a dashboard with favorites, categories, a test status per report and inline buttons to run or download a report, store its test parameters and open its settings, layouts and list/card page. Target: Cloud, platform and application 29.0, runtime 18.0, feature `NoImplicitWith`.

## Repo Layout
| Path | Content |
| --- | --- |
| `app/` | Main app `Report-Overview`, IDs 50100..50149, namespace `ReportOverview` |
| `test/` | Test app `Report-Overview Tests`, IDs 50150..50199, namespace `ReportOverview.Test`, depends on the main app and the Microsoft apps `Library Assert` and `Permissions Mock` |
| `Report-Overview.code-workspace` | Multi-root workspace for both apps. Always open this file, not the repo root |
| `resources/` | Screenshots used by `README.md` (see "Screenshots") |

`app/` and `test/` must stay siblings. A test folder nested inside the app folder gets compiled into the main app.
With the repo root open, object-ID tools resolved a file in `test/` to the main app (range 50100..50149) or to no project at all. Open the workspace file and check the returned app name and range before using an ID.

## Objects (app)
| Object | Purpose |
| --- | --- |
| Table 50100 `Report Test` | One row per custom report: `Is Favorite`, `Category`, `List Page No.`, `Card Page No.`, `Test Information`, `Test Status` with `Last Tested At` and `Last Tested By` (set in `OnValidate`), Blob `Test Parameters` with `Has Test Parameters` (use `SetTestParameters` and `GetTestParameters`). FlowFields `Report Caption` and `Report Exists` (from `AllObjWithCaption`). The FlowFilters `Is Favorite Filter` and `Category Filter` are currently unused |
| Enum 50100 `Report Category` | Extensible, value 0 is the blank value |
| Enum 50101 `Report Test Status` | Extensible: blank (not tested), `Passed`, `Failed` |
| Codeunit 50100 `Report Overview Mgt.` | All business logic: `FillTestTable`, `RunReport`, `SetTestParameters`, `ClearTestParameters`, `DownloadReport`, `SaveReportToBlob`, `OpenReportSettings`, `OpenReportLayouts`, `GetCurrentLayoutName`, `RemoveMissingReports`, `DeleteMissingReports`, `CheckReportExists`, `GetLineStyle`, `GetTestStatusStyle`, `GetListPageNo`, `GetCardPageNo`, `GetCustomReportCaption` |
| Page 50100 `Report Overview` | Dashboard, Card page **without** SourceTable: filters, Quick Run Report, both parts |
| Page 50102 `Report Overview Subpage` | ListPart on `Report Test` with the inline buttons, the favorites actions and the group `Test` (`Clear Test Parameters`, `Remove Missing Reports`) |
| Page 50101 `Report Selections Subpage` | ListPart on standard `Report Selections`, limited to the usages that `GetListPageNo` maps |
| Page 50103 `Favorite Reports` | Read-only ListPart with the favorites and a run button, for role centers |
| PageExtension 50100 and 50101 | Add `Favorite Reports` with `addlast(rolecenter)` to `Business Manager Role Center` and `Administrator Role Center` |
| PermissionSet 50100 `Report Overview` | Covers every object of the app |

## Patterns to Keep
**Dashboard filters.** The dashboard has no record. A filter field calls the local `ApplyFilters()`, which calls `CurrPage.ReportOverviewSubpage.Page.SetFilters(ShowFavoritesOnly, CategoryFilter, ShowUntestedOnly)`. The subpage applies `Rec.SetRange()` and `CurrPage.Update(false)`. Add new filters as a parameter of `SetFilters`, and reset them in the action `Show All Reports`.

**Inline buttons instead of row actions.** A command for one line is an inline field that calls the codeunit, not a page action:
```al
field(RunReportLink; '▶')
{
    Caption = 'Run Report';
    ToolTip = 'Specifies the action to run the selected report. With stored test parameters the report runs without request page.';
    Editable = false;
    Width = 1;
    Style = Favorable;
    StyleExpr = Rec."Report ID" <> 0;

    trigger OnDrillDown()
    begin
        ReportOverviewMgt.RunReport(Rec);
    end;
}
```
The buttons of a line: `▶` run, `✎` test parameters (highlighted when stored), `⬇` download, `⚙` report settings, `🔗` list and card page. Use symbols that the font draws as text: an emoji in color ignores `Style`. The column `Layout` is the current layout name with an `OnDrillDown` that opens the layouts.
Page actions exist only for commands that are not tied to one inline target or that are rare: filter shortcuts and links to setup pages on the dashboard, `Add to Favorites`, `Remove from Favorites`, `Clear Test Parameters` and `Remove Missing Reports` on the subpage.

**Line styles.** `Report ID` and `Report Caption` use `StyleExpr = LineStyle`, `Test Status` uses `TestStatusStyle`. Both are filled in `UpdateLineValues()` from `GetLineStyle` (entry without report: `Subordinate`, favorite: `Attention`) and `GetTestStatusStyle` (`Favorable`, `Unfavorable`). Return styles with `Format(PageStyle::...)`. The client does not render a style on a Boolean field (checkbox), so never put it on `Is Favorite`.

**Running with test parameters.** `SetTestParameters` stores the XML of `Report.RunRequestPage` in the Blob. `RunReport` uses `Report.Execute` (preview without request page) when test parameters exist, else `Report.RunModal`. `DownloadReport` asks for the format with `StrMenu`, uses the stored test parameters or shows the request page once, and saves with `Report.SaveAs`. Processing-only reports have no download, reports without request page no test parameters (`Report Metadata`).

**Current layout.** `GetCurrentLayoutName` follows the standard page `Report Layouts`: `Tenant Report Layout Selection` of the company, else `DefaultLayoutName` of `Report Metadata`.

**Role center.** A further role center gets its own page extension with `addlast(rolecenter)`. The platform leaves the part out for a user without read permission on `Report Test`, so no `AccessByPermission` is needed (checked by a test).

**Report discovery.** `FillTestTable()` runs when the dashboard opens and inserts a row for every report in 50000..100000 that has none. It never changes or deletes existing rows. The range is set in that procedure. Rows whose report no longer exists stay until the user chooses `Remove Missing Reports`.

**Document pages for report selections.** `GetListPageNo` and `GetCardPageNo` delegate to one `case` procedure per area (purchase, sales, service, reminder). A new usage goes into the matching procedure and into `SourceTableView` of page 50101, a new area gets its own procedure. `S.Invoice`, `S.Cr.Memo`, `P.Invoice` and `P.Cr.Memo` are the usages of the posted documents in the standard, but are mapped to the unposted document pages since version 1.0: change that only when the user asks for it.

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
| Codeunit 50150 `Report Overview Mgt. Test` | Logic without pages: page mapping per usage, report caption, `FillTestTable`, FlowField `Report Caption`, numbers of the enum values, `OpenReportSettings`, test status, test parameters, line styles, current layout, `SaveReportToBlob`, file name, missing reports |
| Codeunit 50151 `Report Overview Page Test` | Dashboard through `TestPage`: discovery on open, filters and filter actions, Quick Run Report, inline buttons, editing and adding lines, favorites actions, report selections part with all usages, navigation actions |
| Codeunit 50154 `Report Overview Tools Test` | Dashboard through `TestPage`: settings and layout buttons, test status and its filter, test parameters, download, `Remove Missing Reports`, Quick Run with the ID of another object type, `Favorite Reports` part alone and on the role center |
| Codeunit 50153 `Report Overview Perm. Test` | Permission set `Report Overview`: dashboard, favorites part and cleanup work with it, the dashboard cannot be opened without it, the role center leaves the part out without it |
| Report 50150 `Report Overview Test Report` | Custom report inside the scanned range. It has no request page and counts its runs |
| Report 50151 `Test Report With Request Page` | Same with a request page |
| Report 50152 `Test Report With Layout` | Report with request page, one data row and an empty RDLC layout (`TestLayout`), for layout and download tests |
| Codeunit 50152 `Test Report Run Counter` | Single instance counter that the test reports increment |
| PermissionSet 50150 `Report Overview Test` | Covers the test objects |

Rules for tests:
- `Subtype = Test`, `TestPermissions = Disabled`, comments `// [GIVEN]`, `// [WHEN]`, `// [THEN]`, assertions with `Library Assert`. After `asserterror` always `Assert.ExpectedError('<text>')`.
- The test runner rolls data back per test **codeunit**, not per test. Every test starts with `Initialize()`, which removes the rows and resets the counters earlier tests left behind. `Initialize()` deletes all rows of `Report Test`: run the tests only with the default runner (isolation per codeunit) and never in an environment with real data.
- The environment can contain other custom reports. Assert on specific rows (`FindReportLine`), never on totals. Rows 50197 to 50199 are entries without a report object, used for filter tests.
- Never assert on translatable captions: the language of the test session depends on the environment (the container is a DE localization). The caption of the test report is locked for that reason.
- Running a report without request page: use `Report Overview Test Report` and check `TestReportRunCounter.GetRunCount()`. A `ReportHandler` is not called for a report without request page.
- Running a report with request page: use `Test Report With Request Page` with a `[RequestPageHandler]`. The test needs `[TransactionModel(TransactionModel::AutoCommit)]` and a call of `CommitPageTriggers()` right before the drilldown. Without the commit `Report.RunModal` fails with "An error occurred and the transaction is stopped", because the test has an open write transaction. The same holds for `Report.RunRequestPage` and `Report.Execute`. Moving to another line of an editable `TestPage` can write the line, so position on the line first and commit last. The runner still rolls the committed data back at the end of the codeunit (checked in `bc29`). `Commit()` is allowed only through `CommitPageTriggers()`.
- Dialogs need handlers: `[StrMenuHandler]` for the download format, `[ConfirmHandler]` for `Confirm Management` (the test session has a user interface), `[MessageHandler]` for messages. A handler with a counter and a preset answer keeps the tests short.
- `DownloadFromStream` needs no handler: the download test only checks that the report ran. The content of the file is checked through `SaveReportToBlob`.
- A Blob read after `Get()` is empty without `CalcFields`, and `HasValue()` is true anyway: read test parameters only through `GetTestParameters()`.
- A missing RDLC layout file is generated by the compiler on the first build. Commit the generated file.
- Opening a page from an inline button or a navigation action: `[PageHandler]` with a `TestPage` of the opened page and a counter. Use a small standard page (`Payment Terms`) where the page number is test data.
- Actions of a ListPart are invoked through the part of the dashboard (`ReportOverview.ReportOverviewSubpage.AddToFavorites.Invoke()`), not on the ListPart opened on its own (TA0002).
- A `TestPage` returns option filters as ordinal value (`3` for object type Report), other filters as text. Read enum fields with `AsInteger()`.
- A value rejected by a `TableRelation`: `asserterror` on `SetValue`, then `Assert.ExpectedErrorCode('TestValidation')`. Use `GetUnusedObjectId()`: the Quick Run field only rejects an ID that no object of any type uses, the table fields `List Page No.` and `Card Page No.` also reject the ID of another object type.
- Permissions: `StartWithBasicPermissions()` sets `D365 BASIC` through `Permissions Mock`, `Assign` adds a permission set. Stop the mock before the assertions, otherwise a failed assertion leaves it running for the following tests. A missing table permission has the error code `DB:ClientReadDenied`, a part that the platform left out has `TestPartNotFound`.
- A test must be able to fail: when a test guards a property or a line of code, remove that line once and check that the test turns red.

## Not automatable
List these for the user as manual test steps whenever a change touches them:
- Look: `Style` and `StyleExpr` in the client (the style names are tested), column widths, symbols, promoted actions and their categories, the position of the part on the role centers.
- Finding the dashboard through the search (`UsageCategory`).
- Real report output: preview through the run button with test parameters, print, and the content of a downloaded PDF, Word or Excel file of a report with a real layout.
- Deleting a line (a `TestPage` cannot delete), lookups of the ID fields, the filter pane of the parts.
- Refresh behavior in the client (`UpdatePropagation`, enabled state of the actions after a click, styles after editing a line).
- Upgrade of an environment that already has data of an older version.

## Screenshots
The images in `resources/` are taken in the container with demo data, never with the reports of the test app:
- Use a throwaway demo app outside the repo (own ID range, depends on the main app) with a few custom reports that have realistic captions, and a codeunit that fills `Report Test` in the company `My Company`. Run the codeunit with `Invoke-NavContainerCodeunit`. Uninstall the test app while taking screenshots, so that its reports are not listed.
- Afterwards remove the demo rows, unpublish the demo app, publish the test app again and run the whole suite.
- The container is a DE localization: texts of the platform are German in the images, the captions of this app are English.
