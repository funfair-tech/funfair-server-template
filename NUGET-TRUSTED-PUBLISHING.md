# NuGet Trusted Publishing

Repositories derived from this template publish to nuget.org using [Trusted Publishing](https://learn.microsoft.com/en-us/nuget/nuget-org/trusted-publishing) instead of a long-lived API key; nuget.org is deprecating static API keys. GitHub Actions requests a short-lived OIDC token, exchanges it with nuget.org for a temporary (1-hour) API key, and uses that key to push. Trusted Publishing only applies to the nuget.org feed; `NUGET_FEED` must point at nuget.org for this to work. Which path a repository takes (nuget.org, Sleet, or no publish at all) is controlled by `NUGET_FEED_TYPE` below.

## nuget.org setup (one-off, per repository)

This step happens on nuget.org itself and cannot be automated from this repository. Sign in to nuget.org, open **Trusted Publishing**, and add one policy per publishing workflow:

- **Repository Owner**: `funfair-tech` (or the owning org/user of the derived repository)
- **Repository**: the repository name
- **Workflow File**: the file name only, not the path, e.g. `build-and-publish-release.yml` or `build-and-publish-pre-release.yml`
- **Environment** (optional): leave blank unless the workflow uses a GitHub Actions `environment:`

This repository publishes from two workflows (`build-and-publish-pre-release.yml` and `build-and-publish-release.yml`), so two separate policies are needed.

## GitHub repository configuration

| Setting | Kind | Value |
| --- | --- | --- |
| `NUGET_FEED_TYPE` | variable | `NUGET` to publish to nuget.org via Trusted Publishing, `SLEET` to publish via Sleet, empty/unset to skip publishing. Neither this nor `NUGET_USER_NAME` carries any credential material, so both are plain variables, not secrets |
| `NUGET_USER_NAME` | variable | The nuget.org username (profile name) the Trusted Publishing policy above is registered against, not an email address |
| `NUGET_FEED` | secret | Must remain the nuget.org v3 index, `https://api.nuget.org/v3/index.json` |

`NUGET_USER_NAME` may be set once at the organisation level if all repositories publish under the same nuget.org account.

An unrecognised `NUGET_FEED_TYPE` value (a typo, or a leftover static API key from before this template switched to Trusted Publishing) fails the build with a clear error rather than silently skipping the publish step.

`NUGET_SYMBOL_FEED` and `NUGET_API_KEY` are no longer used. This template currently packs with `IncludeSymbols=False`, so no symbol package is produced at all; if that ever changes, nuget.org accepts a `.snupkg` through the same push call, so no separate symbol feed configuration would be needed even then. No static API key is stored or read for the nuget.org path any more.

A repository whose `NUGET_USER_NAME` secret is missing entirely will fail fast with a clear "required but not set" error. If `NUGET_USER_NAME` is set (e.g. inherited from an organisation-level secret) but the matching nuget.org policy hasn't been created yet, the failure instead surfaces as a less obvious error from the OIDC login/exchange step itself; set the policy up before merging a change that triggers a publish.
