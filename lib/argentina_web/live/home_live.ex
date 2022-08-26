defmodule ArgentinaWeb.Live.HomeLive do
  use ArgentinaWeb, :live_view

  def mount(_params, _session, socket) do
    sets = Argentina.SearchEngine.all_documents("test_index", limit: 100)

    {:ok, assign(socket, sets: sets)}
  end

  def handle_event("search", %{ "search_field" => %{ "query" => query } }, socket) do
    sets = do_search(query)

    {:noreply, assign(socket, :sets, sets)}
  end

  defp do_search(""), do: Argentina.SearchEngine.all_documents("test_index")
  defp do_search(query) do
    {:ok, %{ "hits" => sets }} = Argentina.SearchEngine.search("test_index", query)
    sets
  end

  def render(assigns) do
    ArgentinaWeb.HomeView.render("index.html", assigns)
  end

end
