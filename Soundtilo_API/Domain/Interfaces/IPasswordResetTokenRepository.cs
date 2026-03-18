using Domain.Entities;

namespace Domain.Interfaces;

public interface IPasswordResetTokenRepository
{
    Task<PasswordResetToken?> GetByTokenAsync(string token);
    Task<PasswordResetToken> CreateAsync(PasswordResetToken passwordResetToken);
    Task MarkAsUsedAsync(string token);
    Task MarkAllAsUsedByUserIdAsync(Guid userId);
}
