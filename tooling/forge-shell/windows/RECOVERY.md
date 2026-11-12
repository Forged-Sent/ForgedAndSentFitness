# Recovery plan — Forge Shell 2.0

Use these steps for the optional personal shell installed by this repository.

## Scope

All implementation lives in `%USERPROFILE%\.config\powershell`. No application repository files, Git configuration, PATH registry entries, execution policies, credentials, or machine installations are changed by the core installer.

The installer appends one marked loader to `$PROFILE.CurrentUserAllHosts`. Existing profile content is preserved around the managed loader. Windows PowerShell 5.1 stays untouched. PowerShell 7.5+ and 64-bit are required.

## Before each activation

1. Parse every PowerShell source file and validate configuration.
2. Save byte-for-byte copies of every file being changed under `backups/<timestamp>/`, with SHA-256 hashes and a manifest recording absent files too.
3. Refuse overlapping managed blocks or modified rollback targets.
4. Write atomically. On an installation error, restore changes made by that transaction.

Terminal and VS Code settings have a separate preview/apply transaction. No package installation is part of core activation. Existing notes and bookmarks are imported only when requested, from an explicit source, without deleting the source.

## Escape hatch

Open `"C:\Program Files\PowerShell\7\pwsh.exe" -NoProfile`.

Run `& "$HOME\.config\powershell\Uninstall.ps1" -WhatIf` to preview removal of the managed loader and theme changes. Run without `-WhatIf` to disable it. Your personal data, source files, and backups remain available. Start a fresh shell afterward.

Run `& "$HOME\.config\powershell\Restore.ps1" -Backup <backup-directory> -WhatIf` to preview an exact transaction rollback. Changed-since-install files cause a refusal instead of overwriting later edits. A forced restore is an explicit, confirmed choice.

Set `$env:FORGE_DISABLE = '1'` before starting a child shell to bypass the loader without modifying files. `reloadforge` reloads the module globally and disposes owned prompt processes; opening a new shell is the cleanest reset.
