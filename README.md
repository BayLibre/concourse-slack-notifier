# concourse-slack-notifier [![License: Apache-2.0](https://img.shields.io/badge/License-Apache_2.0-yellow.svg)](https://opensource.org/licenses/Apache-2.0)  [![Docker Pulls](https://img.shields.io/docker/pulls/mkorpershoek/concourse-slack-notifier.svg)](https://hub.docker.com/r/mkorpershoek/concourse-slack-notifier/)

A structured and opinionated Slack notification resource for [Concourse](https://concourse.ci/). It started as a rewrite of [arbourd/concourse-slack-alert-resource](https://github.com/arbourd/concourse-slack-alert-resource) in Rust to add a few features, mainly reading the message from a file or being able to send shorter messages that still had a similar format.

<img src="https://raw.githubusercontent.com/makohoek/concourse-slack-notifier/master/img/custom.png">

This is an up-to-date fork of https://github.com/mockersf/concourse-slack-notifier/ with [instanced pipeline](https://concourse-ci.org/instanced-pipelines.html) support.

This work is based on https://github.com/aoldershaw/concourse-slack-notifier/tree/support-instance-vars

The message is built by using Concourse's [resource metadata](https://concourse-ci.org/implementing-resources.html#resource-metadata) to show the pipeline, job, build number and a URL.

## Installing

Use this resource by adding the following to the resource_types section of a pipeline config:

```yaml
resource_types:

- name: slack-notifier
  type: docker-image
  source:
    repository: mkorpershoek/concourse-slack-notifier
```

See the [Concourse docs](https://concourse-ci.org/resource-types.html) for more details on adding `resource_types` to a pipeline config.

## Source Configuration

* `url`: *Required.* Slack webhook URL.
* `channel`: *Optional*. Target channel where messages are posted. If unset the default channel of the webhook is used.
* `concourse_url`: *Optional.* The external URL that points to Concourse. Defaults to the env variable `ATC_EXTERNAL_URL`.
* `username`: *Optional.* Concourse local user (or basic auth) username. Required for non-public pipelines if using alert type `fixed` or `broke`
* `password`: *Optional.* Concourse local user (or basic auth) password. Required for non-public pipelines if using alert type `fixed` or `broke`
* `ca_cert`: *Optional.* A CA certificate for the Concourse instance. This is used to validate the certificate of Concourse when the instance's certificate is signed by a custom authority (or itself).
* `ignore_ssl`: *Optional.* This option allows unsecure access to Concourse (not verifying certificates).
* `disabled`: *Optional.* This option will disable all notifications from this resource.

```yaml
resources:

- name: notify
  type: slack-notifier
  source:
    url: https://hooks.slack.com/services/T00000000/B00000000/XXXXXXXXXXXXXXXXXXXXXXXX
```

## Behavior

### `check`: No operation.

### `in`: No operation.

### `out`: Send a message to Slack.

Sends a structured message to Slack based on the alert type and mode.

#### Parameters

- `alert_type`: *Optional.* The type of alert to send to Slack. See [Alert Types](#alert-types). Defaults to `custom`.
- `channel`: *Optional.* Channel where this message is posted. Defaults to the `channel` setting in Source.
- `message`: *Optional.* The status message at the top of the alert. Defaults to name of alert type.
- `message_file`: *Optional.* The path to a file to use as message.
- `fail_if_message_file_missing`: *Optional.* Will fail if `message_file` is set but the file is missing. Defaults to `false`.
- `color`: *Optional.* The color of the notification bar as a hexadecimal. Defaults to the icon color of the alert type.
- `mode`: *Optional.* The amount of information displayed in the message. See [Modes](#modes). Defaults to `normal_with_info`.
- `disabled`: *Optional.* This notification is disabled.
- `message_as_code`: *Optional.* Message text will be wrapped in ` ``` [...] ``` `, if message is in mode `normal` or `normal_with_info`.

basic configuration:
```yaml
jobs:
  plan:
  - put: notify
```

with an alert type, a mode and a message
```yaml
jobs:
  plan:
  - put: notify
    params:
      message: my job failed
      mode: concise
      alert_type: failed
```

#### Alert Types

- `custom`

  <img src="https://raw.githubusercontent.com/makohoek/concourse-slack-notifier/master/img/custom.png" width="75%">

- `success`

  <img src="https://raw.githubusercontent.com/makohoek/concourse-slack-notifier/master/img/success.png" width="75%">

- `failed`

  <img src="https://raw.githubusercontent.com/makohoek/concourse-slack-notifier/master/img/failed.png" width="75%">

- `started`

  <img src="https://raw.githubusercontent.com/makohoek/concourse-slack-notifier/master/img/started.png" width="75%">

- `aborted`

  <img src="https://raw.githubusercontent.com/makohoek/concourse-slack-notifier/master/img/aborted.png" width="75%">

- `fixed`

  Fixed is a special alert type that only alerts if the previous build did not succeed. Fixed requires `username` and `password` to be set for the resource if the pipeline is not public.

  <img src="https://raw.githubusercontent.com/makohoek/concourse-slack-notifier/master/img/fixed.png" width="75%">

- `broke`

  Broke is a special alert type that only alerts if the previous build succeed. Broke requires `username` and `password` to be set for the resource if the pipeline is not public.

  <img src="https://raw.githubusercontent.com/makohoek/concourse-slack-notifier/master/img/broke.png" width="75%">

#### Modes

Examples notifications with a messages with the different modes:

- `concise`

  <img src="https://raw.githubusercontent.com/makohoek/concourse-slack-notifier/master/img/concise.png" width="75%">

- `normal`

  <img src="https://raw.githubusercontent.com/makohoek/concourse-slack-notifier/master/img/normal.png" width="75%">

- `normal_with_info`

  <img src="https://raw.githubusercontent.com/makohoek/concourse-slack-notifier/master/img/normal_with_info.png" width="75%">
