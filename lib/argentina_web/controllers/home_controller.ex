defmodule ArgentinaWeb.HomeController do
  use ArgentinaWeb, :controller
  alias Phoenix.LiveView

  def index(conn, _params) do
    LiveView.Controller.live_render(conn, ArgentinaWeb.Live.HomeLive, conn: conn)
  end
end
