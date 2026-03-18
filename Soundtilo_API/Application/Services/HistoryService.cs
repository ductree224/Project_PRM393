using Application.DTOs.History;
using Domain.Entities;
using Domain.Interfaces;

namespace Application.Services;

public class HistoryService
{
    private readonly IHistoryRepository _historyRepository;

    public HistoryService(IHistoryRepository historyRepository)
    {
        _historyRepository = historyRepository;
    }

    public async Task<HistoryListResponse> GetHistoryAsync(Guid userId, int page = 1, int pageSize = 20)
    {
        var history = await _historyRepository.GetByUserIdAsync(userId, page, pageSize);
        var totalListens = await _historyRepository.GetTotalListensAsync(userId);
        var totalTime = await _historyRepository.GetTotalListeningTimeAsync(userId);

        return new HistoryListResponse(
            History: history.Select(h => new HistoryDto(
                Id: h.Id,
                TrackExternalId: h.TrackExternalId,
                ListenedAt: h.ListenedAt,
                DurationListened: h.DurationListened,
                Completed: h.Completed
            )),
            TotalListens: totalListens,
            TotalListeningTimeSeconds: totalTime
        );
    }

    public async Task RecordListenAsync(Guid userId, RecordListenRequest request)
    {
        await _historyRepository.AddAsync(new ListeningHistory
        {
            Id = Guid.NewGuid(),
            UserId = userId,
            TrackExternalId = request.TrackExternalId,
            ListenedAt = DateTime.UtcNow,
            DurationListened = request.DurationListened,
            Completed = request.Completed
        });
    }

    public Task<int> DeleteHistoryAsync(Guid userId, IReadOnlyCollection<Guid> historyIds)
    {
        return _historyRepository.DeleteByIdsAsync(userId, historyIds);
    }
}
