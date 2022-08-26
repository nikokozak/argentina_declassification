defmodule ArgentinaWeb.PdfViewerController do
  use ArgentinaWeb, :controller

  def viewer(conn, %{ "pdf_path" => pdf_path } = _params) do
    render(conn, "viewer.html", pdf_path: pdf_path)
  end

end
