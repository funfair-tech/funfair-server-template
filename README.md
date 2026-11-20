# funfair-server-template

Template repository for C# / server code

## Build Status

<!-- Add in significant CI badges for your repo here. -->
<!-- For example, if you have a pre-release and release workflow, -->
<!-- add both badges. -->
<!-- When using this template, make sure the badge URLs point -->
<!-- to the ones in this repo. -->

| Branch  | Status                                                       |
|---------|--------------------------------------------------------------|
| main    | [![Build: Pre-Release][pre-release-img]][pre-release-link]   |
| release | [![Build: Release][release-img]][release-link]               |

## Documentation

See [NuGet Trusted Publishing][nuget-trusted-publishing] for the nuget.org and repository secret configuration a repository derived from this template needs to publish packages.

## AWS credentials: ECS task role

Services must not use long-lived IAM user access keys (`AWS_ACCESS_KEY_ID` / `AWS_SECRET_KEY`). Give the ECS task a task role instead, so the container receives short-lived credentials that rotate automatically.

- Create a per-service `AWS::IAM::Role` trusted by `ecs-tasks.amazonaws.com`, with an inline policy granting only the permissions that service needs (for example `cloudformation:DescribeStacks` and the specific `sns` actions it uses).
- Reference it from the ECS task definition as `TaskRoleArn` (this is separate from `ExecutionRoleArn`, which ECS itself uses to pull images and read secrets).
- `cloudformation-deploy` passes `--capabilities CAPABILITY_IAM`, so stacks may create the role. Use `CAPABILITY_NAMED_IAM` instead only if a template sets an explicit `RoleName`.
- Construct AWS SDK clients with the default credential chain (no `BasicAWSCredentials`) so the task role is picked up automatically. For local development supply credentials through environment variables or an AWS profile.
- Remove the access-key and secret-key settings and their `Secrets` entries once a service has moved over, then rotate and delete the old IAM user keys.

```json
{
  "ServiceTaskRole": {
    "Type": "AWS::IAM::Role",
    "Properties": {
      "AssumeRolePolicyDocument": {
        "Version": "2012-10-17",
        "Statement": [
          {
            "Effect": "Allow",
            "Principal": { "Service": "ecs-tasks.amazonaws.com" },
            "Action": "sts:AssumeRole"
          }
        ]
      },
      "Policies": [
        {
          "PolicyName": "service-access",
          "PolicyDocument": {
            "Version": "2012-10-17",
            "Statement": [
              {
                "Effect": "Allow",
                "Action": ["cloudformation:DescribeStacks"],
                "Resource": "*"
              }
            ]
          }
        }
      ]
    }
  },
  "TaskDefinition": {
    "Type": "AWS::ECS::TaskDefinition",
    "Properties": {
      "TaskRoleArn": { "Fn::GetAtt": ["ServiceTaskRole", "Arn"] }
    }
  }
}
```

## Workflow runners

Every job, apart from those listed under Exceptions below, reads its `runs-on` from a repository (or organisation) variable for its workflow's category:

- `PRE_RELEASE_BUILD_ENVIRONMENT` (build): `build-and-publish-pre-release.yml`.
- `RELEASE_BUILD_ENVIRONMENT` (build): `build-and-publish-release.yml`.
- `CHECK_ENVIRONMENT` (check): `pr-lint.yml`, `pr-update.yml`, `test-check-no-files-actions.yml`, `check-composite-action-versions.yml`.
- `DEPLOY_ENVIRONMENT` (deploy): `deploy.yml`.
- `MAINTENANCE_ENVIRONMENT` (maintenance): `pull-request.yml`, `branch-protection-sync.yml`, `create-prs-for-stale-branches.yml`,
  `missing-releases.yml`, `on-pr-closed.yml`, `update-labels.yml`, `approve-dependabot.yml`, `dependabot.yml`, `dotnet-version.yml`.

Variable values:

- A value is a single runner label (for example `ubuntu-latest`) or a JSON array of labels,
  for example `["self-hosted","linux","build"]`; a value starting with `[` is parsed as JSON.
- An unset variable defaults to `ubuntu-latest`.

Exceptions:

- Every `pr-lint.yml` and `test-check-no-files-actions.yml` job runs a pull request from a fork on `ubuntu-latest`,
  whatever `CHECK_ENVIRONMENT` says.
- `pr-update.yml` skips pull requests from forks; `pr-update-fork.yml` handles them and always runs on `ubuntu-latest`,
  reading no variable, because it holds a writable token while handling an untrusted pull request.
- `on-pr-closed.yml` skips pull requests from forks, because their read-only token cannot delete caches;
  those caches are left to expire.
- In `build-and-publish-pre-release.yml`, a `build-pre-release` run that did not allocate a build number runs on
  `ubuntu-latest`: a fork pull request, an in-repo pull request run already built by push, or a failed or cancelled allocation.

The fork exceptions in `pr-lint.yml`, `test-check-no-files-actions.yml`, `pr-update.yml`, `on-pr-closed.yml` and
`build-and-publish-pre-release.yml` are best effort, not an enforced boundary. A `pull_request` run uses the workflow
files from the pull request's merge ref, so a fork can edit those guards in its own copy and pick a self-hosted label.
`pr-update-fork.yml` is different: it runs under `pull_request_target` from the base branch, so a fork cannot change it
and its guards are enforced. Two repository or organisation settings are what actually keep fork pull requests off
self-hosted runners:

- Require approval before running workflows from fork pull requests.
- Restrict self-hosted runner groups so that public repositories and fork pull requests cannot use them.

## Changelog

View [changelog](CHANGELOG.md)

[nuget-trusted-publishing]: NUGET-TRUSTED-PUBLISHING.md
[pre-release-img]: https://github.com/funfair-tech/funfair-server-template/actions/workflows/build-and-publish-pre-release.yml/badge.svg
[pre-release-link]: https://github.com/funfair-tech/funfair-server-template/actions/workflows/build-and-publish-pre-release.yml
[release-img]: https://github.com/funfair-tech/funfair-server-template/actions/workflows/build-and-publish-release.yml/badge.svg
[release-link]: https://github.com/funfair-tech/funfair-server-template/actions/workflows/build-and-publish-release.yml
