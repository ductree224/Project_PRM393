using System;
using Domain.Entities;
using Domain.Interfaces;
using Infrastructure.Data;
using Microsoft.EntityFrameworkCore;

namespace Infrastructure.Repositories;

public class UserRepository : IUserRepository
{
    private readonly SoundtiloDbContext _context;

    public UserRepository(SoundtiloDbContext context)
    {
        _context = context;
    }

    public async Task<User?> GetByIdAsync(Guid id)
    {
        return await _context.Users.FindAsync(id);
    }

    public async Task<User?> GetByUsernameAsync(string username)
    {
        return await _context.Users.FirstOrDefaultAsync(u => u.Username == username);
    }

    public async Task<User?> GetByEmailAsync(string email)
    {
        return await _context.Users.FirstOrDefaultAsync(u => u.Email == email);
    }

    public async Task<User?> GetByUsernameOrEmailAsync(string usernameOrEmail)
    {
        return await _context.Users.FirstOrDefaultAsync(u =>
            u.Username == usernameOrEmail || u.Email == usernameOrEmail);
    }

    public async Task<User> CreateAsync(User user)
    {
        // Ensure timestamps are UTC
        user.CreatedAt = EnsureUtc(user.CreatedAt == default ? DateTime.UtcNow : user.CreatedAt);
        user.UpdatedAt = EnsureUtc(user.UpdatedAt == default ? DateTime.UtcNow : user.UpdatedAt);
        user.BannedAt = EnsureUtcNullable(user.BannedAt);
        user.PremiumExpiresAt = EnsureUtcNullable(user.PremiumExpiresAt);
        user.Birthday = EnsureUtcNullable(user.Birthday);

        _context.Users.Add(user);
        await _context.SaveChangesAsync();
        return user;
    }

    public async Task UpdateAsync(User user)
    {
        // Update timestamp and normalize all DateTime kinds to UTC to satisfy Npgsql
        user.UpdatedAt = DateTime.UtcNow;
        user.CreatedAt = EnsureUtc(user.CreatedAt);
        user.BannedAt = EnsureUtcNullable(user.BannedAt);
        user.PremiumExpiresAt = EnsureUtcNullable(user.PremiumExpiresAt);
        user.Birthday = EnsureUtcNullable(user.Birthday);

        _context.Users.Update(user);
        await _context.SaveChangesAsync();
    }

    private static DateTime EnsureUtc(DateTime value)
    {
        if (value.Kind == DateTimeKind.Utc) return value;
        if (value.Kind == DateTimeKind.Local) return value.ToUniversalTime();
        // Unspecified -> treat as UTC
        return DateTime.SpecifyKind(value, DateTimeKind.Utc);
    }

    private static DateTime? EnsureUtcNullable(DateTime? value)
    {
        if (!value.HasValue) return null;
        return EnsureUtc(value.Value);
    }

    public async Task DeleteAsync(User user)
    {
        _context.Users.Remove(user);
        await _context.SaveChangesAsync();
    }

    public async Task<(IEnumerable<User> Users, int Total)> GetAllAsync(
        int page = 1,
        int pageSize = 20,
        string? search = null,
        string? role = null,
        bool? isBanned = null,
        string? subscriptionTier = null)
    {
        var safePage = Math.Max(page, 1);
        var safePageSize = Math.Clamp(pageSize, 1, 100);

        var query = _context.Users.AsQueryable();

        if (!string.IsNullOrWhiteSpace(search))
        {
            var normalized = search.Trim().ToLower();
            query = query.Where(u =>
                u.Username.ToLower().Contains(normalized) ||
                u.Email.ToLower().Contains(normalized) ||
                (u.DisplayName != null && u.DisplayName.ToLower().Contains(normalized)));
        }

        if (!string.IsNullOrWhiteSpace(role))
            query = query.Where(u => u.Role == role);

        if (isBanned.HasValue)
            query = query.Where(u => u.IsBanned == isBanned.Value);

        if (!string.IsNullOrWhiteSpace(subscriptionTier))
            query = query.Where(u => u.SubscriptionTier == subscriptionTier);

        var total = await query.CountAsync();
        var users = await query
            .OrderByDescending(u => u.CreatedAt)
            .Skip((safePage - 1) * safePageSize)
            .Take(safePageSize)
            .ToListAsync();

        return (users, total);
    }

    public async Task<int> CountAsync()
    {
        return await _context.Users.CountAsync();
    }
}
