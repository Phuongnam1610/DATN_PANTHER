using System.Net;
using System.Security.Claims;
using System.Text.Json;
using AdminWeb.Models;
using Firebase.Auth;
using Firebase.Auth.Providers;
using FirebaseAdmin.Auth;
using Microsoft.AspNetCore.Authentication;
using Microsoft.AspNetCore.Authentication.Cookies;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;

public class AppUserController : Controller
{   

    

    public AppUserController()
    {
        
    }

    public IActionResult Login()
    {

        return View();

    }
   

[HttpPost]
public async Task<IActionResult> Login([FromBody] Dictionary<string, string> data)
{
    string idToken = data["idToken"];
    if (string.IsNullOrEmpty(idToken))
    {
        ModelState.AddModelError(string.Empty, "Invalid token.");
        return View();
    }

    try
    {
        // Verify the token
        var decodedToken = await FirebaseAuth.DefaultInstance.VerifyIdTokenAsync(idToken);
        var email = decodedToken.Claims["email"]?.ToString();
        if(email!="adminpantherapp010@gmail.com"){
                        return Json(new { success = false, redirectUrl = Url.Action("Ride") });

        }

        if (string.IsNullOrEmpty(email))
        {
            ModelState.AddModelError(string.Empty, "Email not found in token.");
            return View();
        }

        // Get user by email
        var user = await FirebaseAuth.DefaultInstance.GetUserByEmailAsync(email);
        
        // Create claims for the user
        var claims = new List<Claim>
        {
            new Claim(ClaimTypes.NameIdentifier, user.Uid),
            new Claim(ClaimTypes.Email, email)
            // Add other claims as necessary
        };

        var claimsIdentity = new ClaimsIdentity(claims, CookieAuthenticationDefaults.AuthenticationScheme);
        
        // Sign in the user
        await HttpContext.SignInAsync(CookieAuthenticationDefaults.AuthenticationScheme, new ClaimsPrincipal(claimsIdentity));

            return Json(new { success = true }); // Return JSON success
    }
    catch (Firebase.Auth.FirebaseAuthException ex)
    {
            return Json(new { success = false, redirectUrl = Url.Action("Ride") });
        
    }
    catch (Exception ex)
    {
            return Json(new { success = false, redirectUrl = Url.Action("Ride") });
    }

}



    public IActionResult Register()
    {
        return View();
    } public IActionResult SignOut()
    {
        HttpContext.SignOutAsync(CookieAuthenticationDefaults.AuthenticationScheme);
        return RedirectToAction("Login", "AppUser");
    }

    public IActionResult Success()
    {
        return RedirectToAction("Index", "Admin");
    }



    [Authorize]
    public IActionResult Profile()
    {
        ViewBag.Name = HttpContext.User.Identity.Name;
        return View();

    }

    private void SetLockoutStartTimeInSession(ISession session, DateTime dateTime)
    {
        session.SetString("LockoutStartTime", JsonSerializer.Serialize(dateTime));
    }

    private DateTime? GetLockoutStartTimeFromSession(ISession session)
    {
        string lockoutTimeJson = session.GetString("LockoutStartTime");
        if (lockoutTimeJson == null) return null;
        return JsonSerializer.Deserialize<DateTime>(lockoutTimeJson);
    }


    private void RemoveLockoutStartTimeFromSession(ISession session)
    {
        session.Remove("LockoutStartTime");
    }


}