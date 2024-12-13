

using System.Collections.ObjectModel;
using System.Data.Common;
using AdminWeb.Models;
using Google.Cloud.Firestore;

class PaymentRepository(FirestoreDb db) : Repository<Payment>(db,collectionName), IPaymentRepository
{
    
    private const string collectionName = "Payment";

}