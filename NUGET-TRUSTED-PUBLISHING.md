# NuGet Trusted Publishing

Repositories derived from this template can publish to nuget.org using [Trusted Publishing](https://learn.microsoft.com/en-us/nuget/nuget-org/trusted-publishing) instead of a long-lived `NUGET_API_KEY`. GitHub Actions requests a short-lived OIDC token, exchanges it with nuget.org for a temporary (1-hour) API key, and uses that key to push. Trusted Publishing only applies to the nuget.org feed; other feeds (private feeds, Sleet) keep using a static API key unchanged.

## nuget.org setup (one-off, per repository)

This step happens on nuget.org itself and cannot be automated from this repository. Sign in to nuget.org, open **Trusted Publishing**, and add one policy per publishing workflow:

- **Repository Owner**: `funfair-tech` (or the owning org/user of the derived repository)
- **Repository**: the repository name
- **Workflow File**: the file name only, not the path, e.g. `build-and-publish-release.yml` or `build-and-publish-pre-release.yml`
- **Environment** (optional): leave blank unless the workflow uses a GitHub Actions `environment:`

This repository publishes from two workflows (`build-and-publish-pre-release.yml` and `build-and-publish-release.yml`), so two separate policies are needed.

## GitHub repository configuration

Set these in the repository (or organisation) secrets:

| Secret | Value |
| --- | --- |
| `NUGET_API_KEY` | Set to the literal sentinel value `TRUSTED_PUBLISHING` to opt in (mirrors the existing `SLEET` sentinel used to select the Sleet publish path) |
| `NUGET_USER_NAME` | The nuget.org username (profile name) the Trusted Publishing policy above is registered against, not an email address |
| `NUGET_FEED` | Must remain the nuget.org v3 index, `https://api.nuget.org/v3/index.json` |

`NUGET_USER_NAME` may be set once at the organisation level if all repositories publish under the same nuget.org account.

Leave `NUGET_API_KEY` as a real API key (or `SLEET`) for any repository not publishing to nuget.org; Trusted Publishing is not available for other feeds.

`NUGET_SYMBOL_FEED` is not used on the Trusted Publishing path: nuget.org pushes symbols through the same push call, so any configured separate symbol feed is ignored while `NUGET_API_KEY` is `TRUSTED_PUBLISHING`.
