defmodule Itunes do
  @moduledoc """
  iTunes search API wrapper and main module.

  ## Examples


  ### Getting a artist by id
  ```
  iex(1)> Itunes.search_artists "Taylor", 1
  {:ok,
   [%Itunes.Artist{amgArtistId: 816977, artistId: 159260351,
     artistLinkUrl: "https://itunes.apple.com/us/artist/taylor-swift/id159260351?uo=4",
     artistName: "Taylor Swift", artistType: "Artist", primaryGenreId: 14,
     primaryGenreName: "Pop", wrapperType: "artist"}]}
  ```

  ### Retrieving 3 albums for a given artist

  ```
  iex(1)> Itunes.albums_by_artist_id 159260351, 3
  {:ok,
   [%Itunes.Album{amgArtistId: 816977, artistId: 159260351,
     artistName: "Taylor Swift",
     artistViewUrl: "https://itunes.apple.com/us/artist/taylor-swift/id159260351?uo=4",
     artworkUrl100: "http://is2.mzstatic.com/image/thumb/Music5/v4/29/fa/b6/29fab67f-c950-826f-26a0-5eebcd0e262b/source/100x100bb.jpg",
     artworkUrl60: "http://is2.mzstatic.com/image/thumb/Music5/v4/29/fa/b6/29fab67f-c950-826f-26a0-5eebcd0e262b/source/60x60bb.jpg",
     collectionCensoredName: "1989", collectionExplicitness: "notExplicit",
     collectionId: 907242701, collectionName: "1989", collectionPrice: 10.99,
     collectionType: "Album",
     collectionViewUrl: "https://itunes.apple.com/us/album/1989/id907242701?uo=4",
     copyright: "℗ 2014 Big Machine Records, LLC.", country: "USA",
     currency: "USD", primaryGenreName: "Pop",
     releaseDate: "2014-10-27T07:00:00Z", trackCount: 14,
     wrapperType: "collection"},
    %Itunes.Album{amgArtistId: 816977, artistId: 159260351,
     artistName: "Taylor Swift",
     artistViewUrl: "https://itunes.apple.com/us/artist/taylor-swift/id159260351?uo=4",
     artworkUrl100: "http://is4.mzstatic.com/image/thumb/Music/v4/11/b7/3f/11b73fb0-46af-42b5-111a-6bce1815562f/source/100x100bb.jpg",
     artworkUrl60: "http://is4.mzstatic.com/image/thumb/Music/v4/11/b7/3f/11b73fb0-46af-42b5-111a-6bce1815562f/source/60x60bb.jpg",
     collectionCensoredName: "Red", collectionExplicitness: "notExplicit",
     collectionId: 571445253, collectionName: "Red", collectionPrice: 11.99,
     collectionType: "Album",
     collectionViewUrl: "https://itunes.apple.com/us/album/red/id571445253?uo=4",
     copyright: "℗ 2012 Big Machine Records, LLC.", country: "USA",
     currency: "USD", primaryGenreName: "Country",
     releaseDate: "2012-10-22T07:00:00Z", trackCount: 16,
     wrapperType: "collection"},
    %Itunes.Album{amgArtistId: 816977, artistId: 159260351,
     artistName: "Taylor Swift",
     artistViewUrl: "https://itunes.apple.com/us/artist/taylor-swift/id159260351?uo=4",
     artworkUrl100: "http://is2.mzstatic.com/image/thumb/Music/v4/ae/35/ac/ae35ac3b-5c14-818e-a54c-a1f73ef13c54/source/100x100bb.jpg",
     artworkUrl60: "http://is2.mzstatic.com/image/thumb/Music/v4/ae/35/ac/ae35ac3b-5c14-818e-a54c-a1f73ef13c54/source/60x60bb.jpg",
     collectionCensoredName: "Fearless", collectionExplicitness: "notExplicit",
     collectionId: 295757174, collectionName: "Fearless", collectionPrice: 7.99,
     collectionType: "Album",
     collectionViewUrl: "https://itunes.apple.com/us/album/fearless/id295757174?uo=4",
     copyright: "℗ 2008 Big Machine Records, LLC", country: "USA",
     currency: "USD", primaryGenreName: "Country",
     releaseDate: "2008-11-11T08:00:00Z", trackCount: 13,
     wrapperType: "collection"}]}
  ```

  ### Searching a different countries store
  ```
  iex(1)> Itunes.search_artists "西野カナ", 1, "jp"
  {:ok,
   [%Itunes.Artist{amgArtistId: nil, artistId: 410542403,
     artistLinkUrl: "https://itunes.apple.com/jp/artist/xi-yekana/id410542403?uo=4",
     artistName: "西野カナ", artistType: "Artist", primaryGenreId: 27,
     primaryGenreName: "J-Pop", wrapperType: "artist"}]}
  ```
  """

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

  Returns `{:ok, [t:Itunes.Song, ...]}`, `{:error, reason}`
  """
  def search_songs(query, limit \\ 10, store \\ "us") do
    search_and_parse(query, "song", Itunes.Song, limit, store)
  end

  @doc """
  Queries iTunes for albums for the given query.

  Note that the hard limit for iTunes is 200 results. More can not be returned.

  Returns `{:ok, [t:Itunes.Album, ...]}`, `{:error, reason}`
  """
  def search_albums(query, limit \\ 10, store \\ "us") do
    search_and_parse(query, "album", Itunes.Album, limit, store)
  end

  @doc """
  Queries iTunes for artists for the given query.

  Note that the hard limit for iTunes is 200 results. More can not be returned.

  Returns `{:ok, [t:Itunes.Artist, ...]}`, `{:error, reason}`
  """
  def search_artists(query, limit \\ 10, store \\ "us") do
    search_and_parse(query, "musicArtist", Itunes.Artist, limit, store)
  end

  @doc """
  Uses a iTunes lookup to get the artist information by id

  Returns `{:ok, t:Itunes.Artist}`, `{:error, reason}`

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

  Returns `{:ok, t:Itunes.Album}`, `{:error, reason}`

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

  Returns `{:ok, t:Itunes.Song}`, `{:error, reason}`

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

  Returns `{:ok, [t:Itunes.Song, ...]}`, `{:error, reason}`
  """
  def songs_by_id(id, limit \\ 10, store \\ "us") do
    lookup_and_parse(id, "song", Itunes.Song, limit, store)
  end

  @doc """
  Uses a iTunes lookup to get all songs for the given itunes album id.

  Note that the hard limit for iTunes is 200 results. More can not be returned.

  Returns `{:ok, [t:Itunes.Album, ...]}`, `{:error, reason}`
  """
  def albums_by_artist_id(id, limit \\ 10, store \\ "us") do
    lookup_and_parse(id, "album", Itunes.Album, limit, store)
  end
end
