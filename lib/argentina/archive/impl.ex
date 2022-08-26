defmodule Argentina.Archive.Impl do
  @index_name "index.json"

  # REPO-like module for interacting with files in the local filesystem.
  # In this case "archive" files. 
  # ----
  # Hidden file with state of files. (track which files we've already ingested, etc.) Index of files.
  #
  # Assumptions:
  # 1. All individual files are part of a "collection"
  # 2. A "set" of files includes ".pdf", ".txt", and ".png" files as well as others, all sharing the same rootname.
  # 3. No postprocessing will be done on files in this module (no name cleanup, etc.).
  # 4. There will ALWAYS be a ".pdf", ".txt", and ".png" file in each set.
  # 5. Files are always valid.
  # 6. The folder structure being imported is FLAT!
  #
  # Archive Structure:
  # archive/
  #   index.json
  #   collection_1/
  #   collection_2/
  #     index.json
  #     filename/
  #       filename.pdf
  #       filename.txt
  #       filename.png

  @doc """
  Imports a folder into the archive, creating a collection and splitting files into sets.
  """
  @spec import(String.t, String.t) :: :ok
  def import(folder_path, collection_name) do
    # Make a collection parent folder at the archive location (i.e. "archive/ARMY")
    make_collection(collection_name)

    #Copy files and remove folders from file list.
    File.cp_r!(folder_path, collection_path(collection_name)) 
    |> Enum.filter(&(Path.extname(&1) !== ""))
    |> make_sets_for_files(collection_name)
    |> move_files_into_sets(collection_name)
    |> make_index(collection_name)
    |> write_index(collection_name)
  end
  
  ########################################

  @spec make_collection(String.t) :: :ok
  defp make_collection(name), do: File.mkdir!(Path.join(archive_path(), name))

  @spec add_to_search_engine(String.t, String.t) :: {:ok, map()}
  def add_to_search_engine(se_index, collection_name) do
    docs = export(collection_name)

    Argentina.SearchEngine.add_documents(se_index, docs)
  end

  ########################################
  
  @doc """
  Returns a list of sets in the given collection, each with a `txt_content` field
  containing the content of given set's txt file.
  """
  @spec export(String.t) :: list(map)
  def export(collection_name) do
    File.read!(Path.join(collection_path(collection_name), @index_name))
    |> Jason.decode!
    |> Map.fetch!("sets")
    |> Enum.map(&transform_set_for_export(collection_name, &1))
  end

  defp transform_set_for_export(collection_name, set) do
    set
    |> Map.put("text_content", File.read!(set["txt"]))
    |> Map.put("collection", collection_name)
    |> Map.delete("txt")
    |> Map.delete("pdf")
    |> Map.delete("thumb")
  end
  
  ########################################

  @doc """
  Lists the name of all sets in a given collection.
  """
  @spec list_set_names(String.t) :: list(String.t)
  def list_set_names(collection_name) do
    if File.exists?(index_path(collection_name)) do
      File.read!(index_path(collection_name))
      |> Jason.decode!
      |> Map.get("sets")
      |> Enum.map(&(&1["name"]))
    else
      File.ls!(collection_path(collection_name))
    end
  end

  @doc """
  Lists the name of all sets in a given collection.
  """
  @spec list_sets(String.t) :: list(map) | nil | {:error, :no_index}
  def list_sets(collection_name) do
    if File.exists?(index_path(collection_name)) do
      File.read!(index_path(collection_name))
      |> Jason.decode!
      |> Map.get("sets")
    else
      {:error, :no_index}
    end
  end

  @doc """ 
  Returns a map with properties of a given set in a collection.
  """
  @spec get_set(String.t, String.t) :: map | nil | {:error, :no_index}
  def get_set(collection_name, set_name) do
    find_set(collection_name, &(&1["name"] == set_name))
  end

  @spec find_set(String.t, (map -> true | false)) :: map | nil | {:error, :no_index}
  def find_set(collection_name, find_fn) do
    if File.exists?(index_path(collection_name)) do
      File.read!(index_path(collection_name))
      |> Jason.decode!
      |> Map.get("sets")
      |> Enum.find(find_fn)
    else
      {:error, :no_index}
    end
  end

  ######################################## 

  def list_collections() do
    File.ls!(archive_path())
    |> Enum.filter(&(Path.extname(&1) === ""))
  end

  ########################################

  def make_index(set_names, collection_name) do
    %{ 
      collection: collection_name,
      sets: Enum.map(set_names, &make_set_index(collection_name, &1))
    }
  end

  def rebuild_all_indexes() do
    list_collections()
    |> Enum.each(&rebuild_index/1)
  end

  def rebuild_index(collection_name) do
    list_set_names(collection_name)
    |> make_index(collection_name)
    |> write_index(collection_name)
  end

  def write_index(index, collection_name) do
    serialized = Jason.encode!(index)
    File.write!(index_path(collection_name), serialized)
  end

  defp make_set_index(collection_name, set_name) do
    file_path_base = Path.join(set_path(collection_name, set_name), set_name) 
    static_file_path_base = Path.join(set_path(collection_name, set_name, true), set_name) 
    %{ 
      id: UUID.uuid4(),
      collection: collection_name,
      name: set_name,
      static_pdf: file_or_nil(file_path_base <> ".pdf", static_file_path_base <> ".pdf"),
      pdf: file_or_nil(file_path_base <> ".pdf"),
      static_txt: file_or_nil(file_path_base <> ".txt", static_file_path_base <> ".txt"),
      txt: file_or_nil(file_path_base <> ".txt"),
      static_thumb: file_or_nil(file_path_base <> ".png", static_file_path_base <> ".png"),
      thumb: file_or_nil(file_path_base <> ".png"),
      text_content: nil
    }
  end

  defp file_or_nil(file, return \\ false), do: if File.exists?(file), do: return || file, else: nil

  ########################################

  defp make_sets_for_files(file_list, collection_name) do
    set_names = set_names_from_filelist(file_list)
    Enum.each(set_names, &make_set(collection_name, &1))

    set_names
  end

  defp move_files_into_sets(set_names, collection_name) do
    set_names
    |> Enum.each(&move_files_into_single_set(collection_name, &1))

    set_names
  end

  defp move_files_into_single_set(collection_name, set_name) do
    files = Path.wildcard(Path.join(collection_path(collection_name), set_name <> ".*"))
    Enum.each(files, &File.cp!(&1, Path.join(set_path(collection_name, set_name), Path.basename(&1))))
    Enum.each(files, &File.rm!(&1))
  end

  ########################################
  
  @spec make_set(String.t, String.t) :: :ok
  defp make_set(collection_name, set_name), do: File.mkdir!(Path.join(archive_path(), collection_name) |> Path.join(set_name))

  ########################################

  @spec set_names_from_filelist(list(String.t)) :: list(String.t)
  defp set_names_from_filelist(file_list), do: remove_duplicates(file_list, [])

  defp remove_duplicates([], result_list), do: result_list |> Enum.reverse
  defp remove_duplicates([el | input_list], result_list) do
    rootname = Path.basename(el) |> Path.rootname()
    if rootname in result_list do
      remove_duplicates(input_list, result_list)
    else
      remove_duplicates(input_list, [rootname | result_list])
    end
  end
  
  ########################################

  def index_path(collection_name), do: Path.join(collection_path(collection_name), @index_name)

  @spec collection_path(String.t) :: String.t
  defp collection_path(name), do: collection_path(name, false)
  defp collection_path(name, _static = false), do: Path.join(archive_path(), name)
  defp collection_path(name, _static = true), do: Path.join(static_path(), name)

  @spec set_path(String.t, String.t) :: String.t
  defp set_path(collection_name, set_name), do: set_path(collection_name, set_name, false)
  defp set_path(collection_name, set_name, _static = false), do: Path.join(collection_path(collection_name), set_name)
  defp set_path(collection_name, set_name, _static = true), do: Path.join(collection_path(collection_name, true), set_name)

  defp archive_path, do: Application.fetch_env!(:argentina, Argentina.Archive) |> Keyword.fetch!(:path)
  defp static_path do
    p = archive_path() |> Path.basename
    "/" <> p
  end

end
