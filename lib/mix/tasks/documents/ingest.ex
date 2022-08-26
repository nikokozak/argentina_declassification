defmodule Mix.Tasks.Documents.Ingest do
  use Mix.Task

  def run(args) do
    folder = List.first(args)

    Argentina.Storage.Logic.copy_and_ingest(folder)
  end
end
