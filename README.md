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

## Changelog

View [changelog](CHANGELOG.md)

[nuget-trusted-publishing]: NUGET-TRUSTED-PUBLISHING.md
[pre-release-img]: https://github.com/funfair-tech/funfair-server-template/actions/workflows/build-and-publish-pre-release.yml/badge.svg
[pre-release-link]: https://github.com/funfair-tech/funfair-server-template/actions/workflows/build-and-publish-pre-release.yml
[release-img]: https://github.com/funfair-tech/funfair-server-template/actions/workflows/build-and-publish-release.yml/badge.svg
[release-link]: https://github.com/funfair-tech/funfair-server-template/actions/workflows/build-and-publish-release.yml
