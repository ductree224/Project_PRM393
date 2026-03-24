using Application.DTOs.Playlists;
using Application.Interfaces.Repositories;
using Domain.Entities;

namespace Application.Services;

public class WaitlistService
{
    private readonly IWaitlistRepository _waitlistRepository;

    public WaitlistService(IWaitlistRepository waitlistRepository)
    {
        _waitlistRepository = waitlistRepository;
    }

    // Lấy hoặc tự tạo Hàng đợi mới cho User
    public async Task<Waitlist> GetOrCreateUserWaitlistAsync(Guid userId)
    {
        var waitlist = await _waitlistRepository.GetWaitlistByUserIdAsync(userId);
        if (waitlist == null)
        {
            waitlist = new Waitlist { UserId = userId };
            waitlist = await _waitlistRepository.CreateWaitlistAsync(waitlist);
        }
        return waitlist;
    }

    public async Task AddTrackAsync(Guid userId, AddTrackToPlaylistRequest request)
    {
        var waitlist = await GetOrCreateUserWaitlistAsync(userId);

        // Tránh thêm trùng lặp bài hát
        if (waitlist.Tracks.Any(t => t.TrackExternalId == request.TrackExternalId))
            return;

        // Cho bài hát mới xếp vào cuối hàng
        var newPosition = waitlist.Tracks.Any() ? waitlist.Tracks.Max(t => t.Position) + 1 : 0;

        waitlist.Tracks.Add(new WaitlistTrack
        {
            WaitlistId = waitlist.Id,
            TrackExternalId = request.TrackExternalId,
            Position = newPosition,
            AddedAt = DateTime.UtcNow
        });

        await _waitlistRepository.UpdateWaitlistAsync(waitlist);
    }

    public async Task RemoveTrackAsync(Guid userId, string trackExternalId)
    {
        var waitlist = await _waitlistRepository.GetWaitlistByUserIdAsync(userId);
        if (waitlist == null) throw new KeyNotFoundException("Không tìm thấy hàng đợi.");

        var track = waitlist.Tracks.FirstOrDefault(t => t.TrackExternalId == trackExternalId);
        if (track == null) throw new KeyNotFoundException("Bài hát không có trong hàng đợi.");

        waitlist.Tracks.Remove(track);

        // Sắp xếp lại Position cho các bài hát còn lại để danh sách không bị lủng lỗ
        var orderedTracks = waitlist.Tracks.OrderBy(t => t.Position).ToList();
        for (int i = 0; i < orderedTracks.Count; i++)
        {
            orderedTracks[i].Position = i;
        }

        await _waitlistRepository.UpdateWaitlistAsync(waitlist);
    }

    // ĐÂY LÀ HÀM ĐÃ ĐƯỢC VIẾT LẠI CHUẨN THEO DTO CỦA ANH/CHỊ
    public async Task ReorderTracksAsync(Guid userId, ReorderTracksRequest request)
    {
        var waitlist = await _waitlistRepository.GetWaitlistByUserIdAsync(userId);
        if (waitlist == null) throw new KeyNotFoundException("Không tìm thấy hàng đợi.");

        if (request.TrackExternalIds == null || !request.TrackExternalIds.Any())
            return; // Nếu list rỗng thì không làm gì cả

        // Duyệt qua từng bài hát hiện có trong Database
        foreach (var track in waitlist.Tracks)
        {
            // Tìm vị trí mới của bài hát này trong cái mảng mà Frontend vừa gửi lên
            var newIndex = request.TrackExternalIds.IndexOf(track.TrackExternalId);

            if (newIndex != -1)
            {
                // Nếu tìm thấy, gán Position bằng đúng index của nó trong mảng Frontend gửi
                track.Position = newIndex;
            }
            else
            {
                // Phòng hờ Frontend gửi thiếu ID bài hát, ta đẩy bài bị thiếu đó xuống cuối cùng
                track.Position = request.TrackExternalIds.Count + track.Position;
            }
        }

        await _waitlistRepository.UpdateWaitlistAsync(waitlist);
    }

    public async Task ClearWaitlistAsync(Guid userId)
    {
        var waitlist = await _waitlistRepository.GetWaitlistByUserIdAsync(userId);
        if (waitlist != null)
        {
            await _waitlistRepository.ClearWaitlistTracksAsync(waitlist.Id);
        }
    }
}