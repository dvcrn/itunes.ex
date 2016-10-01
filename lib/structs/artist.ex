defmodule Itunes.Artist do
  @moduledoc """
  Itunes.Artist represents a artist-based search result from iTunes.

  ```
  defstruct
    amgArtistId: nil,
    artistId: nil,
    artistLinkUrl: nil,
    artistName: nil,
    artistType: nil,
    primaryGenreId: nil,
    primaryGenreName: nil,
    wrapperType: nil
  ```
  """

  defstruct \
    amgArtistId: nil, \
    artistId: nil, \
    artistLinkUrl: nil, \
    artistName: nil, \
    artistType: nil, \
    primaryGenreId: nil, \
    primaryGenreName: nil, \
    wrapperType: nil
end
