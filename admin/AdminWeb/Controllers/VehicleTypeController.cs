using System.Net;
using System.Security.Claims;
using System.Text.Json;
using AdminWeb.Models;
using Google.Cloud.Firestore;
using Microsoft.AspNetCore.Authentication;
using Microsoft.AspNetCore.Authentication.Cookies;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;

[Authorize]
public class VehicleTypeController : Controller
{

    private readonly VehicleTypeRepository vehicletypes;
    public VehicleTypeController(FirestoreDb db)
    {
        vehicletypes = new VehicleTypeRepository(db);

    }

    public IActionResult Index()
    {
        return View();
    }

 
    public async Task<IActionResult> GetVehicleType()
    {
        // Retrieve all cars from the database
        var listVehicleTypes = await vehicletypes.GetAllAsync();

        // Serialize the cars to JSON format
        return Json(listVehicleTypes);
    }

     public async Task<IActionResult> Edit(string id)
    {

        var vehicletype = await vehicletypes.GetByIdAsync(id);
        ViewBag.Action = "Edit";
        return View(vehicletype);
    }

    [HttpPost]
    [ValidateAntiForgeryToken]

    public async Task<IActionResult> Edit(VehicleType vehicletype)
    {
        ViewBag.Action = "Edit";
    

        if (ModelState.IsValid)
        {
           
                try
                {
                    await vehicletypes.UpdateAsync(vehicletype.id, vehicletype);
                }
                catch (Exception ex)
                {
                    ModelState.AddModelError("VehicleType", ex.Message);
                    return View(vehicletype);
                }

                return RedirectToAction(nameof(Index));
            
        }

        return View(vehicletype);
    }
    


}