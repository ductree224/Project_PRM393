using Domain.Entities;
using Domain.Interfaces;
using Infrastructure.Data;
using Microsoft.EntityFrameworkCore;

namespace Infrastructure.Repositories;

public class PasswordResetTokenRepository : IPasswordResetTokenRepository
{
    private readonly SoundtiloDbContext _context;

    public PasswordResetTokenRepository(SoundtiloDbContext context)
    {
        _context = context;
    }

    public async Task<PasswordResetToken?> GetByTokenAsync(string token)
    {
        return await _context.PasswordResetTokens
            .Include(prt => prt.User)
            .FirstOrDefaultAsync(prt => prt.Token == token);
    }

    public async Task<PasswordResetToken> CreateAsync(PasswordResetToken passwordResetToken)
    {
        _context.PasswordResetTokens.Add(passwordResetToken);
        await _context.SaveChangesAsync();
        return passwordResetToken;
    }

    public async Task MarkAsUsedAsync(string token)
    {
        var passwordResetToken = await _context.PasswordResetTokens
            .FirstOrDefaultAsync(prt => prt.Token == token);
        if (passwordResetToken != null)
        {
            passwordResetToken.UsedAt = DateTime.UtcNow;
            await _context.SaveChangesAsync();
        }
    }

    public async Task MarkAllAsUsedByUserIdAsync(Guid userId)
    {
        var tokens = await _context.PasswordResetTokens
            .Where(prt => prt.UserId == userId && prt.UsedAt == null)
            .ToListAsync();

        foreach (var token in tokens)
        {
            token.UsedAt = DateTime.UtcNow;
        }

        await _context.SaveChangesAsync();
    }
}
