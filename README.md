# ggshield MDM Deploy

MDM scripts to deploy and keep [ggshield](https://github.com/GitGuardian/ggshield) up to date on macOS.

Inspired by [Installomator](https://github.com/Installomator/Installomator).

## Supported MDM Platforms

| Platform                      | Directory | Description                                         |
| ----------------------------- | --------- | --------------------------------------------------- |
| [Iru](iru/) (formerly Kandji) | `iru/`    | Audit & remediation scripts for Iru Custom Scripts  |
| [Jamf Pro](jamf/)             | `jamf/`   | Install script and Extension Attribute for Jamf Pro |

## Structure

```
shared/
  ggshield_install.sh                    # Shared install script (single source of truth)
  ggshield_configure_eu.sh                # Points ggshield at GitGuardian's EU dashboard
  ggshield_configure_self_hosted.sh       # Points ggshield at a self-hosted instance
iru/
  ggshield_audit.sh                      # Iru audit script
  ggshield_remediation.sh                # -> ../shared/ggshield_install.sh (symlink)
  ggshield_configure_eu.sh                # -> ../shared/ggshield_configure_eu.sh (symlink)
  ggshield_configure_self_hosted.sh       # -> ../shared/ggshield_configure_self_hosted.sh (symlink)
jamf/
  ggshield_install.sh                    # -> ../shared/ggshield_install.sh (symlink)
  ggshield_configure_eu.sh                # -> ../shared/ggshield_configure_eu.sh (symlink)
  ggshield_configure_self_hosted.sh       # -> ../shared/ggshield_configure_self_hosted.sh (symlink)
  jamf_ea_ggshield_version.sh
```

The install logic lives in `shared/ggshield_install.sh`. Platform directories symlink to it. When uploading to your MDM, copy the resolved file contents.

## How It Works

The install script:

1. Fetches the latest ggshield release from GitHub (supports both Apple Silicon and Intel)
2. Verifies the `.pkg` signature via Gatekeeper (`spctl`) and validates the GitGuardian Team ID (`N67C7J5WQ9`)
3. Confirms the package is notarized by Apple
4. Installs the package and verifies the installed binary signature

## Instance Configuration

By default ggshield talks to GitGuardian's public SaaS dashboard. If your organization uses the
EU-hosted dashboard or a self-hosted instance, run one of the configuration scripts after install:

- `ggshield_configure_eu.sh` — points ggshield at `https://dashboard.eu1.gitguardian.com`, no
  editing required.
- `ggshield_configure_self_hosted.sh` — edit the `INSTANCE_URL` variable at the top of the script
  to your self-hosted dashboard URL before deploying.

ggshield stores the instance setting per-user (`~/.gitguardian.yaml`), not system-wide, so both
scripts detect the logged-in console user and run `ggshield config set instance` as that user
rather than as root.
