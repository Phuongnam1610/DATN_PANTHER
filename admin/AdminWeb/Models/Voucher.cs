using System;
using System.ComponentModel.DataAnnotations;
using System.Runtime.Serialization;
using Google.Cloud.Firestore;

namespace AdminWeb.Models
{
    [FirestoreData]
    public class Voucher : IIdentifiable
    {

        [FirestoreProperty]
        [Required(ErrorMessage = "Code is required.")]
        [StringLength(50, ErrorMessage = "Code cannot exceed 50 characters.")]
        public string? code { get; set; }

        [FirestoreProperty]
        [Required(ErrorMessage = "Discount type is required.")]
        public string? discountType { get; set; }

        [FirestoreProperty]
        [Range(0, double.MaxValue, ErrorMessage = "Discount value must be a positive number.")]
        public double discountValue { get; set; }

        [FirestoreProperty]
        [Range(1, int.MaxValue, ErrorMessage = "Usage limit must be at least 1.")]
        public int usageLimit { get; set; }

        [FirestoreProperty]
        [Range(0, int.MaxValue, ErrorMessage = "Used count cannot be negative.")]
        public int usedCount { get; set; }

         private DateTime _validFrom;
        [FirestoreProperty]
        public DateTime validFrom
        {
            get => _validFrom;
            set => _validFrom = DateTime.SpecifyKind(value, DateTimeKind.Utc);
        }

        private DateTime _validUntil;
        [FirestoreProperty]
        public DateTime validUntil
        {
            get => _validUntil;
            set => _validUntil = DateTime.SpecifyKind(value, DateTimeKind.Utc);
        }

        public string validFromString => validFrom.ToString("dd-MM-yyyy");
        public string validUntilString => validUntil.ToString("dd-MM-yyyy");

        [IgnoreDataMember]
        public bool IsActive
        {
            get
            {
                DateTime now = DateTime.UtcNow;
             

                return now >= validFrom && now <= validUntil && usedCount < usageLimit;
            }
        }

        public string? id { get; set; }
    }
}