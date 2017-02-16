defmodule BrokenLinks.PageAnalyzer do
  # returns a list of broken links
  def analyze(url) do
    case HTTPoison.get(url, [], [ssl: [{:versions, [:'tlsv1.2']}]]) do
      {:ok, %HTTPoison.Response{body: body, status_code: 200}} ->
        broken_links = find_links(body) |> Enum.filter(&broken_link?/1)
        {:ok, broken_links}
      oops ->
        {:error, inspect(oops)}
    end
  end

  defp broken_link?(%{href: href}) do
    case HTTPoison.get(href, [], [ssl: [{:versions, [:'tlsv1.2']}]]) do
      {:ok, %HTTPoison.Response{status_code: status_code}} -> status_code >= 400
      _ -> true
    end
  end

  defp find_links(html) do
    html
    |> Floki.find("a")
    |> Enum.map(fn {_, attrs, [text]} ->
      {_, href} = Enum.find(attrs, fn {k, _} -> k == "href" end)
      %{text: text, href: href}
    end)
  end
end
