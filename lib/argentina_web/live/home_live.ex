defmodule ArgentinaWeb.Live.HomeLive do
  use ArgentinaWeb, :live_view

  def mount(_params, _session, socket) do
    sets = Argentina.SearchEngine.all_documents("test_index", limit: 100)

    {:ok, assign(socket, sets: sets)}
  end

  def handle_event("search", %{ "search_field" => %{ "query" => query }, "collections" => colls }, socket) do
    searchable_collections = Enum.reduce(colls, [], fn 
      {_coll, "false"}, acc -> acc
      {coll, "true"}, acc -> [ "collection = \"#{coll}\"" | acc ]
    end) 

    filter_query = Enum.join(searchable_collections, " AND ")

    sets = do_search(query, filter_query)

    {:noreply, assign(socket, :sets, sets)}
  end

  defp do_search("", _), do: Argentina.SearchEngine.all_documents("test_index")
  defp do_search(query, []) do
    {:ok, %{ "hits" => sets }} = Argentina.SearchEngine.search("test_index", query)
    sets
  end
  defp do_search(query, cols_filter) do
    {:ok, %{ "hits" => sets }} = Argentina.SearchEngine.search("test_index", query, filter: cols_filter)
    sets
  end

  def render(assigns) do
    ArgentinaWeb.HomeView.render("index.html", assigns)
  end

end
