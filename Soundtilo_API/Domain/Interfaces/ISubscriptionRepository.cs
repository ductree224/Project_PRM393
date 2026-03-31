using Domain.Entities;

namespace Domain.Interfaces;

public interface ISubscriptionRepository
{
    Task<Subscription?> GetByUserIdAsync(Guid userId);
    Task<Subscription?> GetByStripeSubscriptionIdAsync(string stripeSubscriptionId);
    Task<Subscription> CreateAsync(Subscription subscription);
    Task UpdateAsync(Subscription subscription);
    Task<(IEnumerable<Subscription> Items, int Total)> GetAllAsync(
        int page = 1,
        int pageSize = 20,
        string? status = null);
    Task<int> CountPremiumUsersAsync();
    Task<IEnumerable<SubscriptionPlan>> GetActivePlansAsync();
}
