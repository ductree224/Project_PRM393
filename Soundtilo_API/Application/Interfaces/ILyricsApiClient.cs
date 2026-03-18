namespace Application.Interfaces;

/// <summary>
/// Interface for lyrics API client
/// Primary: lyrics.ovh (free, no API key needed)
/// GET https://api.lyrics.ovh/v1/{artist}/{title}
/// </summary>
public interface ILyricsApiClient
{
    Task<string?> GetLyricsAsync(string artist, string title);
}
