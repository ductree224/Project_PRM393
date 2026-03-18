namespace Application.DTOs.Lyrics;

public record LyricsDto(
    string Artist,
    string Title,
    string? Lyrics
);
