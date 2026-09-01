# ggshield - Iru Custom Scripts

Iru (formerly Kandji) audit and remediation scripts to deploy and keep [ggshield](https://github.com/GitGuardian/ggshield) up to date on macOS.

Inspired by [Installomator](https://github.com/Installomator/Installomator).

## Scripts

### `ggshield_audit.sh`

Custom Script (Audit) that checks whether ggshield is:

- Installed at `/usr/local/bin/ggshield`
- Code-signed with the expected GitGuardian Team ID (`N67C7J5WQ9`)
- Running the latest version (fetched from GitHub releases)

**Exit codes:** `0` = pass, `1` = fail (triggers remediation).

If GitHub is unreachable, the version check is skipped to avoid false failures.

### `ggshield_remediation.sh`

Symlink to [`../shared/ggshield_install.sh`](../shared/ggshield_install.sh). Custom Script (Remediation) that:

1. Fetches the latest release from GitHub (supports both Apple Silicon and Intel)
2. Verifies the `.pkg` signature via Gatekeeper (`spctl`) and validates the Team ID
3. Confirms the package is notarized by Apple
4. Installs the package and verifies the installed binary signature

### `ggshield_configure_eu.sh`

Symlink to [`../shared/ggshield_configure_eu.sh`](../shared/ggshield_configure_eu.sh). Custom
Script that points ggshield at GitGuardian's EU-hosted dashboard
(`https://dashboard.eu1.gitguardian.com`) for the logged-in console user. No editing required.

### `ggshield_configure_self_hosted.sh`

Symlink to
[`../shared/ggshield_configure_self_hosted.sh`](../shared/ggshield_configure_self_hosted.sh).
Custom Script that points ggshield at a self-hosted GitGuardian instance for the logged-in console
user. Edit the `INSTANCE_URL` variable at the top of the script before uploading.

## Iru Setup

1. Create a **Custom Script** library item
2. Set `ggshield_audit.sh` as the **Audit Script**
3. Set `ggshield_remediation.sh` as the **Remediation Script**
4. Assign to the appropriate Blueprint(s)
5. If you're on the EU or a self-hosted instance, create a separate **Custom Script** library item
   running `ggshield_configure_eu.sh` or `ggshield_configure_self_hosted.sh` (edited with your URL)
