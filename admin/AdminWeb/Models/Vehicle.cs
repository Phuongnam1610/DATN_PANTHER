using System.ComponentModel.DataAnnotations;
using Google.Cloud.Firestore;

namespace AdminWeb.Models
{
    [FirestoreData]

    public class Vehicle: IIdentifiable
    {
     

        [FirestoreProperty]
        public int capacity { get; set; }
        [FirestoreProperty]
        public string color { get; set; }
        [FirestoreProperty]
        public string driverId { get; set; }
        [FirestoreProperty]
        public string licensePlate { get; set; }
        [FirestoreProperty]
        public string model { get; set; }
        [FirestoreProperty]
        public string vehicleTypeId { get; set; }

        public string? id { get; set; }=null;
    }
    
}
