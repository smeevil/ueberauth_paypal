# Überauth Paypal

> Paypal OAuth2 strategy for Überauth.

## Installation

1. Setup your application at [https://developer.paypal.com](https://developer.paypal.com).

1. Add `:ueberauth_paypal` to your list of dependencies in `mix.exs`:

    ```elixir
    def deps do
      [{:ueberauth_paypal, "~> 0.1"}]
    end
    ```

1. Add the strategy to your applications:

    ```elixir
    def application do
      [applications: [:ueberauth_paypal]]
    end
    ```

1. Add Paypal to your Überauth configuration:

    ```elixir
    config :ueberauth, Ueberauth,
      providers: [
        paypal: {Ueberauth.Strategy.Paypal, []}
      ]
    ```

1.  Update your provider configuration:

    ```elixir
    config :ueberauth,
      Ueberauth.Strategy.Paypal.OAuth, [
        client_id: System.get_env("PAYPAL_CLIENT_ID"),
        client_secret: System.get_env("PAYPAL_CLIENT_SECRET"),
        sandbox: false
      ]
    ```
    Note: the sandbox option, in your dev and test you might want to set this to true. The sandbox has different API credentials.
    
1.  Include the Überauth plug in your controller:

    ```elixir
    defmodule MyApp.AuthController do
      use MyApp.Web, :controller
      plug Ueberauth
      ...
    end
    ```

1.  Create the request and callback routes if you haven't already:

    ```elixir
    scope "/auth", MyApp do
      pipe_through :browser

      get "/:provider", AuthController, :request
      get "/:provider/callback", AuthController, :callback
    end
    ```

1. Your controller needs to implement callbacks to deal with `Ueberauth.Auth` and `Ueberauth.Failure` responses.

For an example implementation see the [Überauth Example](https://github.com/ueberauth/ueberauth_example) application.

## Calling

Depending on the configured URL you can initialize the request through:

    /auth/paypal

