using System.ComponentModel.DataAnnotations;
using Google.Cloud.Firestore;

namespace AdminWeb.Models
{
    [FirestoreData]

    public class User: IIdentifiable
    {
     

        [FirestoreProperty]
        public string email { get; set; }
        [FirestoreProperty]
        public string imageUrl { get; set; }
        [FirestoreProperty]
        public string name { get; set; }
        [FirestoreProperty]
        public string phoneNumber { get; set; }
        [FirestoreProperty]
        public string role { get; set; }
        [FirestoreProperty]
        public string gender { get; set; }
        // [FirestoreProperty]
        // public Timestamp createdAt { get; set; }
        
        public string? id { get; set; }=null;
    }
    
}
