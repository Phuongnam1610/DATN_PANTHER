

using System.Collections.ObjectModel;
using System.Data.Common;
using AdminWeb.Models;
using Google.Cloud.Firestore;

class VehicleTypeRepository(FirestoreDb db) : Repository<VehicleType>(db,collectionName), IVehicleTypeRepository
{
    
    private const string collectionName = "VehicleType";


}