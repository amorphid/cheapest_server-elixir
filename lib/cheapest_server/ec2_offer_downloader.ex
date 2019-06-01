defmodule CheapestServer.EC2OfferDownloader do
  use Gin.Server

  defdelegate handle_cast(message, data), to: __MODULE__, as: :handle_info

  defstruct do
    defkey(:name, default: __MODULE__, type: Atom)
  end

  #######
  # API #
  #######

  def initiate_download(pid \\ __MODULE__, current_version_url) do
    GenServer.cast(pid, {:download, current_version_url})
  end

  #############
  # Callbacks #
  #############

  def handle_info({:download, current_version_url}, %__MODULE__{} = data) do
    IO.inspect(current_version_url)
    {:noreply, data}
  end
end
