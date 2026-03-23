using Domain.Interfaces;
using Infrastructure.Data;
using Microsoft.EntityFrameworkCore;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Linq.Expressions;
using System.Text;
using System.Threading.Tasks;

namespace Infrastructure.Repositories;

public class GenericRepository<TEntity> : IGenericRepository<TEntity> where TEntity : class
{
    protected readonly SoundtiloDbContext _context;
    protected readonly DbSet<TEntity> _dbSet;

    public GenericRepository(SoundtiloDbContext context)
    {
        _context = context;
        _dbSet = context.Set<TEntity>();
    }

    public virtual async Task<TEntity?> GetByIdAsync(Guid id , CancellationToken cancellationToken = default)
    {
        return await _dbSet.FindAsync(new object[] { id } , cancellationToken);
    }

    public virtual async Task<IReadOnlyList<TEntity>> GetAllAsync(CancellationToken cancellationToken = default)
    {
        return await _dbSet.ToListAsync(cancellationToken);
    }

    public virtual async Task<IReadOnlyList<TEntity>> FindAsync(
        Expression<Func<TEntity , bool>> predicate ,
        CancellationToken cancellationToken = default)
    {
        return await _dbSet.Where(predicate).ToListAsync(cancellationToken);
    }

    public virtual async Task<bool> AnyAsync(
        Expression<Func<TEntity , bool>> predicate ,
        CancellationToken cancellationToken = default)
    {
        return await _dbSet.AnyAsync(predicate , cancellationToken);
    }

    public virtual async Task<int> CountAsync(
        Expression<Func<TEntity , bool>>? predicate = null ,
        CancellationToken cancellationToken = default)
    {
        if ( predicate is null )
        {
            return await _dbSet.CountAsync(cancellationToken);
        }

        return await _dbSet.CountAsync(predicate , cancellationToken);
    }

    public virtual async Task AddAsync(TEntity entity , CancellationToken cancellationToken = default)
    {
        await _dbSet.AddAsync(entity , cancellationToken);
    }

    public virtual async Task AddRangeAsync(IEnumerable<TEntity> entities , CancellationToken cancellationToken = default)
    {
        await _dbSet.AddRangeAsync(entities , cancellationToken);
    }

    public virtual void Update(TEntity entity)
    {
        _dbSet.Update(entity);
    }

    public virtual void Remove(TEntity entity)
    {
        _dbSet.Remove(entity);
    }

    public virtual void RemoveRange(IEnumerable<TEntity> entities)
    {
        _dbSet.RemoveRange(entities);
    }

    public virtual async Task<int> SaveChangesAsync(CancellationToken cancellationToken = default)
    {
        return await _context.SaveChangesAsync(cancellationToken);
    }
}
