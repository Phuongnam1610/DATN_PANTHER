

using System.Collections.ObjectModel;
using System.Data.Common;
using AdminWeb.Models;
using Google.Cloud.Firestore;

class VoucherRepository(FirestoreDb db) : Repository<Voucher>(db,collectionName), IVoucherRepository
{
        private const string collectionName = "Voucher";


    public async Task<bool> AddVouchers(Voucher voucher)
    {
        QuerySnapshot snapshot = await collection.WhereEqualTo("code", voucher.code).GetSnapshotAsync(); 
        if (snapshot.Documents.Any())
        {
            throw new Exception("Mã voucher đã tồn tại");
        }
        else
        {
            // Add the voucher
            DocumentReference docRef = await collection.AddAsync(voucher);
            voucher.id = docRef.Id; // Update the voucher ID if your Voucher class has an Id property
           return true;
        }
    }

    
    public async Task<bool> EditVouchers(Voucher voucher,string oldcode)
    {
        if(oldcode != voucher.code){
            QuerySnapshot snapshot = await collection.WhereEqualTo("code", voucher.code).GetSnapshotAsync(); 
        if (snapshot.Documents.Any())
        {
            throw new Exception("Mã voucher đã tồn tại");
        }
            // Add the voucher
            await collection.Document(voucher.id).SetAsync(voucher); // Update the voucher ID if your Voucher class has an Id property
            return true;
        }
        else
        {
            // Add the voucher
            await collection.Document(voucher.id).SetAsync(voucher); // Update the voucher ID if your Voucher class has an Id property
            return true;
        }
    }

    public async Task<IEnumerable<Voucher>> GetAllAsync (string searchText, string discountTypeFilter, bool? isActiveFilter)
    {
        var collection = await GetAllAsync();
        if(searchText!="")
        {
            collection = collection.Where(x => x.discountType.Contains(searchText)||
            x.code.Contains(searchText) 
            || x.discountValue.ToString().Contains(searchText)
            || x.usageLimit.ToString().Contains(searchText)
            || x.usedCount.ToString().Contains(searchText)
            || x.validFrom.ToString("dd/MM/yyyy").Contains(searchText)
            || x.validUntil.ToString("dd/MM/yyyy").Contains(searchText));
        }
        if(discountTypeFilter!="")
        {
            collection = collection.Where(x => x.discountType == discountTypeFilter);
        }
        if(isActiveFilter!=null)
        {
            collection = collection.Where(x => x.IsActive == isActiveFilter);
        }
        return collection;
    }
}