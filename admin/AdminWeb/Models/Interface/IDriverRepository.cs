using System.Linq.Expressions;

namespace AdminWeb.Models
{
    public interface IDriverRepository: IRepository<Driver>
    {
                Task<IEnumerable<Driver>> GetAllDriverAsync(string searchText);
 Task<Driver> GetDriverByIdAsync (string driverId);

    }
}