defmodule Ueberauth.Strategy.Paypal.OAuth do
  @moduledoc """
  OAuth2 for Paypal.

  Add `client_id` and `client_secret` to your configuration:
  config :ueberauth, Ueberauth.Strategy.Facebook.OAuth,
    client_id: System.get_env("PAYPAL_CLIENT_ID"),
    client_secret: System.get_env("PAYPAL_CLIENT_SECRET")
    sandbox: false #default

  Do note that you can pass a `sandbox: true` option in this config
  to use the paypal sandbox for authentication, by default this is false.
  """
  use OAuth2.Strategy
  @defaults [
    authorize_url: "https://www.paypal.com/webapps/auth/protocol/openidconnect/v1/authorize",
    token_url: "https://www.paypal.com/webapps/auth/protocol/openidconnect/v1/tokenservice",
    site: "https://api.paypal.com",
    scope: "openid profile email address",
    strategy: __MODULE__,
    sandbox: false,
  ]

  def scope, do: @defaults[:scope]

  def authorize_url!(params \\ [], opts \\ []) do
    params = Keyword.merge([scope: scope], params)
    opts
    |> create_client
    |> OAuth2.Client.authorize_url!(params)
  end

  def get_token!(params \\ [], opts \\ []) do
    opts
    |> create_client
    |> OAuth2.Client.get_token!(params)
  end

  def authorize_url(client, params) do
    OAuth2.Strategy.AuthCode.authorize_url(client, params)
  end

  def get_token(client, params, headers) do
    client
    |> put_header("Accept", "application/json")
    |> OAuth2.Strategy.AuthCode.get_token(params, headers)
  end

  defp set_sandbox_if_needed(options) do
    case Keyword.fetch(options, :sandbox) do
      {:ok, true} -> options |> create_sandbox_urls
      _ -> options
    end
  end

  defp create_sandbox_urls([] = options), do: options
  defp create_sandbox_urls([{key, "https://" <> _rest = url}|tail]) do
    [{key, String.replace(url, "paypal.com", "sandbox.paypal.com")}| create_sandbox_urls(tail)]
  end
  defp create_sandbox_urls([head|tail]), do: [head | create_sandbox_urls(tail)]

  defp create_client(opts) do
    opts
    |> enrich_options
    |> OAuth2.Client.new
  end

  defp enrich_options(opts) do
    @defaults
    |> Keyword.merge(Application.get_env(:ueberauth, Ueberauth.Strategy.Paypal.OAuth) || [])
    |> Keyword.merge(opts)
    |> set_sandbox_if_needed
  end
end
