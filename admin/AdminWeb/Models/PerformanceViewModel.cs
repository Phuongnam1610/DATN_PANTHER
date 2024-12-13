using System.ComponentModel.DataAnnotations;

namespace AdminWeb.Models
{
    public class PerformanceViewModel:IIdentifiable
    {
        public string? name { get; set; }
        public string? email { get; set; }
        public string? phone { get; set; }
        public double? totalRevenue { get; set; }   
        public double? rating { get; set; }
     public int? tripCount { get; set; }
        public double? earning { get; set; }
        public string? vehicleType { get; set; }
        public string? model { get; set; }
        public string id { get; set; }
    }
}
