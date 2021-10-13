# slack-unfurling-redmine

A Slack unfruling Lambda function for Redmine.
It based on AWS SAM(Serverless application mode).

Inspired by and based on [slack-unfurling-esa](https://github.com/mallowlabs/slack-unfurling-esa).

## Requirements

* AWS CLI
* SAM CLI

## Deploy

### Slack side

#### 1. Create Slack App

https://api.slack.com/apps

#### 2. `Event Subscriptions` setting

`Enable Events` Set to On

`App Unfurl Domains` Add your redmine url.

Click `Save Changes`.

#### 3. `OAuth & Permissions` setting

Added `links:write` to `Scopes`.

Click `Install App to Workspace`.

Remember your `OAuth Access Token`.

### Lambda side

```bash
$ aws s3 mb s3://your-sandbox --region ap-northeast-1
```

```bash
$ cd slack-unfurling-redmine
$ bundle install --path vendor/bundle
```

```bash
$ sam package \
    --template-file template.yaml \
    --output-template-file serverless-output.yaml \
    --s3-bucket your-sandbox
```

```bash
$ sam deploy \
    --template-file serverless-output.yaml \
    --stack-name your-slack-unfurling-redmine \
    --capabilities CAPABILITY_IAM \
    --parameter-overrides \
      RedmineAPIAccessKey=your-api-access-key \
      SlackOauthAccessToken=your-slack-oauth-token
```

Confirm your endpoint url.

(To ignore custom fields, add IgnoreCustomFields=true for parameter-overrides.)


```bash
$ aws cloudformation describe-stacks --stack-name your-slack-unfurling-redmine --region ap-northeast-1
```

### Slack side
Input your endpoint url to `Request URL` in `Event Subscriptions`.

Click `Save Changes`.
