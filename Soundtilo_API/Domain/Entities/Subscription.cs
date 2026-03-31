using System.Text.Json.Serialization;

namespace Domain.Entities;

public class Subscription
{
    public Guid Id { get; set; }
    public Guid UserId { get; set; }
    public Guid PlanId { get; set; }
    public string? VnpayOrderInfo { get; set; }
    /// <summary>active | cancelled | past_due | trialing | manually_granted</summary>
    public string Status { get; set; } = "active";
    public DateTime CurrentPeriodStart { get; set; }
    public DateTime CurrentPeriodEnd { get; set; }
    public DateTime? CancelledAt { get; set; }
    public DateTime CreatedAt { get; set; }

    [JsonIgnore]
    public User User { get; set; } = null!;
    [JsonIgnore]
    public SubscriptionPlan Plan { get; set; } = null!;
    [JsonIgnore]
    public ICollection<PaymentTransaction> PaymentTransactions { get; set; } = new List<PaymentTransaction>();
}
