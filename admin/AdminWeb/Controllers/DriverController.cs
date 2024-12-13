using System.Diagnostics;
using Microsoft.AspNetCore.Mvc;
using AdminWeb.Models;
using Google.Cloud.Firestore;
using Newtonsoft.Json;
using Microsoft.AspNetCore.Authorization;

namespace AdminWeb.Controllers;

[Authorize]
public class DriverController : Controller
{
    private readonly ILogger<HomeController> _logger;

    private readonly DriverRepository drivers;
    private readonly RatingRepository ratings;
    private readonly VehicleRepository vehicles;

    public DriverController(ILogger<HomeController> logger,FirestoreDb db)
    {
        _logger = logger;
        drivers = new DriverRepository(db);
        vehicles = new VehicleRepository(db);
        ratings=new  RatingRepository(db);
    }

    public IActionResult Index()
    {
        return View();
    }

    public IActionResult Privacy()
    {
        return View();
    }public async Task<IActionResult> Rating(string id)
{
    var listrating = await ratings.getRatingByDriverId(id);
    listrating = listrating.Select(rating => {
        rating.dcreatedAt = rating.getCreatedAt().ToString("dd/MM/yyyy HH:mm:ss");
        return rating;
    }).ToList();
    return View(listrating);
}
    [ResponseCache(Duration = 0, Location = ResponseCacheLocation.None, NoStore = true)]
    public IActionResult Error()
    {
        return View(new ErrorViewModel { RequestId = Activity.Current?.Id ?? HttpContext.TraceIdentifier });
    }

     public async Task<IActionResult> GetDrivers(string searchText = "")
    {
        // Retrieve all cars from the database
        var listsDrivers = await drivers.GetAllDriverAsync(searchText);

        // Serialize the cars to JSON format
        return Json(listsDrivers);
    }

        public async Task<IActionResult> Edit(string id)
    {

        var driver = await drivers.GetDriverByIdAsync(id);
        ViewBag.Action = "Edit";
        return View(driver);
    }

    [HttpPost]
    [ValidateAntiForgeryToken]

    public async Task<IActionResult> Edit(Driver driver)
    {
        ViewBag.Action = "Edit";

        if (ModelState.IsValid)
        {

            try
            {
                await drivers.UpdateAsync(driver.id, driver);
                await vehicles.UpdateAsync(driver.vehicleOnId, driver.vehicle);
            }
            catch (Exception ex)
            {
                ModelState.AddModelError("Driver", ex.Message);
                return View(driver);
            }

            return RedirectToAction(nameof(Index));

        }

        return View(driver);
    }

      

}
