namespace Application.DTOs.Subscriptions;

public record SubscriptionPlanDto(
    Guid Id,
    string Name,
    decimal Price,
    string Currency,
    string Interval,
    decimal? MonthlyEquivalent,
    bool IsActive
);

public record SubscriptionPlansResponse(
    IEnumerable<SubscriptionPlanDto> Plans
);

public record SubscriptionDto(
    Guid Id,
    Guid UserId,
    string Username,
    string PlanName,
    string Status,
    DateTime CurrentPeriodStart,
    DateTime CurrentPeriodEnd,
    DateTime? CancelledAt,
    DateTime CreatedAt
);

public record SubscriptionListResponse(
    IEnumerable<SubscriptionDto> Items,
    int Total,
    int Page,
    int PageSize,
    int TotalPages
);

public record PaymentTransactionDto(
    Guid Id,
    Guid UserId,
    string Username,
    Guid? SubscriptionId,
    string? StripePaymentIntentId,
    decimal Amount,
    string Currency,
    string Status,
    DateTime CreatedAt
);

public record PaymentTransactionListResponse(
    IEnumerable<PaymentTransactionDto> Items,
    int Total,
    int Page,
    int PageSize,
    int TotalPages
);
