using System.ComponentModel.DataAnnotations;
using Google.Cloud.Firestore;

namespace AdminWeb.Models
{
    [FirestoreData]

    public class Prompt: IIdentifiable
    {
     

        [FirestoreProperty]
        public string question { get; set; }
        [FirestoreProperty]
        public string responses { get; set; }
       
        public string? id { get; set; }=null;
    }
    
}
