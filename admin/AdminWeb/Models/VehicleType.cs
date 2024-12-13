using System.ComponentModel.DataAnnotations;
using Google.Cloud.Firestore;

namespace AdminWeb.Models
{
    [FirestoreData]

    public class VehicleType: IIdentifiable
    {
     

        [FirestoreProperty]
        public double baseFare { get; set; }
        [FirestoreProperty]
        public double fareFor10km { get; set; }
        [FirestoreProperty]
        public double fareFor5km { get; set; }
        [FirestoreProperty]
        public double farePerkm { get; set; }
        [FirestoreProperty]
        public double multiplier { get; set; }
        [FirestoreProperty]
        public string type { get; set; }

        public string? id { get; set; }=null;
    }
    
}
