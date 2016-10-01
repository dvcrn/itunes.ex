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
 [%Itunes.Artist{amgArtistId: 816977, artistId: 159260351,
   artistLinkUrl: "https://itunes.apple.com/us/artist/taylor-swift/id159260351?uo=4",
   artistName: "Taylor Swift", artistType: "Artist", primaryGenreId: 14,
   primaryGenreName: "Pop", wrapperType: "artist"}]}
```

Check out the [API Docs](https://hexdocs.pm/itunes/api-reference.html) for more examples on how to use this.

## Limitations
- Currently only music-related APIs are implemented
- iTunes maximum result length is 200. Specifying anything over 200 will have no effect

## License 

MIT
