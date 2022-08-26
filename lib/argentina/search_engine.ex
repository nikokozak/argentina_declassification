defmodule Argentina.SearchEngine do

  @doc """
  Creates a new index, which by default passes a `filterableAttributes` option for our `collection` field.
  """
  @spec create_index(String.t, keyword) :: {:ok, map}
  def create_index(name, opts \\ [ {:filterableAttributes, ["collection"]} ]), do: Meilisearch.Indexes.create(name, opts)

  def delete_index(name), do: Meilisearch.Indexes.delete(name)

  def all_documents(index_name, opts \\ []) do
    case Meilisearch.Documents.list(index_name, opts) do
      {:ok, docs} -> Map.get(docs, "results")
      error -> error
    end
  end

  def add_documents(index_name, document_list) when is_list(document_list) do
    Meilisearch.Documents.add_or_replace(index_name, document_list)
  end
  def add_documents(index_name, json_file) when is_binary(json_file) do
    docs = File.read!(json_file)
           |> Jason.decode!

    add_documents(index_name, docs)
  end

  def search(index_name, term, opts \\ []), do: Meilisearch.Search.search(index_name, term, opts)

end
