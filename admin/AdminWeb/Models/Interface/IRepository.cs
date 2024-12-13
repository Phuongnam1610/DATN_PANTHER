using System.Linq.Expressions;

namespace AdminWeb.Models
{
    public interface IRepository<T> where T: class
    {
    Task<IEnumerable<T>> GetAllAsync();
    Task<T> GetByIdAsync(string id);
    Task AddAsync(T model);
    Task UpdateAsync(string id, T model);
    Task DeleteAsync(string id);
        
    }
}