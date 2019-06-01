defmodule CheapestServer.OfferIndexPoller do
  use Gin.Server
  require Logger
  alias CheapestServer.EC2OfferDownloader

  defstruct do
    defkey(:init_timeout,
      default: 0,
      type: Integer
    )

    defkey(:name,
      default: __MODULE__,
      type: Atom
    )

    defkey(:pid,
      default: EC2OfferDownloader,
      types: [Atom, PID]
    )

    defkey(:poll_interval,
      default: 3_600_000,
      type: Integer
    )

    defkey(:retry_interval,
      default: 60_000,
      type: Integer
    )

    defkey(:url,
      default: %URI{
        authority: "pricing.us-east-1.amazonaws.com",
        fragment: nil,
        host: "pricing.us-east-1.amazonaws.com",
        path: "/offers/v1.0/aws/index.json",
        port: 443,
        query: nil,
        scheme: "https",
        userinfo: nil
      },
      type: URI
    )
  end

  #############
  # Callbacks #
  #############

  def handle_continue(
        :download,
        %__MODULE__{
          poll_interval: poll_interval,
          retry_interval: retry_interval,
        } = data
      ) do
    case initiate_ec2_offer_download(data) do
      :ok -> 
        {:noreply, data, poll_interval}

      :error -> 
        {:noreply, data, poll_interval}
    end
  end

  def handle_info(:timeout, %__MODULE__{} = data) do
    {:noreply, data, {:continue, :download}}
  end

  @doc false
  def initiate_ec2_offer_download(%__MODULE__{pid: pid, url: url}) do
    case HTTPoison.get(url) do
      {:ok, %HTTPoison.Response{body: body_as_json, status_code: 200}} ->
        body_as_json
        |> JSONMomoa.parse()
        |> case do
          {body, ""} ->
            body
        end
        |> Map.fetch!("offers")
        |> Map.fetch!("AmazonEC2")
        |> Map.fetch!("currentVersionUrl")
        |> String.replace(~r/json^/, "csv")
        |> case do
          current_version_url ->
            EC2OfferDownloader.initiate_download(pid, current_version_url)
        end
      {:error, _} ->
        :ok = Logger.warn("Price poll failed.  Retrying in #{60_000} milliseconds.")
        :error
    end
  end
end
