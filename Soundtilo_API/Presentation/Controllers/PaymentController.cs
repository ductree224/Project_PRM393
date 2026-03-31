using System.IdentityModel.Tokens.Jwt;
using System.Security.Claims;
using Application.DTOs.Subscriptions;
using Application.Services;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;

namespace Presentation.Controllers;

/// <summary>
/// User-facing payment endpoints for VNPay integration.
/// </summary>
[ApiController]
[Route("api/payment")]
public class PaymentController : ControllerBase
{
    private readonly SubscriptionService _subscriptionService;

    public PaymentController(SubscriptionService subscriptionService)
    {
        _subscriptionService = subscriptionService;
    }

    private Guid GetUserId() =>
        Guid.Parse(User.FindFirstValue(JwtRegisteredClaimNames.Sub)
            ?? User.FindFirstValue(ClaimTypes.NameIdentifier)
            ?? throw new UnauthorizedAccessException());

    /// <summary>
    /// POST /api/payment/create-payment-url
    /// Creates a VNPay payment URL. Flutter opens this in a WebView.
    /// </summary>
    [HttpPost("create-payment-url")]
    [Authorize]
    public async Task<IActionResult> CreatePaymentUrl([FromBody] CreatePaymentRequest request)
    {
        try
        {
            var userId = GetUserId();
            var ipAddress = HttpContext.Connection.RemoteIpAddress?.ToString() ?? "127.0.0.1";

            var result = await _subscriptionService.CreatePaymentUrlAsync(userId, request.PlanId, ipAddress);
            return Ok(result);
        }
        catch (ArgumentException ex)
        {
            return BadRequest(new { message = ex.Message });
        }
    }

    /// <summary>
    /// GET /api/payment/vnpay-return?vnp_...
    /// VNPay redirects here after payment. Returns JSON for Flutter WebView to capture.
    /// </summary>
    [HttpGet("vnpay-return")]
    [AllowAnonymous]
    public async Task<IActionResult> VnPayReturn()
    {
        var vnpParams = Request.Query
            .ToDictionary(kv => kv.Key, kv => kv.Value.ToString());

        var result = await _subscriptionService.ProcessVnpayReturnAsync(vnpParams);
        return Ok(result);
    }

    /// <summary>
    /// GET /api/payment/vnpay-ipn?vnp_...
    /// VNPay server-to-server IPN callback. Must return {"RspCode":"00","Message":"..."}.
    /// </summary>
    [HttpGet("vnpay-ipn")]
    [AllowAnonymous]
    public async Task<IActionResult> VnPayIpn()
    {
        var vnpParams = Request.Query
            .ToDictionary(kv => kv.Key, kv => kv.Value.ToString());

        var (rspCode, message) = await _subscriptionService.ProcessVnpayIpnAsync(vnpParams);
        return Ok(new { RspCode = rspCode, Message = message });
    }

    /// <summary>
    /// GET /api/payment/subscription-status
    /// Returns the current user's subscription status.
    /// </summary>
    [HttpGet("subscription-status")]
    [Authorize]
    public async Task<IActionResult> GetSubscriptionStatus()
    {
        try
        {
            var userId = GetUserId();
            var result = await _subscriptionService.GetUserSubscriptionAsync(userId);
            return Ok(result);
        }
        catch (ArgumentException ex)
        {
            return NotFound(new { message = ex.Message });
        }
    }

    /// <summary>
    /// DELETE /api/payment/subscription — soft cancel (keeps active until period end)
    /// </summary>
    [HttpDelete("subscription")]
    [Authorize]
    public async Task<IActionResult> CancelSubscription()
    {
        try
        {
            await _subscriptionService.CancelSubscriptionAsync(GetUserId());
            return Ok(new { message = "Đã hủy đăng ký. Gói Premium vẫn có hiệu lực đến hết kỳ thanh toán." });
        }
        catch (KeyNotFoundException ex) { return NotFound(new { message = ex.Message }); }
        catch (InvalidOperationException ex) { return Conflict(new { message = ex.Message }); }
    }
}
