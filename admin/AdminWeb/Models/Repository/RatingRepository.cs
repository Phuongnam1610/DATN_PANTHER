

using System.Collections.ObjectModel;
using System.Data.Common;
using AdminWeb.Models;
using Google.Cloud.Firestore;

class RatingRepository(FirestoreDb db) : Repository<Rating>(db,collectionName), IRatingRepository
{
        private const string collectionName = "Rating";

    public async Task<IEnumerable<Rating>> getRatingByDriverId(string driverId)
    {
          Query query = collection.WhereEqualTo("driverId", driverId); // Assuming "driverId" is the field name in your Ride document
        QuerySnapshot snapshot = await query.GetSnapshotAsync();
        
  var ratings = snapshot.Documents.Select(doc => 
    {
        Rating rating = doc.ConvertTo<Rating>();
        rating.id = doc.Id; // Assign the document ID to the rating.id property
        return rating;
    });        
    
        return ratings; 
    }
}