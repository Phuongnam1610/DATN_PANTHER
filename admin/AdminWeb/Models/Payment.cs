using System.ComponentModel.DataAnnotations;
using Google.Cloud.Firestore;

namespace AdminWeb.Models
{
    [FirestoreData]

    public class Payment:IIdentifiable
    {
     

        [FirestoreProperty]
        public double amount { get; set; }
        [FirestoreProperty]
        public Timestamp createdAt { get; set; }
        [FirestoreProperty]
        public string driverId { get; set; }
        [FirestoreProperty]
        public Int64 oderCode { get; set; }
        public string id { get; set; }
        
        public string dcreatedAt { get; set; }
        public DateTime getCreatedAt()
        {
            DateTimeOffset dto = createdAt.ToDateTimeOffset();
            return dto.DateTime;
        }
    }


  
}
