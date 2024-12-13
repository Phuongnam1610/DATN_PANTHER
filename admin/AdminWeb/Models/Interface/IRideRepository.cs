using System.Linq.Expressions;

namespace AdminWeb.Models
{
    public interface IRideRepository: IRepository<Ride>
    {
        Task<IEnumerable<Ride>> getAllRide();
        Task<IEnumerable<Ride>> getRideByDriverId(string driverId);
    }
}