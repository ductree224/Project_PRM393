using System.Text.Json.Serialization;

namespace Domain.Entities;

public class PaymentTransaction
{
    public Guid Id { get; set; }
    public Guid UserId { get; set; }
    public Guid? SubscriptionId { get; set; }
    public string? StripePaymentIntentId { get; set; }
    public string? StripeInvoiceId { get; set; }
    public decimal Amount { get; set; }
    public string Currency { get; set; } = "vnd";
    /// <summary>succeeded | failed | pending | refunded</summary>
    public string Status { get; set; } = string.Empty;
    public DateTime CreatedAt { get; set; }

    [JsonIgnore]
    public User User { get; set; } = null!;
    [JsonIgnore]
    public Subscription? Subscription { get; set; }
}
