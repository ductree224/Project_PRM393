using Domain.Entities;

namespace Application.Interfaces.Repositories;

public interface IWaitlistRepository
{
    Task<Waitlist?> GetWaitlistByUserIdAsync(Guid userId);
    Task<Waitlist> CreateWaitlistAsync(Waitlist waitlist);
    Task UpdateWaitlistAsync(Waitlist waitlist);
    Task ClearWaitlistTracksAsync(Guid waitlistId);
}