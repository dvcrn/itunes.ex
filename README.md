# Itunes.ex

Elixir wrapper for the [iTunes affiliate search API](https://affiliate.itunes.apple.com/resources/documentation/itunes-store-web-service-search-api/). 

## Installation

  1. Add `itunes` to your list of dependencies in `mix.exs`:

    ```elixir
    def deps do
      [{:itunes, "~> 0.1.0"}]
    end
    ```

  2. Ensure `itunes` is started before your application:

    ```elixir
    def application do
      [applications: [:itunes]]
    end
    ```

## Usage

```
iex(1)> Itunes.search_artists "Taylor", 1
{:ok,
 [%Itunes.Album{amgArtistId: 816977, artistId: 159260351,
   artistName: "Taylor Swift", artistViewUrl: nil, artworkUrl100: nil,
   artworkUrl60: nil, collectionCensoredName: nil, collectionExplicitness: nil,
   collectionId: nil, collectionName: nil, collectionPrice: nil,
   collectionType: nil, collectionViewUrl: nil, copyright: nil, country: nil,
   currency: nil, primaryGenreName: "Pop", releaseDate: nil, trackCount: nil,
   wrapperType: "artist"}]}
```

## Limitations
- Currently only music-related APIs are implemented
- iTunes maximum result length is 200. Specifying anything over 200 will have no effect

## License 

MIT