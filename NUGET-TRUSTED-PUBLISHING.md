# NuGet Trusted Publishing

Repositories derived from this template publish to nuget.org using [Trusted Publishing](https://learn.microsoft.com/en-us/nuget/nuget-org/trusted-publishing) instead of a long-lived `NUGET_API_KEY`; nuget.org is deprecating static API keys. GitHub Actions requests a short-lived OIDC token, exchanges it with nuget.org for a temporary (1-hour) API key, and uses that key to push. Trusted Publishing only applies to the nuget.org feed; `NUGET_FEED` must point at nuget.org for this to work. A repository publishing to Sleet instead (`NUGET_API_KEY` set to the sentinel value `SLEET`) is unaffected.

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
| `NUGET_API_KEY` | Any non-empty value opts into a nuget.org push (the value itself is no longer used as a credential); set to the literal sentinel value `SLEET` instead to publish via Sleet |
| `NUGET_USER_NAME` | The nuget.org username (profile name) the Trusted Publishing policy above is registered against, not an email address |
| `NUGET_FEED` | Must remain the nuget.org v3 index, `https://api.nuget.org/v3/index.json` |

`NUGET_USER_NAME` may be set once at the organisation level if all repositories publish under the same nuget.org account.

`NUGET_SYMBOL_FEED` is no longer used: nuget.org pushes symbols through the same push call, so a separate symbol feed isn't needed.

A repository whose nuget.org policy or `NUGET_USER_NAME` isn't set up yet will fail the build's publish step with a clear error rather than silently doing nothing; set both up before merging a change that triggers a publish.
