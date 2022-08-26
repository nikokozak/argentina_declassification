defmodule Argentina.Archive do
  alias Argentina.Archive.Impl

  def all(index), do: Argentina.SearchEngine.all_documents(index)

  @doc """
  Imports a folder into the archive, creating a collection and splitting files into sets.
  Assumes that the folder to import has a flat file structure, ideally with PDF's accompanied
  by `txt`, and `png` files of the same name.
  """
  @spec import(String.t, String.t) :: :ok
  defdelegate import(folder_path, collection_name), to: Impl

  defdelegate add_to_search_engine(se_index, collection), to: Impl

  defdelegate rebuild_index(collection_name), to: Impl

  defdelegate rebuild_all_indexes(), to: Impl

  @doc """
  Returns a list of sets in the given collection, each with a `txt_content` field
  containing the content of given set's txt file. This is useful when passing in docs
  to the Search Engine.
  """
  @spec export(String.t) :: list(map)
  defdelegate export(collection_name), to: Impl

  @doc """
  Lists the name of all sets in a given collection.
  """
  @spec list_set_names(String.t) :: list(String.t)
  defdelegate list_set_names(collection_name), to: Impl

  @doc """
  Lists the sets in a given collection.
  """
  @spec list_sets(String.t) :: list(map) | nil | {:error, :no_index}
  defdelegate list_sets(collection_name), to: Impl

  @doc """
  Lists the different collections available in the archive.
  """
  @spec list_collections() :: list(String.t)
  defdelegate list_collections(), to: Impl

  @doc """ 
  Returns a map with properties of a given set in a collection.
  """
  @spec get_set(String.t, String.t) :: map | nil | {:error, :no_index}
  defdelegate get_set(collection_name, set_name), to: Impl

  @spec find_set(String.t, (map -> true | false)) :: map | nil | {:error, :no_index}
  defdelegate find_set(collection_name, find_fn), to: Impl

end
