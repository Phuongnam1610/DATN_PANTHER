

using System.Collections.ObjectModel;
using System.Data.Common;
using AdminWeb.Models;
using Google.Cloud.Firestore;

class DriverRepository(FirestoreDb db) : Repository<Driver>(db,collectionName), IDriverRepository
{
    
    private const string collectionName = "User";
    private readonly VehicleRepository vehicles=new VehicleRepository(db);
public async Task<IEnumerable<Driver>> GetAllDriverAsync (string searchText)
    {
        var users = await GetAllAsync();
        var drivers = users.Where(x => x.role == "driver");
        foreach (var driver in drivers)
        {
            driver.vehicle = await vehicles.GetByIdAsync(driver.vehicleOnId);
        }
        if(searchText!="")
        {
            drivers = drivers.Where(x => x.id.Contains(searchText)||
            x.name.Contains(searchText)||
            x.phoneNumber.Contains(searchText)||
            x.email.Contains(searchText)||            
            x.gender.Contains(searchText));
        }
        return drivers;
    }

    public async Task<Driver> GetDriverByIdAsync (string driverId)
    {
        var driver = await GetByIdAsync(driverId);
        driver.vehicle = await vehicles.GetByIdAsync(driver.vehicleOnId);
        
       
        return driver;
    }
}