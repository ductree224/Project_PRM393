using Application.Interfaces.Repositories;
using Domain.Entities;
using Infrastructure.Data;
using Microsoft.EntityFrameworkCore;

namespace Infrastructure.Repositories;

public class WaitlistRepository : IWaitlistRepository
{
    private readonly SoundtiloDbContext _context;

    public WaitlistRepository(SoundtiloDbContext context)
    {
        _context = context;
    }

    public async Task<Waitlist?> GetWaitlistByUserIdAsync(Guid userId)
    {
        // Phải Include(w => w.Tracks) để lấy luôn danh sách bài hát bên trong
        return await _context.Waitlists
            .Include(w => w.Tracks)
            .FirstOrDefaultAsync(w => w.UserId == userId);
    }

    public async Task<Waitlist> CreateWaitlistAsync(Waitlist waitlist)
    {
        _context.Waitlists.Add(waitlist);
        await _context.SaveChangesAsync();
        return waitlist;
    }

    public async Task UpdateWaitlistAsync(Waitlist waitlist)
    {
        _context.Waitlists.Update(waitlist);
        await _context.SaveChangesAsync();
    }

    public async Task ClearWaitlistTracksAsync(Guid waitlistId)
    {
        var tracks = await _context.WaitlistTracks.Where(wt => wt.WaitlistId == waitlistId).ToListAsync();
        if (tracks.Any())
        {
            _context.WaitlistTracks.RemoveRange(tracks);
            await _context.SaveChangesAsync();
        }
    }
}