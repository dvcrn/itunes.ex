defmodule Itunes do

  @itunes_url "https://itunes.apple.com"

  defp query_itunes(type, query, entity, limit, store) do
    verb = case type do
      "search" -> "term"
      "lookup" -> "id"
      _ -> "term"
    end

    wrapper_type = case entity do
      "album" -> "collection"
      "musicArtist" -> "artist"
      "song" -> "track"
    end

    url = "#{@itunes_url}/#{type}?#{verb}=#{query}&entity=#{entity}&limit=#{limit}&country=#{store}" |> URI.encode

    case HTTPoison.get(url) do
      {:ok, response} ->
        case Poison.decode(response.body) do
          {:ok, data} ->
            data
            |> Map.put(
              "results",
              Map.get(data, "results") |> Enum.filter(&(&1["wrapperType"] === wrapper_type))
            )
            |> (&(Tuple.append({:ok}, &1))).()

          {:error, err} -> {:error, err}
        end
      {:error, err} -> {:error, err}
    end
  end

  defp search_itunes(query, entity, limit, store) do
    query_itunes("search", query, entity, limit, store)
  end

  defp lookup_itunes(id, entity, limit, store) do
    query_itunes("lookup", id, entity, limit, store)
  end

  defp search_and_parse(query, entity, struct, limit, store) do
    case search_itunes(query, entity, limit, store) do
      {:ok, data} ->
        %{"results" => results, "resultCount" => result_count} = data
        {:ok, Enum.map(results, &Itunes.StructParser.to_struct(struct, &1))}

      {:error, err} -> {:error, err}
    end
  end

  defp lookup_and_parse(id, entity, struct, limit, store) do
    case lookup_itunes(id, entity, limit, store) do
      {:ok, data} ->
        %{"results" => results, "resultCount" => result_count} = data
        {:ok, Enum.map(results, &Itunes.StructParser.to_struct(struct, &1))}

      {:error, err} -> {:error, err}
    end
  end

  @doc """
  Queries iTunes for songs for the given query.

  Note that the hard limit for iTunes is 200 results. More can not be returned.

  Returns `{:ok, [t:%Itunes.Song, ...]}`, `{:error, reason}`
  """
  def search_songs(query, limit \\ 10, store \\ "us") do
    search_and_parse(query, "song", Itunes.Song, limit, store)
  end

  @doc """
  Queries iTunes for albums for the given query.

  Note that the hard limit for iTunes is 200 results. More can not be returned.

  Returns `{:ok, [t:%Itunes.Album, ...]}`, `{:error, reason}`
  """
  def search_albums(query, limit \\ 10, store \\ "us") do
    search_and_parse(query, "album", Itunes.Album, limit, store)
  end

  @doc """
  Queries iTunes for artists for the given query.

  Note that the hard limit for iTunes is 200 results. More can not be returned.

  Returns `{:ok, [t:%Itunes.Artist, ...]}`, `{:error, reason}`
  """
  def search_artists(query, limit \\ 10, store \\ "us") do
    search_and_parse(query, "musicArtist", Itunes.Album, limit, store)
  end

  @doc """
  Uses a iTunes lookup to get the artist information by id

  Returns `{:ok, t:%Itunes.Artist}`, `{:error, reason}`

  In case no result is found, `{:ok, nil}` is being returned.
  """
  def artist_by_id(id, store \\ "us") do
    case lookup_and_parse(id, "musicArtist", Itunes.Artist, 0, store) do
      {:ok, response} -> {:ok, List.first(response)}
      {:error, err} -> {:error, err}
    end
  end

  @doc """
  Uses a iTunes lookup to get the album information by id

  Returns `{:ok, t:%Itunes.Album}`, `{:error, reason}`

  In case no result is found, `{:ok, nil}` is being returned.
  """
  def album_by_id(id, store \\ "us") do
    case lookup_and_parse(id, "album", Itunes.Album, 0, store) do
      {:ok, response} -> {:ok, List.first(response)}
      {:error, err} -> {:error, err}
    end
  end

  @doc """
  Uses a iTunes lookup to get the song information by id

  Returns `{:ok, t:%Itunes.Song}`, `{:error, reason}`

  In case no result is found, `{:ok, nil}` is being returned.
  """
  def song_by_id(id, store \\ "us") do
    case lookup_and_parse(id, "song", Itunes.Song, 0, store) do
      {:ok, response} -> {:ok, List.first(response)}
      {:error, err} -> {:error, err}
    end
  end

  @doc """
  Uses a iTunes lookup to get all songs for the given itunes id.
  Id can be a artist *or* a album id, both are okay

  Note that the hard limit for iTunes is 200 results. More can not be returned.

  Returns `{:ok, [t:%Itunes.Song, ...]}`, `{:error, reason}`
  """
  def songs_by_id(id, limit \\ 10, store \\ "us") do
    lookup_and_parse(id, "song", Itunes.Song, limit, store)
  end

  @doc """
  Uses a iTunes lookup to get all songs for the given itunes album id.

  Note that the hard limit for iTunes is 200 results. More can not be returned.

  Returns `{:ok, [t:%Itunes.Album, ...]}`, `{:error, reason}`
  """
  def albums_by_artist_id(id, limit \\ 10, store \\ "us") do
    lookup_and_parse(id, "album", Itunes.Album, limit, store)
  end
end
