defmodule StorageTests do
  alias Argentina.Storage.Logic
  use ExUnit.Case

  @test_dir "./storage_tests"

  setup do
    File.mkdir!(@test_dir)

    on_exit(fn -> File.rm_rf!(@test_dir) end)
    :ok
  end

  describe "remove_extraneous_extensions!/1" do

    test "removes extensions" do
      File.touch!(Path.join(@test_dir, "one.pdf.txt"))
      File.touch!(Path.join(@test_dir, "one.pdf"))
      File.touch!(Path.join(@test_dir, "a.pdf"))
      File.touch!(Path.join(@test_dir, "b.pdf"))
      File.touch!(Path.join(@test_dir, "a"))
      File.touch!(Path.join(@test_dir, "b.txt"))
  
      expected = ["a", "b.txt", "one.pdf", "a.pdf", "b.pdf", "one.txt"]

      Logic.get_files_in_folder(@test_dir)
      |> Logic.remove_extraneous_extensions!


      assert expected == Logic.get_files_in_folder(@test_dir) |> Enum.map(&Path.basename/1)
    end

  end

end
