using Application.DTOs.Lyrics;
using Application.Interfaces;

namespace Application.Services;

public class LyricsService
{
    private readonly ILyricsApiClient _lyricsApi;

    public LyricsService(ILyricsApiClient lyricsApi)
    {
        _lyricsApi = lyricsApi;
    }

    public async Task<LyricsDto> GetLyricsAsync(string artist, string title)
    {
        var lyrics = await _lyricsApi.GetLyricsAsync(artist, title);

        return new LyricsDto(
            Artist: artist,
            Title: title,
            Lyrics: lyrics
        );
    }
}
