using System.ComponentModel.DataAnnotations;
using Google.Cloud.Firestore;

namespace AdminWeb.Models
{
    [FirestoreData]

    public class Driver: User
    {
     

        [FirestoreProperty]
        public string status { get; set; }
        [FirestoreProperty]
        public string vehicleOnId { get; set; }
        [FirestoreProperty]
        public bool verify { get; set; }
        [FirestoreProperty]
        public bool banned { get; set; }
         [FirestoreProperty]
        public double earning { get; set; }
         [FirestoreProperty]
        public bool weeklyFeeStatus { get; set; }
           [FirestoreProperty]
        public double rating { get; set; }
        [FirestoreProperty]
        public Location? location { get; set; }
        public Vehicle vehicle { get; set; }



    }

    [FirestoreData] // Optional: Add this if you want to store Location as a separate document.
    public class Location
    {
        [FirestoreProperty]
        public double latitude { get; set; }
        [FirestoreProperty]
        public double longitude { get; set; }
    }
    
}
