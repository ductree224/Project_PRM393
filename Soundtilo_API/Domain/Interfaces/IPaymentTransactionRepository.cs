using Domain.Entities;

namespace Domain.Interfaces;

public interface IPaymentTransactionRepository
{
    Task<PaymentTransaction> CreateAsync(PaymentTransaction transaction);
    Task<PaymentTransaction?> GetByVnpTxnRefAsync(string vnpTxnRef);
    Task UpdateAsync(PaymentTransaction transaction);
    Task<(IEnumerable<PaymentTransaction> Items, int Total)> GetAllAsync(
        int page = 1,
        int pageSize = 20,
        Guid? userId = null);
    Task<decimal> GetTotalRevenueAsync();
}
