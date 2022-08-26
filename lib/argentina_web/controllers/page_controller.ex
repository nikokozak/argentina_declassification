defmodule ArgentinaWeb.PageController do
  use ArgentinaWeb, :controller

  def index(conn, %{ "collection" => collection, "set" => set } = _params) do
    # IO.inspect("Collection: #{ collection }, Set: #{ set }")
    case Argentina.Archive.get_set(collection, set) do
      {:error, :no_index} -> raise Phoenix.Router.NoRouteError, message: "No index for collection"
      set -> 
        text_content = File.read!(set["txt"])
        render(conn, "index.html", set: set, collection: collection, text_content: text_content)
    end
  end


end
