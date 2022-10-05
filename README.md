# eien [![Gem Version](https://img.shields.io/gem/v/eien.svg)](https://rubygems.org/gems/eien) [![Build Status](https://img.shields.io/github/workflow/status/alhafoudh/eien/Test?event=push)](https://github.com/alhafoudh/eien/actions?query=event%3Apush)

`eien` is a command line tool that manages and deploys apps to any Kubernetes cluster and abstracts all kubernetes
concepts from you.

📦 Focus of `eien` is to require minimum dependencies inside the Kubernetes cluster and use standard Kubernetes features
to manage and deploy the app. `eien` tries to follow all best practices for deploying apps in Kubernetes.

⚙️ `eien` has simple commands like you are used to
from [heroku CLI](https://devcenter.heroku.com/articles/heroku-cli-commands)
or [dokku CLI](https://dokku.com/docs/deployment/application-management).

🏗 `eien` uses [Krane](https://github.com/Shopify/krane) gem to deploy Kubernetes resources. This allows you to:

- monitor the deploy status and see if the roll out was successfull
- see debug information if case of failure
- predeploys certain types of resources to make sure they are available for resources that might consume them (e.g. Deployment)

For more information visit https://github.com/Shopify/krane.

## Installation

`eien` requires Ruby 2.7 or newer.

Install the gem and add to the application's Gemfile by executing:

    $ bundle add eien

If bundler is not being used to manage dependencies, install the gem by executing:

    $ gem install eien

️⭐️ *Recommendation*: Lock down the version of `eien` gem by adding the gem to `Gemfile` to ensure consistency. If you don't use `bundler` just create `Gemfile` only for `eien` gem version tracking.

## Usage

1. Initialize Kubernetes cluster for `eien`


    $ eien init <kubernetes context>

This will deploy `eien` [Kubernetes Custom Resource Definitions](https://kubernetes.io/docs/concepts/extend-kubernetes/api-extension/custom-resources) to store app , processes and other definitions. Those are used to generate Kubernetes resources when depoying the apps.

2. Create `eien` app and select it to be used ever time when deploying from current diretory

    ```
    $ eien apps create myapp
    $ eien apps select myapp
    ```    

3. Create first process (like Procfile process type)

    ```
    $ eien ps create web --enabled --image ealen/echo-server:latest --replicas 3 --ports http:80
    ```

4. Create domain

    ```
    $ eien domain create myapp.x.x.x.x.nip.io
    ```
    

5. Create route to route HTTP request from domain to process port

    ```
    $ eien route create root --enabled --domains myapp.x.x.x.x.nip.io --path / --process web --port http
    ```
    

6. Preview what Kubernetes resources would be deployed

    ```
    $ eien deploy generate
    ```
    

7. Finally, deploy the app

    ```
    $ eien deploy apply
    ```

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/alhafoudh/eien. This project is intended to
be a safe, welcoming space for collaboration, and contributors are expected to adhere to
the [code of conduct](https://github.com/alhafoudh/eien/blob/main/CODE_OF_CONDUCT.md).

## License

The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).

## Code of Conduct

Everyone interacting in the Eien project's codebases, issue trackers, chat rooms and mailing lists is expected to follow
the [code of conduct](https://github.com/alhafoudh/eien/blob/main/CODE_OF_CONDUCT.md).
