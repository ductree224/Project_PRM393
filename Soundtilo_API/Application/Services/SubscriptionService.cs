using System.Globalization;
using System.Net;
using System.Security.Cryptography;
using System.Text;
using Application.DTOs.Subscriptions;
using Domain.Entities;
using Domain.Interfaces;
using Microsoft.Extensions.Configuration;

namespace Application.Services;

/// <summary>
/// Handles subscription lifecycle — VNPay payment creation, IPN processing, and admin views.
/// </summary>
public class SubscriptionService
{
    private readonly ISubscriptionRepository _subscriptionRepository;
    private readonly IPaymentTransactionRepository _paymentTransactionRepository;
    private readonly IUserRepository _userRepository;
    private readonly IConfiguration _configuration;

    public SubscriptionService(
        ISubscriptionRepository subscriptionRepository,
        IPaymentTransactionRepository paymentTransactionRepository,
        IUserRepository userRepository,
        IConfiguration configuration)
    {
        _subscriptionRepository = subscriptionRepository;
        _paymentTransactionRepository = paymentTransactionRepository;
        _userRepository = userRepository;
        _configuration = configuration;
    }

    // ==================== USER-FACING ====================

    /// <summary>
    /// Creates a VNPay payment URL for the given plan.
    /// The Flutter app opens this URL in a WebView.
    /// </summary>
    public async Task<CreatePaymentResponse> CreatePaymentUrlAsync(Guid userId, Guid planId, string clientIpAddress)
    {
        var plans = await _subscriptionRepository.GetActivePlansAsync();
        var plan = plans.FirstOrDefault(p => p.Id == planId)
            ?? throw new ArgumentException("Gói đăng ký không tồn tại hoặc đã ngừng hoạt động.");

        if (plan.Interval == "free")
            throw new ArgumentException("Gói miễn phí không cần thanh toán.");

        var vnpay = _configuration.GetSection("VnPay");
        var tmnCode = vnpay["TmnCode"] ?? throw new InvalidOperationException("VnPay:TmnCode not configured");
        var hashSecret = vnpay["HashSecret"] ?? throw new InvalidOperationException("VnPay:HashSecret not configured");
        var paymentUrl = vnpay["PaymentUrl"] ?? "https://sandbox.vnpayment.vn/paymentv2/vpcpay.html";
        var returnUrl = vnpay["ReturnUrl"] ?? "http://localhost:5196/api/payment/vnpay-return";
        var version = vnpay["Version"] ?? "2.1.0";
        var command = vnpay["Command"] ?? "pay";
        var currCode = vnpay["CurrCode"] ?? "VND";
        var locale = vnpay["Locale"] ?? "vn";
        var orderType = vnpay["OrderType"] ?? "other";

        // Unique transaction reference: timestamp + random suffix
        var txnRef = DateTime.UtcNow.ToString("yyyyMMddHHmmss") + "_" + Guid.NewGuid().ToString("N")[..8];

        // VNPay amount is in VND × 100 (smallest currency unit)
        var amount = (long)(plan.Price * 100);

        var orderInfo = $"Soundtilo Premium - {plan.Name} - User:{userId}";

        // Create pending transaction
        await _paymentTransactionRepository.CreateAsync(new PaymentTransaction
        {
            Id = Guid.NewGuid(),
            UserId = userId,
            VnpTxnRef = txnRef,
            Amount = plan.Price,
            Currency = "vnd",
            Status = "pending",
            CreatedAt = DateTime.UtcNow
        });

        // Build VNPay query params (sorted alphabetically)
        var vnpParams = new SortedDictionary<string, string>
        {
            ["vnp_Version"] = version,
            ["vnp_Command"] = command,
            ["vnp_TmnCode"] = tmnCode,
            ["vnp_Amount"] = amount.ToString(),
            ["vnp_CreateDate"] = DateTime.UtcNow.AddHours(7).ToString("yyyyMMddHHmmss"), // Vietnam timezone
            ["vnp_CurrCode"] = currCode,
            ["vnp_IpAddr"] = clientIpAddress,
            ["vnp_Locale"] = locale,
            ["vnp_OrderInfo"] = orderInfo,
            ["vnp_OrderType"] = orderType,
            ["vnp_ReturnUrl"] = returnUrl,
            ["vnp_TxnRef"] = txnRef,
            ["vnp_ExpireDate"] = DateTime.UtcNow.AddHours(7).AddMinutes(15).ToString("yyyyMMddHHmmss")
        };

        // Build hash data and query string
        var hashData = new StringBuilder();
        var query = new StringBuilder();
        foreach (var kv in vnpParams)
        {
            if (hashData.Length > 0)
            {
                hashData.Append('&');
                query.Append('&');
            }
            hashData.Append(kv.Key).Append('=').Append(kv.Value);
            query.Append(WebUtility.UrlEncode(kv.Key)).Append('=').Append(WebUtility.UrlEncode(kv.Value));
        }

        var secureHash = HmacSha512(hashSecret, hashData.ToString());
        var fullUrl = $"{paymentUrl}?{query}&vnp_SecureHash={secureHash}";

        return new CreatePaymentResponse(fullUrl, txnRef);
    }

    /// <summary>
    /// Processes VNPay IPN callback. Called by VNPay servers.
    /// </summary>
    public async Task<(string RspCode, string Message)> ProcessVnpayIpnAsync(IDictionary<string, string> vnpParams)
    {
        var hashSecret = _configuration["VnPay:HashSecret"]
            ?? throw new InvalidOperationException("VnPay:HashSecret not configured");

        // Extract and remove secure hash from params
        vnpParams.TryGetValue("vnp_SecureHash", out var receivedHash);
        var paramsToHash = new SortedDictionary<string, string>(
            vnpParams.Where(kv => kv.Key != "vnp_SecureHash" && kv.Key != "vnp_SecureHashType")
                     .ToDictionary(kv => kv.Key, kv => kv.Value));

        var hashData = string.Join("&", paramsToHash.Select(kv => $"{kv.Key}={kv.Value}"));
        var computedHash = HmacSha512(hashSecret, hashData);

        if (!string.Equals(computedHash, receivedHash, StringComparison.OrdinalIgnoreCase))
            return ("97", "Invalid checksum");

        var txnRef = vnpParams.TryGetValue("vnp_TxnRef", out var txnRefVal) ? txnRefVal : "";
        var responseCode = vnpParams.TryGetValue("vnp_ResponseCode", out var rcVal) ? rcVal : "";
        var transactionNo = vnpParams.TryGetValue("vnp_TransactionNo", out var tnVal) ? tnVal : "";
        var amountStr = vnpParams.TryGetValue("vnp_Amount", out var amtVal) ? amtVal : "0";

        var transaction = await _paymentTransactionRepository.GetByVnpTxnRefAsync(txnRef);
        if (transaction is null)
            return ("01", "Order not found");

        if (transaction.Status == "succeeded")
            return ("02", "Order already confirmed");

        // VNPay amount is ×100
        var vnpAmount = long.Parse(amountStr) / 100m;
        if (vnpAmount != transaction.Amount)
            return ("04", "Invalid amount");

        transaction.VnpTransactionNo = transactionNo;
        transaction.VnpResponseCode = responseCode;

        if (responseCode == "00")
        {
            transaction.Status = "succeeded";
            await _paymentTransactionRepository.UpdateAsync(transaction);

            // Activate subscription
            await ActivateSubscriptionAsync(transaction);
            return ("00", "Confirm Success");
        }
        else
        {
            transaction.Status = "failed";
            await _paymentTransactionRepository.UpdateAsync(transaction);
            return ("00", "Confirm Success");
        }
    }

    /// <summary>
    /// Handles VNPay return URL redirect. Returns result for Flutter.
    /// </summary>
    public async Task<PaymentResultResponse> ProcessVnpayReturnAsync(IDictionary<string, string> vnpParams)
    {
        var hashSecret = _configuration["VnPay:HashSecret"]
            ?? throw new InvalidOperationException("VnPay:HashSecret not configured");

        vnpParams.TryGetValue("vnp_SecureHash", out var receivedHash);
        var paramsToHash = new SortedDictionary<string, string>(
            vnpParams.Where(kv => kv.Key != "vnp_SecureHash" && kv.Key != "vnp_SecureHashType")
                     .ToDictionary(kv => kv.Key, kv => kv.Value));

        var hashData = string.Join("&", paramsToHash.Select(kv => $"{kv.Key}={kv.Value}"));
        var computedHash = HmacSha512(hashSecret, hashData);

        var txnRef = vnpParams.TryGetValue("vnp_TxnRef", out var txnRefRet) ? txnRefRet : "";
        var responseCode = vnpParams.TryGetValue("vnp_ResponseCode", out var rcRet) ? rcRet : "";

        if (!string.Equals(computedHash, receivedHash, StringComparison.OrdinalIgnoreCase))
            return new PaymentResultResponse(false, "Chữ ký không hợp lệ", txnRef, null, null);

        var transaction = await _paymentTransactionRepository.GetByVnpTxnRefAsync(txnRef);
        if (transaction is null)
            return new PaymentResultResponse(false, "Giao dịch không tìm thấy", txnRef, null, null);

        if (responseCode == "00")
        {
            // If IPN hasn't processed yet, activate now
            if (transaction.Status == "pending")
            {
                transaction.VnpTransactionNo = vnpParams.TryGetValue("vnp_TransactionNo", out var tnVal2) ? tnVal2 : null;
                transaction.VnpResponseCode = responseCode;
                transaction.Status = "succeeded";
                await _paymentTransactionRepository.UpdateAsync(transaction);
                await ActivateSubscriptionAsync(transaction);
            }

            var user = await _userRepository.GetByIdAsync(transaction.UserId);
            return new PaymentResultResponse(
                true,
                "Thanh toán thành công! Bạn đã trở thành Premium.",
                txnRef,
                user?.SubscriptionTier,
                user?.PremiumExpiresAt);
        }

        return new PaymentResultResponse(false, $"Thanh toán thất bại (Mã lỗi: {responseCode})", txnRef, null, null);
    }

    /// <summary>Gets the current user's subscription status</summary>
    public async Task<UserSubscriptionStatusResponse> GetUserSubscriptionAsync(Guid userId)
    {
        var user = await _userRepository.GetByIdAsync(userId)
            ?? throw new ArgumentException("Người dùng không tồn tại.");

        var sub = await _subscriptionRepository.GetByUserIdAsync(userId);

        bool isPremium = user.SubscriptionTier == "premium"
            && (user.PremiumExpiresAt == null || user.PremiumExpiresAt > DateTime.UtcNow);

        return new UserSubscriptionStatusResponse(
            user.SubscriptionTier,
            user.PremiumExpiresAt,
            isPremium,
            sub?.Plan?.Name,
            sub?.Plan?.Interval,
            sub?.CurrentPeriodEnd);
    }

    // ==================== ADMIN ====================

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
                t.VnpTxnRef,
                t.Amount,
                t.Currency,
                t.Status,
                t.CreatedAt)),
            total,
            safePage,
            safePageSize,
            totalPages);
    }

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
                p.Interval == "yearly" ? Math.Round(p.Price / 12, 0) : null,
                p.IsActive))
        );
    }

    public async Task<SubscriptionDetailDto?> GetSubscriptionByIdAsync(Guid id)
    {
        var sub = await _subscriptionRepository.GetByIdAsync(id);
        if (sub is null) return null;

        return new SubscriptionDetailDto(
            sub.Id,
            sub.UserId,
            sub.User?.Username ?? string.Empty,
            sub.User?.Email,
            sub.Plan?.Name ?? string.Empty,
            sub.Plan?.Price ?? 0,
            sub.Plan?.Interval ?? string.Empty,
            sub.Status,
            sub.CurrentPeriodStart,
            sub.CurrentPeriodEnd,
            sub.CancelledAt,
            sub.CreatedAt,
            sub.PaymentTransactions?.Select(t => new PaymentTransactionDto(
                t.Id,
                t.UserId,
                sub.User?.Username ?? string.Empty,
                t.SubscriptionId,
                t.VnpTxnRef,
                t.Amount,
                t.Currency,
                t.Status,
                t.CreatedAt)) ?? Enumerable.Empty<PaymentTransactionDto>());
    }

    public async Task<SubscriptionStatsDto> GetSubscriptionStatsAsync()
    {
        var (allSubs, totalSubs) = await _subscriptionRepository.GetAllAsync(1, 1, "active");
        var totalActive = totalSubs;
        var expiringCount = await _subscriptionRepository.GetExpiringCountAsync(DateTime.UtcNow.AddDays(10));
        var totalRevenue = await _paymentTransactionRepository.GetTotalRevenueAsync();
        var (_, totalTransactions) = await _paymentTransactionRepository.GetAllAsync(1, 1);

        return new SubscriptionStatsDto(totalActive, expiringCount, totalRevenue, totalTransactions);
    }

    public async Task<SubscriptionListResponse> GetExpiringSubscriptionsAsync(
        int daysAhead = 10,
        int page = 1,
        int pageSize = 20)
    {
        var now = DateTime.UtcNow;
        var cutoff = now.AddDays(daysAhead);
        var expiringAll = await _subscriptionRepository.GetExpiringSubscriptionsAsync(now, cutoff);
        var total = expiringAll.Count();

        var safePage = Math.Max(page, 1);
        var safePageSize = Math.Clamp(pageSize, 1, 100);
        var totalPages = (int)Math.Ceiling((double)total / safePageSize);

        var items = expiringAll
            .OrderBy(s => s.CurrentPeriodEnd)
            .Skip((safePage - 1) * safePageSize)
            .Take(safePageSize)
            .Select(s => new SubscriptionDto(
                s.Id,
                s.UserId,
                s.User?.Username ?? string.Empty,
                s.Plan?.Name ?? string.Empty,
                s.Status,
                s.CurrentPeriodStart,
                s.CurrentPeriodEnd,
                s.CancelledAt,
                s.CreatedAt));

        return new SubscriptionListResponse(items, total, safePage, safePageSize, totalPages);
    }

    // ==================== PRIVATE HELPERS ====================

    private async Task ActivateSubscriptionAsync(PaymentTransaction transaction)
    {
        var user = await _userRepository.GetByIdAsync(transaction.UserId);
        if (user is null) return;

        // Determine plan from amount
        var plans = await _subscriptionRepository.GetActivePlansAsync();
        var plan = plans.FirstOrDefault(p => p.Price == transaction.Amount && p.Interval != "free");
        if (plan is null) return;

        var now = DateTime.UtcNow;
        var periodEnd = plan.Interval == "yearly"
            ? now.AddYears(1)
            : now.AddMonths(1);

        // Update or create subscription
        var existingSub = await _subscriptionRepository.GetByUserIdAsync(user.Id);
        if (existingSub is not null)
        {
            // Extend if still active, or restart
            var newEnd = existingSub.Status == "active" && existingSub.CurrentPeriodEnd > now
                ? (plan.Interval == "yearly"
                    ? existingSub.CurrentPeriodEnd.AddYears(1)
                    : existingSub.CurrentPeriodEnd.AddMonths(1))
                : periodEnd;

            existingSub.PlanId = plan.Id;
            existingSub.Status = "active";
            existingSub.CurrentPeriodStart = now;
            existingSub.CurrentPeriodEnd = newEnd;
            existingSub.VnpayOrderInfo = transaction.VnpTxnRef;
            existingSub.CancelledAt = null;
            await _subscriptionRepository.UpdateAsync(existingSub);

            transaction.SubscriptionId = existingSub.Id;
            await _paymentTransactionRepository.UpdateAsync(transaction);

            periodEnd = newEnd;
        }
        else
        {
            var newSub = new Subscription
            {
                Id = Guid.NewGuid(),
                UserId = user.Id,
                PlanId = plan.Id,
                VnpayOrderInfo = transaction.VnpTxnRef,
                Status = "active",
                CurrentPeriodStart = now,
                CurrentPeriodEnd = periodEnd,
                CreatedAt = now
            };
            var created = await _subscriptionRepository.CreateAsync(newSub);
            transaction.SubscriptionId = created.Id;
            await _paymentTransactionRepository.UpdateAsync(transaction);
        }

        // Upgrade user
        user.SubscriptionTier = "premium";
        user.PremiumExpiresAt = periodEnd;
        user.UpdatedAt = now;
        await _userRepository.UpdateAsync(user);
    }

    private static string HmacSha512(string key, string data)
    {
        using var hmac = new HMACSHA512(Encoding.UTF8.GetBytes(key));
        var hash = hmac.ComputeHash(Encoding.UTF8.GetBytes(data));
        return BitConverter.ToString(hash).Replace("-", "").ToLowerInvariant();
    }
}
