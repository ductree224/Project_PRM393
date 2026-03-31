using Domain.Entities;

namespace Domain.Interfaces;

public interface ISubscriptionRepository
{
    Task<Subscription?> GetByUserIdAsync(Guid userId);
    Task<Subscription?> GetByVnpayOrderInfoAsync(string vnpayOrderInfo);
    Task<Subscription> CreateAsync(Subscription subscription);
    Task UpdateAsync(Subscription subscription);
    Task<(IEnumerable<Subscription> Items, int Total)> GetAllAsync(
        int page = 1,
        int pageSize = 20,
        string? status = null);
    Task<int> CountPremiumUsersAsync();
    Task<IEnumerable<SubscriptionPlan>> GetActivePlansAsync();
    Task<IEnumerable<Subscription>> GetExpiringSubscriptionsAsync(DateTime from, DateTime to);
    Task<int> GetExpiringCountAsync(DateTime before);
    Task<Subscription?> GetByIdAsync(Guid id);
}
