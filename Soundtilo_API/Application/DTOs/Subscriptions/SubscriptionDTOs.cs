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
    string? VnpTxnRef,
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

/// <summary>Request from Flutter to create a VNPay payment URL</summary>
public record CreatePaymentRequest(
    Guid PlanId
);

/// <summary>Response containing the VNPay payment URL to open in WebView</summary>
public record CreatePaymentResponse(
    string PaymentUrl,
    string TxnRef
);

/// <summary>Returned to Flutter after VNPay redirects back</summary>
public record PaymentResultResponse(
    bool Success,
    string Message,
    string? TxnRef,
    string? SubscriptionTier,
    DateTime? PremiumExpiresAt
);

/// <summary>Current user's subscription status</summary>
public record UserSubscriptionStatusResponse(
    string SubscriptionTier,
    DateTime? PremiumExpiresAt,
    bool IsPremium,
    string? PlanName,
    string? PlanInterval,
    DateTime? CurrentPeriodEnd,
    bool IsCancelled
);

/// <summary>Admin: subscription detail with user info and payment history</summary>
public record SubscriptionDetailDto(
    Guid Id,
    Guid UserId,
    string Username,
    string? Email,
    string PlanName,
    decimal PlanPrice,
    string PlanInterval,
    string Status,
    DateTime CurrentPeriodStart,
    DateTime CurrentPeriodEnd,
    DateTime? CancelledAt,
    DateTime CreatedAt,
    IEnumerable<PaymentTransactionDto> Transactions
);

/// <summary>Admin: subscription stats summary</summary>
public record SubscriptionStatsDto(
    int TotalActive,
    int TotalExpiringSoon,
    decimal TotalRevenue,
    int TotalTransactions
);
