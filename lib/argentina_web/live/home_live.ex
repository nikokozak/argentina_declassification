defmodule ArgentinaWeb.Live.HomeLive do
  use ArgentinaWeb, :live_view

  @number_of_docs_limit 100

  def mount(_params, _session, socket) do
    sets = Argentina.SearchEngine.all_documents("test_index", limit: @number_of_docs_limit)

    {:ok, assign(socket, sets: sets, searchable_collections: [])}
  end

  def handle_event("search", %{ "search_field" => %{ "query" => query }, "collections" => colls }, socket) do
    searchable_collections = Enum.reduce(colls, [], fn 
      {_coll, "false"}, acc -> acc
      {coll, "true"}, acc -> [ coll | acc ]
    end) 

    filter_query = 
      searchable_collections 
      |> Enum.map(&("collection = \"#{&1}\""))
      |> Enum.join(" AND ")

    sets = do_search(query, filter_query)

    {:noreply, assign(socket, sets: sets, searchable_collections: searchable_collections)}
  end

  defp do_search("", _), do: Argentina.SearchEngine.all_documents("test_index", limit: @number_of_docs_limit)
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
