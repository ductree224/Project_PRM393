using Domain.Entities;

namespace Domain.Interfaces;

public interface IAdminAuditLogRepository
{
    Task AddAsync(AdminAuditLog log);
    Task<IEnumerable<AdminAuditLog>> GetByAdminIdAsync(Guid adminId, int page = 1, int pageSize = 20);
}
