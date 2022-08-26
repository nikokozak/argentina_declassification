defmodule Mix.Tasks.Documents.Reprocess do
  use Mix.Task

  def run(args) do
    folder = List.first(args)

    Argentina.Storage.Logic.ingest(folder)
  end
end
