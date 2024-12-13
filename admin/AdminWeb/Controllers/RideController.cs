using System.Net;
using System.Security.Claims;
using System.Text.Json;
using Google.Cloud.Firestore;
using Microsoft.AspNetCore.Authentication;
using Microsoft.AspNetCore.Authentication.Cookies;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;

[Authorize]
public class RideController : Controller
{
    
    private readonly RideRepository _rides;
    public RideController(FirestoreDb db)
    {
        _rides=new RideRepository(db);
    }

    public IActionResult Index()
    {
        var rides = _rides.GetAllAsync();
        return View();
    }
   


}