using System.ComponentModel.DataAnnotations;
using Google.Cloud.Firestore;

namespace AdminWeb.Models
{
    [FirestoreData]

    public class Ride: IIdentifiable
    {
     
    [FirestoreProperty]
        public string status   { get; set; }
        [FirestoreProperty]
        public Timestamp createdAt { get; set; }
        [FirestoreProperty]
        public string driverId { get; set; }
        [FirestoreProperty]
        public string customerId { get; set; }
        [FirestoreProperty]
        public string dropoffAddress { get; set; }
        [FirestoreProperty]
        public string pickupAddress { get; set; }
        [FirestoreProperty]
        public double fareAmount { get; set; }
        [FirestoreProperty]
        public double voucherFare{ get; set; }
        [FirestoreProperty]
        public Location pickupLocation { get; set; }
        [FirestoreProperty]
        public Location dropoffLocation { get; set; }
        [FirestoreProperty]
        public string distance { get; set; }

        [FirestoreProperty]
        public string car_details { get; set; }
        public string id { get; set; }

        public int rating { get; set; }

        public string dcreatedAt { get; set; }

        public DateTime getCreatedAt()
        {
            DateTimeOffset dto = createdAt.ToDateTimeOffset();
            return dto.DateTime;
        }

    }
  
}
