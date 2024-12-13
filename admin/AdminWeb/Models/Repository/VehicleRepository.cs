

using System.Collections.ObjectModel;
using System.Data.Common;
using AdminWeb.Models;
using Google.Cloud.Firestore;

class VehicleRepository(FirestoreDb db) : Repository<Vehicle>(db,collectionName), IVehicleRepository
{
    
    private const string collectionName = "Vehicle";
}