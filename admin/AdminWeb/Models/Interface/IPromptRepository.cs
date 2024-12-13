using System.Linq.Expressions;

namespace AdminWeb.Models
{
    public interface IPromptRepository: IRepository<Prompt>
    {
        Task<IEnumerable<Prompt>> GetAllAsync(string searchText);
        Task<bool> AddPrompts(Prompt voucher);
        Task<bool> EditPrompts(Prompt voucher);
    }
}