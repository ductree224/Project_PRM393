using Domain.Entities;
using Domain.Interfaces;
using Infrastructure.Data;
using Microsoft.EntityFrameworkCore;

namespace Infrastructure.Repositories;

public class SubscriptionRepository : ISubscriptionRepository
{
    private readonly SoundtiloDbContext _context;

    public SubscriptionRepository(SoundtiloDbContext context)
    {
        _context = context;
    }

    public async Task<Subscription?> GetByUserIdAsync(Guid userId)
    {
        return await _context.Subscriptions
            .Include(s => s.Plan)
            .FirstOrDefaultAsync(s => s.UserId == userId);
    }

    public async Task<Subscription?> GetByVnpayOrderInfoAsync(string vnpayOrderInfo)
    {
        return await _context.Subscriptions
            .Include(s => s.Plan)
            .FirstOrDefaultAsync(s => s.VnpayOrderInfo == vnpayOrderInfo);
    }

    public async Task<Subscription> CreateAsync(Subscription subscription)
    {
        _context.Subscriptions.Add(subscription);
        await _context.SaveChangesAsync();
        return subscription;
    }

    public async Task UpdateAsync(Subscription subscription)
    {
        _context.Subscriptions.Update(subscription);
        await _context.SaveChangesAsync();
    }

    public async Task<(IEnumerable<Subscription> Items, int Total)> GetAllAsync(
        int page = 1,
        int pageSize = 20,
        string? status = null)
    {
        var safePage = Math.Max(page, 1);
        var safePageSize = Math.Clamp(pageSize, 1, 100);

        var query = _context.Subscriptions
            .Include(s => s.User)
            .Include(s => s.Plan)
            .AsQueryable();

        if (!string.IsNullOrWhiteSpace(status))
            query = query.Where(s => s.Status == status);

        var total = await query.CountAsync();
        var items = await query
            .OrderByDescending(s => s.CreatedAt)
            .Skip((safePage - 1) * safePageSize)
            .Take(safePageSize)
            .ToListAsync();

        return (items, total);
    }

    public async Task<int> CountPremiumUsersAsync()
    {
        return await _context.Users.CountAsync(u => u.SubscriptionTier == "premium");
    }

    public async Task<IEnumerable<SubscriptionPlan>> GetActivePlansAsync()
    {
        return await _context.SubscriptionPlans
            .Where(p => p.IsActive)
            .OrderBy(p => p.Price)
            .ToListAsync();
    }

    public async Task<IEnumerable<Subscription>> GetExpiringSubscriptionsAsync(DateTime from, DateTime to)
    {
        return await _context.Subscriptions
            .Include(s => s.User)
            .Include(s => s.Plan)
            .Where(s => s.Status == "active" && s.CurrentPeriodEnd >= from && s.CurrentPeriodEnd <= to)
            .ToListAsync();
    }

    public async Task<int> GetExpiringCountAsync(DateTime before)
    {
        return await _context.Subscriptions
            .CountAsync(s => s.Status == "active" && s.CurrentPeriodEnd <= before);
    }

    public async Task<Subscription?> GetByIdAsync(Guid id)
    {
        return await _context.Subscriptions
            .Include(s => s.User)
            .Include(s => s.Plan)
            .Include(s => s.PaymentTransactions)
            .FirstOrDefaultAsync(s => s.Id == id);
    }
}
