

using System.Collections.ObjectModel;
using System.Data.Common;
using AdminWeb.Models;
using Google.Cloud.Firestore;

class RideRepository(FirestoreDb db) : Repository<Ride>(db,collectionName), IRideRepository
{
    
    private const string collectionName = "Ride";
    private RatingRepository ratingRepository=new RatingRepository(db);

    public async Task<bool> AddRides(Ride ride)
    {
   
            DocumentReference docRef = await collection.AddAsync(ride);
            ride.id = docRef.Id; // Update the ride ID if your Ride class has an Id property
           return true;
    }

    
    public async Task<bool> EditRides(Ride ride)
    {

            await collection.Document(ride.id).SetAsync(ride); // Update the ride ID if your Ride class has an Id property
            return true;
        
    }

    public async Task<IEnumerable<Ride>> getAllRide ()
    {
        var rides = await GetAllAsync();
        foreach (var ride in rides)
        {
          if(ride.id!=null)
{
          Rating rating= await ratingRepository.GetByIdAsync(ride.id);
          if(rating!=null){
          ride.rating=rating.rating;}}
        }
        
        return rides;
    }

    public async Task<IEnumerable<Ride>> getRideByDriverId(string driverId)
    {
        Query query = collection.WhereEqualTo("driverId", driverId); // Assuming "driverId" is the field name in your Ride document
        QuerySnapshot snapshot = await query.GetSnapshotAsync();
        var rides= snapshot.Documents.Select(doc => doc.ConvertTo<Ride>());
        foreach (var ride in rides)
        {
          if(ride.id!=null){
          Rating rating= await ratingRepository.GetByIdAsync(ride.id);
          if(rating!=null){
          ride.rating=rating.rating;}}
        }
        return rides; 
    }
}