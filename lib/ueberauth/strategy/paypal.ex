defmodule Ueberauth.Strategy.Paypal do
  @moduledoc """
  Paypal Strategy for Überauth.
  """
  use Ueberauth.Strategy

  alias Ueberauth.Auth.Info
  alias Ueberauth.Auth.Credentials
  alias Ueberauth.Auth.Extra
  alias Ueberauth.Strategy.Paypal

  #übearauth callbacks
  def handle_request!(conn) do
    authorize_url = conn.params
    |> Enum.map(fn {k,v} -> {String.to_existing_atom(k), v} end)
    |> Keyword.put(:redirect_uri, callback_url(conn))
    |> Paypal.OAuth.authorize_url!

    redirect!(conn, authorize_url)
  end

  def handle_callback!(%Plug.Conn{params: %{"code" => code}} = conn) do
    options = [redirect_uri: callback_url(conn)]
    token = Paypal.OAuth.get_token!([code: code], options)
    handle_token(token, conn)
  end
  def handle_callback!(conn) do
    conn |> set_errors!([error("missing_code", "No code received")])
  end

  def handle_cleanup!(conn) do
    conn
    |> put_private(:paypal_user, nil)
    |> put_private(:paypal_token, nil)
  end

  # übearauth callbacks to gather information
  def uid(conn) do
    "https://www.paypal.com/webapps/auth/identity/user/" <> uid = conn.private.paypal_user["user_id"]
    uid
  end

  def extra(conn) do
    %Extra{
      raw_info: %{
        token: conn.private.paypal_token,
        user: conn.private.paypal_user
      }
    }
  end

  def info(conn) do
    user = conn.private.paypal_user
    %Info{
      name: user["name"],
      first_name: user["given_name"],
      last_name: user["family_name"],
      email: user["email"]
    }
  end

  def credentials(conn) do
    token = conn.private.paypal_token
    %Credentials{
      expires: !!token.expires_at,
      expires_at: token.expires_at,
      scopes: Paypal.OAuth.scope,
      token: token.access_token,
      refresh_token: token.refresh_token,
      token_type: token.token_type,
      other: token.other_params
    }
  end

  #privates

  defp fetch_user(conn, token) do
    token
    |> OAuth2.AccessToken.get("/v1/identity/openidconnect/userinfo/?schema=openid")
    |> handle_response(conn)
  end

  defp handle_response({:ok, %OAuth2.Response{status_code: 401, body: _body}}, conn) do
    set_errors!(conn, [error("token", "unauthorized")])
  end
  defp handle_response({:ok, %OAuth2.Response{status_code: status_code, body: user}}, conn) when status_code in 200..399 do
    put_private(conn, :paypal_user, user)
  end
  defp handle_response({:error, %OAuth2.Error{reason: reason}}, conn) do
    set_errors!(conn, [error("OAuth2", reason)])
  end

  defp handle_token(%{access_token: nil} = token, conn) do
    err = token.other_params["error"]
    desc = token.other_params["error_description"]
    set_errors!(conn, [error(err, desc)])
  end
  defp handle_token(token, conn) do
    conn
    |> put_private(:paypal_token, token)
    |> fetch_user(token)
  end
end
