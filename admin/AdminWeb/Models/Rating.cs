using System.ComponentModel.DataAnnotations;
using Google.Cloud.Firestore;

namespace AdminWeb.Models
{
    [FirestoreData]

    public class Rating : IIdentifiable
    {


        [FirestoreProperty]
        public string comment { get; set; }
        [FirestoreProperty]
        public Timestamp createdAt { get; set; }
        [FirestoreProperty]
        public string driverId { get; set; }
        [FirestoreProperty]
        public string rideId { get; set; }
        [FirestoreProperty]
        public int rating { get; set; }
        public string? id { get; set; } = null;

        public string dcreatedAt { get; set; }

        public DateTime getCreatedAt()
        {
            DateTimeOffset dto = createdAt.ToDateTimeOffset();
            return dto.DateTime;
        }
    }

}
