using AdminWeb.Models;
using Firebase.Auth;
using Firebase.Auth.Providers;
using FirebaseAdmin;
using FirebaseAdmin.Auth;
using Google.Apis.Auth.OAuth2;
using Google.Cloud.Firestore;
using Microsoft.AspNetCore.Authentication.Cookies;

var builder = WebApplication.CreateBuilder(args);

try
{
    // Path to your firebase_credentials.json file.  Make ABSOLUTELY SURE this file is NOT in your source control!  Use environment variables for production!
    string firebaseJsonPath = "C:\\Users\\Puyen\\Desktop\\doan\\admin\\AdminWeb\\firebaseadmin.json"; //Consider using environment variables instead!

 FirebaseApp firebaseApp=   FirebaseApp.Create(new AppOptions()
    {
        Credential = GoogleCredential.FromFile(firebaseJsonPath)
    });

    // Access Firestore after initialization is successful
    FirestoreDb db = FirestoreDb.Create("pantherapp010-1b674"); // replace with your project ID

    // Add FirestoreDb and repository as scoped services.  This is the correct location.
    builder.Services.AddScoped<FirestoreDb>(provider => db);
    builder.Services.AddScoped(typeof(IRepository<>), typeof(Repository<>));
    // Initialize FirebaseAuth
    var firebaseAuth = FirebaseAuth.DefaultInstance;

    // Register FirebaseAuth as a scoped service
    builder.Services.AddScoped<FirebaseAuth>(provider => firebaseAuth);

}
catch (Exception ex)
{
    // Handle exceptions during Firebase initialization, e.g., log the error
    Console.WriteLine($"Error initializing Firebase: {ex.Message}");
    // Consider gracefully handling this and maybe stopping the application if initialization fails
    throw;
}

builder.Services.AddAuthentication(CookieAuthenticationDefaults.AuthenticationScheme).AddCookie(
    options => {options.LoginPath = "/AppUser/Login";

                    options.AccessDeniedPath = "/Account/AccessDenied"; // Đường dẫn đến trang truy cập bị từ chối
    }

);
builder.Services.AddControllersWithViews();
 var app = builder.Build();

// Configure the HTTP request pipeline.
if (!app.Environment.IsDevelopment())
{
    app.UseExceptionHandler("/Home/Error");
    // The default HSTS value is 30 days. You may want to change this for production scenarios, see https://aka.ms/aspnetcore-hsts.
    app.UseHsts();
}


app.UseHttpsRedirection();
app.UseRouting();

app.UseAuthorization();

app.MapStaticAssets();

app.MapControllerRoute(
    name: "default",
    pattern: "{controller=Ride}/{action=Index}/{id?}")
    .WithStaticAssets();


app.Run();
