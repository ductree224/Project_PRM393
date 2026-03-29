using Application.DTOs.Subscriptions;
using Domain.Entities;
using Domain.Interfaces;

namespace Application.Services;

/// <summary>
/// Handles subscription lifecycle — admin management and Stripe webhook processing.
/// Stripe integration: add the Stripe.net NuGet package to Infrastructure.csproj
/// and inject StripeClient here when implementing checkout sessions.
/// </summary>
public class SubscriptionService
{
    private readonly ISubscriptionRepository _subscriptionRepository;
    private readonly IPaymentTransactionRepository _paymentTransactionRepository;
    private readonly IUserRepository _userRepository;

    public SubscriptionService(
        ISubscriptionRepository subscriptionRepository,
        IPaymentTransactionRepository paymentTransactionRepository,
        IUserRepository userRepository)
    {
        _subscriptionRepository = subscriptionRepository;
        _paymentTransactionRepository = paymentTransactionRepository;
        _userRepository = userRepository;
    }

    public async Task<SubscriptionListResponse> GetSubscriptionsAsync(
        int page = 1,
        int pageSize = 20,
        string? status = null)
    {
        var safePage = Math.Max(page, 1);
        var safePageSize = Math.Clamp(pageSize, 1, 100);

        var (items, total) = await _subscriptionRepository.GetAllAsync(safePage, safePageSize, status);
        var totalPages = (int)Math.Ceiling((double)total / safePageSize);

        return new SubscriptionListResponse(
            items.Select(s => new SubscriptionDto(
                s.Id,
                s.UserId,
                s.User?.Username ?? string.Empty,
                s.Plan?.Name ?? string.Empty,
                s.Status,
                s.CurrentPeriodStart,
                s.CurrentPeriodEnd,
                s.CancelledAt,
                s.CreatedAt)),
            total,
            safePage,
            safePageSize,
            totalPages);
    }

    public async Task<PaymentTransactionListResponse> GetTransactionsAsync(
        int page = 1,
        int pageSize = 20,
        Guid? userId = null)
    {
        var safePage = Math.Max(page, 1);
        var safePageSize = Math.Clamp(pageSize, 1, 100);

        var (items, total) = await _paymentTransactionRepository.GetAllAsync(safePage, safePageSize, userId);
        var totalPages = (int)Math.Ceiling((double)total / safePageSize);

        return new PaymentTransactionListResponse(
            items.Select(t => new PaymentTransactionDto(
                t.Id,
                t.UserId,
                t.User?.Username ?? string.Empty,
                t.SubscriptionId,
                t.StripePaymentIntentId,
                t.Amount,
                t.Currency,
                t.Status,
                t.CreatedAt)),
            total,
            safePage,
            safePageSize,
            totalPages);
    }

    /// <summary>
    /// Called by Stripe webhook handler when a payment succeeds.
    /// Updates user subscription tier automatically.
    /// </summary>
    public async Task HandleStripePaymentSucceededAsync(
        string stripeSubscriptionId,
        string stripePaymentIntentId,
        decimal amount,
        string currency,
        DateTime periodEnd)
    {
        var sub = await _subscriptionRepository.GetByStripeSubscriptionIdAsync(stripeSubscriptionId);
        if (sub is null)
            return;

        var user = await _userRepository.GetByIdAsync(sub.UserId);
        if (user is null)
            return;

        user.SubscriptionTier = "premium";
        user.PremiumExpiresAt = periodEnd;
        user.UpdatedAt = DateTime.UtcNow;
        await _userRepository.UpdateAsync(user);

        sub.Status = "active";
        sub.CurrentPeriodEnd = periodEnd;
        await _subscriptionRepository.UpdateAsync(sub);

        await _paymentTransactionRepository.CreateAsync(new PaymentTransaction
        {
            Id = Guid.NewGuid(),
            UserId = user.Id,
            SubscriptionId = sub.Id,
            StripePaymentIntentId = stripePaymentIntentId,
            Amount = amount,
            Currency = currency,
            Status = "succeeded",
            CreatedAt = DateTime.UtcNow
        });
    }

    /// <summary>
    /// Called by Stripe webhook when a subscription is cancelled or expires.
    /// </summary>
    public async Task HandleStripeSubscriptionEndedAsync(string stripeSubscriptionId)
    {
        var sub = await _subscriptionRepository.GetByStripeSubscriptionIdAsync(stripeSubscriptionId);
        if (sub is null)
            return;

        var user = await _userRepository.GetByIdAsync(sub.UserId);
        if (user is not null)
        {
            user.SubscriptionTier = "free";
            user.PremiumExpiresAt = null;
            user.UpdatedAt = DateTime.UtcNow;
            await _userRepository.UpdateAsync(user);
        }

        sub.Status = "cancelled";
        sub.CancelledAt = DateTime.UtcNow;
        await _subscriptionRepository.UpdateAsync(sub);
    }

    /// <summary>
    /// Returns all active subscription plans sorted by price (free first, then monthly, yearly).
    /// Used by the public /api/subscriptions/plans endpoint — no auth required.
    /// </summary>
    public async Task<SubscriptionPlansResponse> GetPlansAsync()
    {
        var plans = await _subscriptionRepository.GetActivePlansAsync();
        return new SubscriptionPlansResponse(
            plans.Select(p => new SubscriptionPlanDto(
                p.Id,
                p.Name,
                p.Price,
                p.Currency,
                p.Interval,
                // Monthly equivalent: for yearly plans show per-month cost so Flutter can show savings
                p.Interval == "yearly" ? Math.Round(p.Price / 12, 0) : null,
                p.IsActive))
        );
    }
}
