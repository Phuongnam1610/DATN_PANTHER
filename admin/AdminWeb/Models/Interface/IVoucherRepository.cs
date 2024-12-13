using System.Linq.Expressions;

namespace AdminWeb.Models
{
    public interface IVoucherRepository: IRepository<Voucher>
    {
        Task<IEnumerable<Voucher>> GetAllAsync(string searchText, string discountTypeFilter, bool? isActiveFilter);
         Task<bool> AddVouchers(Voucher voucher);
        Task<bool> EditVouchers(Voucher voucher,string oldcode);
    }
}