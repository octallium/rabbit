# Repository Organization

`Sparrow` is essentially a `Monorepo` consisting of the following folder structure -

1. `docs` - Stores all of the documention like Project Specs, User Manual and Dev Docs.
2. `slib` - All of the code lives here, it's just an abbrevation for `Sparrow Lib`. To see the repo details click [here](../../slib/Readme.md).

## Branching Strategy -

1. Main Branches:
   1. `main`: Contains production-ready code.
   2. `dev`: Integrates features for the next release.

2. Supporting Branches:
   1. `feature/*`: Used to develop new features.
   2. `release/*`: Prepares a new production release.
   3. `hotfix/*`: Fixes bugs in the production code.

## Workflow -

1. New features are developed in `feature/*` branches.
2. Features are merged into `dev` when ready.
3. When a `release` is **ready**, a `release/*` branch is created from `dev`.
4. Once the `release` is **stable**, it's merged into `main` and `tagged`.
5. Hotfixes are made in `hotfix/*` branches from `main` and then merged back into both `main` and `dev`.

## Naming Conventions -

### A. General -

1. Use short but descriptive names to convery the purpose of branch.
2. Use `lowercase` alphabets to avoid any case sensitivity issues.
3. Use `hypens` to seperate words for readability.

### B. Feature Branch -

For `feature/*` branch, try to start with a verb followed by the object, examples -

1. `feature/add-user-authentication`
2. `feature/add-new-report`
3. `feature/user-notifications-system`
4. `feature/login`
5. `feature/fix-email-notification`
6. If there is a ticket associated, `feature/apr-12345-add-support-tools`

### C. Release Branch -

For `release/*` branch, use semantic versioning (MAJOR.MINOR.PATCH) to indicate the release version.

Include descriptive tags if the release has a specific focus or milestone, examples -

1. `release/v1.0.0-beta`
2. `release/v2.1.0-rc1`
3. `release/v1.0.0-stable`
4. `release/v2.1.0-qa`
5. Use dates to indicate planned release - `release/2024-07-30` , `release/2024-07-30-v0.1.0-test`

### D. Hotfix Branch -

For `hotfix/*` branch, use descriptive names which conveys the purpose of hotfix.

1. `hotfix/apr-1234-reaccom-engine-failing`
2. `hotfix/v1.3.10-patch`
3. `hotfix/fix-notifications-download`
