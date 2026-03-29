using System.Text.Json.Serialization;

namespace Domain.Entities;

public class SubscriptionPlan
{
    public Guid Id { get; set; }
    public string Name { get; set; } = string.Empty;
    public decimal Price { get; set; }
    public string Interval { get; set; } = string.Empty; // free / monthly / yearly
    public string? StripePriceId { get; set; }
    public string Currency { get; set; } = "vnd";
    public bool IsActive { get; set; } = true;
    public DateTime CreatedAt { get; set; }

    [JsonIgnore]
    public ICollection<Subscription> Subscriptions { get; set; } = new List<Subscription>();
}
