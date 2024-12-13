using System.Diagnostics;
using Microsoft.AspNetCore.Mvc;
using AdminWeb.Models;
using Google.Cloud.Firestore;
using Newtonsoft.Json;
using Microsoft.AspNetCore.Authorization;

namespace AdminWeb.Controllers;

[Authorize]
public class AdminController : Controller
{
    private readonly ILogger<HomeController> _logger;

    private readonly RideRepository rides;
    private readonly RatingRepository ratings;

    private readonly VehicleTypeRepository vehicleTypes;
    private readonly DriverRepository drivers;
    private readonly PaymentRepository payments;

    public AdminController(ILogger<HomeController> logger, FirestoreDb db)
    {
        _logger = logger;
        rides = new RideRepository(db);
        vehicleTypes = new VehicleTypeRepository(db);
        ratings = new RatingRepository(db);
        drivers = new DriverRepository(db);
        payments = new PaymentRepository(db);

    }

    public IActionResult Index()
    {
        return View();
    }

    public IActionResult Privacy()
    {
        return View();
    }

    [ResponseCache(Duration = 0, Location = ResponseCacheLocation.None, NoStore = true)]
    public IActionResult Error()
    {
        return View(new ErrorViewModel { RequestId = Activity.Current?.Id ?? HttpContext.TraceIdentifier });
    }



    public IActionResult DoanhThu()
    {
        ViewBag.TotalRevenue = 0;


        return View();
    }

    public IActionResult HieuSuat()
    {


        return View();
    }
    public IActionResult Payment()
    {


        return View();
    }

    [HttpPost]
    public async Task<IActionResult> GetPayment([FromBody] Dictionary<string, string> data) // Updated action method signature
    {
        string startDateStr = data["startDate"];
        string endDateStr = data["endDate"];

        // Chuyển đổi sang DateTime
        if (!DateTime.TryParse(startDateStr, out DateTime startDate) ||
            !DateTime.TryParse(endDateStr, out DateTime endDate))
        {
            return BadRequest("Invalid date format.");
        }


        // Kiểm tra rằng startDate nhỏ hơn endDate
        if (startDate > endDate)
        {
            return BadRequest("Start date must be less than or equal to end date.");
        }

        var listPayments = await payments.GetAllAsync();
        listPayments = listPayments.Where(c => c.getCreatedAt() >= startDate && c.getCreatedAt() <= endDate).ToList();
        var totalPayment = listPayments.Sum(c => c.amount);
        foreach (var payment in listPayments) { 
            payment.dcreatedAt=payment.getCreatedAt().ToString("dd/MM/yyyy HH:mm:ss");
        }
        string json = JsonConvert.SerializeObject(listPayments, new JsonSerializerSettings { ReferenceLoopHandling = ReferenceLoopHandling.Ignore });


        return Ok(Json(new { payments = json, totalPayment = totalPayment }));
    }



    [HttpPost]
    public async Task<IActionResult> GetRevenueData([FromBody] Dictionary<string, string> data) // Updated action method signature
    {
        string startDateStr = data["startDate"];
        string endDateStr = data["endDate"];
        
        // Chuyển đổi sang DateTime
        if (!DateTime.TryParse(startDateStr, out DateTime startDate) ||
            !DateTime.TryParse(endDateStr, out DateTime endDate))
        {
            return BadRequest("Invalid date format.");
        }


        // Kiểm tra rằng startDate nhỏ hơn endDate
        if (startDate > endDate)
        {
            return BadRequest("Start date must be less than or equal to end date.");
        }
        var listRides = await rides.getAllRide();

        listRides = listRides.Where(c => c.getCreatedAt() >= startDate && c.getCreatedAt() <= endDate).ToList();

        foreach (var ride in listRides)
        {
            ride.dcreatedAt = ride.getCreatedAt().ToString("dd/MM/yyyy HH:mm:ss"); ;
        }
        var listPayments = await payments.GetAllAsync();
        listPayments= listPayments.Where(c => c.getCreatedAt() >= startDate && c.getCreatedAt() <= endDate).ToList();
        var totalPayment = listPayments.Sum(c => c.amount);
        double totalRevenue = listRides.Sum(c => c.fareAmount);
        string json = JsonConvert.SerializeObject(listRides, new JsonSerializerSettings { ReferenceLoopHandling = ReferenceLoopHandling.Ignore });
        

        return Ok(Json(new { rides = json, totalRevenue = totalRevenue,totalPayment=totalPayment }));
    }


     [HttpPost]
    public async Task<IActionResult> GetDriverReport([FromBody] Dictionary<string, string> data) // Updated action method signature
    {
        string startDateStr = data["startDate"];
        string endDateStr = data["endDate"];

        // Chuyển đổi sang DateTime
        if (!DateTime.TryParse(startDateStr, out DateTime startDate) ||
            !DateTime.TryParse(endDateStr, out DateTime endDate))
        {
            return BadRequest("Invalid date format.");
        }


        // Kiểm tra rằng startDate nhỏ hơn endDate
        if (startDate > endDate)
        {
            return BadRequest("Start date must be less than or equal to end date.");
        }
        var listDrivers = await drivers.GetAllDriverAsync("");
        var driverReports=new List<PerformanceViewModel>();
      
        foreach (var driver in listDrivers)
        {   var listRides = await rides.getRideByDriverId(driver.id);
            listRides = listRides.Where(c => c.getCreatedAt() >= startDate && c.getCreatedAt() <= endDate).ToList();
            PerformanceViewModel performance = new PerformanceViewModel();
            performance.name = driver.name;
            performance.email = driver.email;
            performance.phone = driver.phoneNumber;
            performance.totalRevenue = listRides.Sum(c => c.fareAmount);
            performance.rating = driver.rating;
            performance.tripCount = listRides.Count();
            performance.earning = driver.earning;
            performance.vehicleType = driver.vehicle.vehicleTypeId;
            performance.model = driver.vehicle.model;
            performance.rating = driver.rating;
            performance.id=driver.id;
            driverReports.Add(performance);
        }

        string json = JsonConvert.SerializeObject(driverReports, new JsonSerializerSettings { ReferenceLoopHandling = ReferenceLoopHandling.Ignore });

        return Ok(Json(new { reports = json }));
    }
  
  


}
