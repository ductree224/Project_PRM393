using Domain.Entities;
using Domain.Interfaces;
using Infrastructure.Data;
using Microsoft.EntityFrameworkCore;

namespace Infrastructure.Repositories;

public class PaymentTransactionRepository : IPaymentTransactionRepository
{
    private readonly SoundtiloDbContext _context;

    public PaymentTransactionRepository(SoundtiloDbContext context)
    {
        _context = context;
    }

    public async Task<PaymentTransaction> CreateAsync(PaymentTransaction transaction)
    {
        _context.PaymentTransactions.Add(transaction);
        await _context.SaveChangesAsync();
        return transaction;
    }

    public async Task<(IEnumerable<PaymentTransaction> Items, int Total)> GetAllAsync(
        int page = 1,
        int pageSize = 20,
        Guid? userId = null)
    {
        var safePage = Math.Max(page, 1);
        var safePageSize = Math.Clamp(pageSize, 1, 100);

        var query = _context.PaymentTransactions
            .Include(t => t.User)
            .AsQueryable();

        if (userId.HasValue)
            query = query.Where(t => t.UserId == userId.Value);

        var total = await query.CountAsync();
        var items = await query
            .OrderByDescending(t => t.CreatedAt)
            .Skip((safePage - 1) * safePageSize)
            .Take(safePageSize)
            .ToListAsync();

        return (items, total);
    }

    public async Task<decimal> GetTotalRevenueAsync()
    {
        return await _context.PaymentTransactions
            .Where(t => t.Status == "succeeded")
            .SumAsync(t => t.Amount);
    }
}
