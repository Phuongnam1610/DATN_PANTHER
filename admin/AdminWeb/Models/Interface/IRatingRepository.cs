using System.Linq.Expressions;

namespace AdminWeb.Models
{
    public interface IRatingRepository: IRepository<Rating>
    {
                Task<IEnumerable<Rating>> getRatingByDriverId(string driverId);
    }
}