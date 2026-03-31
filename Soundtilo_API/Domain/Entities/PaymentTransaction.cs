using System.Text.Json.Serialization;

namespace Domain.Entities;

public class PaymentTransaction
{
    public Guid Id { get; set; }
    public Guid UserId { get; set; }
    public Guid? SubscriptionId { get; set; }
    /// <summary>Unique reference sent to VNPay (vnp_TxnRef)</summary>
    public string VnpTxnRef { get; set; } = string.Empty;
    /// <summary>Transaction number returned by VNPay (vnp_TransactionNo)</summary>
    public string? VnpTransactionNo { get; set; }
    /// <summary>VNPay response code (vnp_ResponseCode): 00 = success</summary>
    public string? VnpResponseCode { get; set; }
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
