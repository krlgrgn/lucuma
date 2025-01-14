defmodule LucumaWeb.Endpoint do
  use Phoenix.Endpoint, otp_app: :lucuma

  @session_options [
    store: :cookie,
    key: "_lucuma_key",
    signing_salt: "a8qXPAHf"
  ]

  def cache_raw_body(conn, opts) do
    case conn.path_info == ["billing", "webhooks"] do
      true ->
        {:ok, body, conn} = Plug.Conn.read_body(conn, opts)
        conn = update_in(conn.assigns[:raw_body], &[body | &1 || []])
        {:ok, body, conn}

      _ ->
        {:ok, body, conn} = Plug.Conn.read_body(conn, opts)
    end
  end

  # Checking if the SQL sandbox env is present because during feature/integrations tests
  # the endpoint is running and we want to enable concurrent testing.
  if Application.get_env(:lucuma, :sql_sandbox) do
    plug Phoenix.Ecto.SQL.Sandbox,
      at: "/sandbox",
      repo: Lucuma.Repo,
      timeout: 15_000
  end

  socket "/socket", LucumaWeb.UserSocket,
    websocket: [timeout: 45_000],
    longpoll: false

  socket "/live", Phoenix.LiveView.Socket, websocket: [connect_info: [session: @session_options]]

  # Serve at "/" the static files from "priv/static" directory.
  #
  # You should set gzip to true if you are running phx.digest
  # when deploying your static files in production.
  plug Plug.Static,
    at: "/",
    from: :lucuma,
    gzip: false,
    only: ~w(css fonts images js favicon.ico robots.txt)

  # Code reloading can be explicitly enabled under the
  # :code_reloader configuration of your endpoint.
  if code_reloading? do
    socket "/phoenix/live_reload/socket", Phoenix.LiveReloader.Socket
    plug Phoenix.LiveReloader
    plug Phoenix.CodeReloader
  end

  plug Plug.RequestId
  plug Plug.Logger

  plug Plug.Parsers,
    parsers: [:urlencoded, :multipart, :json],
    body_reader: {LucumaWeb.Endpoint, :cache_raw_body, []},
    pass: ["*/*"],
    json_decoder: Phoenix.json_library()

  plug Plug.MethodOverride
  plug Plug.Head

  # The session will be stored in the cookie and signed,
  # this means its contents can be read but not tampered with.
  # Set :encryption_salt if you would also like to encrypt it.
  plug Plug.Session, @session_options

  plug LucumaWeb.Router
end
