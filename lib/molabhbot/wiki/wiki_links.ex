defmodule Molabhbot.WikiLinks do

  use GenServer

  @url "http://wiki.labmola.xyz"

  def init(initial_state) do
    {:ok, initial_state, 0}
  end

  def handle_info(:timeout, state) do
    {:noreply, %{state | links: perform_initial_fetch(@url)}}
  end

  def handle_call(:get_links, _from, %{links: links} = state) do
    {:reply, {:ok, links}, state}
  end

  def handle_cast(:refresh_links, state) do
    IO.inspect "refreshing links", label: "wiki"
    {:noreply, %{state | links: perform_initial_fetch(@url)}}
  end

  def start_link() do
    initial_state = %{links: []}
    GenServer.start_link(__MODULE__, initial_state, name: __MODULE__)
  end

  def refresh_links() do
    GenServer.cast(__MODULE__, :refresh_links)
  end

  def get_links!() do
    # fetch links here
    {:ok, links} = GenServer.call(__MODULE__, :get_links)
    links
  end

  defp perform_initial_fetch(url) do
    url
    |> fetch_html()
    |> parse_wiki_links(url)
  end

  defp fetch_html(url) do
    %HTTPoison.Response{body: body} = HTTPoison.get!(url, [], follow_redirect: true)
    body
  end

  defp parse_wiki_links(body, url) do
    links = Floki.find(body, ".level3 div.li a")
    for {"a", [{"href", href}|_], [desc]} <- links, do: {url <> href, desc}
  end

end
