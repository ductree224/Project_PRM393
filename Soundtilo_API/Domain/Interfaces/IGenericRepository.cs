using System;
using System.Collections.Generic;
using System.Linq;
using System.Linq.Expressions;
using System.Text;
using System.Threading.Tasks;

namespace Domain.Interfaces;

public interface IGenericRepository<TEntity> where TEntity : class
{
    Task<TEntity?> GetByIdAsync(Guid id , CancellationToken cancellationToken = default);
    Task<IReadOnlyList<TEntity>> GetAllAsync(CancellationToken cancellationToken = default);
    Task<IReadOnlyList<TEntity>> FindAsync(
        Expression<Func<TEntity , bool>> predicate ,
        CancellationToken cancellationToken = default);

    Task<bool> AnyAsync(
        Expression<Func<TEntity , bool>> predicate ,
        CancellationToken cancellationToken = default);

    Task<int> CountAsync(
        Expression<Func<TEntity , bool>>? predicate = null ,
        CancellationToken cancellationToken = default);

    Task AddAsync(TEntity entity , CancellationToken cancellationToken = default);
    Task AddRangeAsync(IEnumerable<TEntity> entities , CancellationToken cancellationToken = default);

    void Update(TEntity entity);
    void Remove(TEntity entity);
    void RemoveRange(IEnumerable<TEntity> entities);

    Task<int> SaveChangesAsync(CancellationToken cancellationToken = default);
}
