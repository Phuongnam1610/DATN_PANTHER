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
public class PromptController : Controller
{

    private readonly PromptRepository prompts;
    public PromptController(FirestoreDb db)
    {
        prompts = new PromptRepository(db);
    }

    public IActionResult Index()
    {
        return View();
    }
    public IActionResult Create()
    {
        ViewBag.Action = "Create";
        return View();
    }

    [HttpPost]
    public async Task<IActionResult> Create(Prompt prompt)
    {
        ViewBag.Action = "Create";

        if (ModelState.IsValid)
        {

            try
            {
                await prompts.AddPrompts(prompt);
            }
            catch (Exception ex)
            {
                ModelState.AddModelError("Prompt", ex.Message);
                return View(prompt);
            }

            return RedirectToAction(nameof(Index));
        }


        return View(prompt);
    }


    public async Task<IActionResult> Edit(string id)
    {

        var prompt = await prompts.GetByIdAsync(id);
        ViewBag.Action = "Edit";
        return View(prompt);
    }

    [HttpPost]
    [ValidateAntiForgeryToken]

    public async Task<IActionResult> Edit(Prompt prompt)
    {
        ViewBag.Action = "Edit";

        if (ModelState.IsValid)
        {

            try
            {
                await prompts.EditPrompts(prompt);
            }
            catch (Exception ex)
            {
                ModelState.AddModelError("Prompt", ex.Message);
                return View(prompt);
            }

            return RedirectToAction(nameof(Index));

        }

        return View(prompt);
    }



    public async Task<IActionResult> GetPrompts(string searchText = "")
    {
        // Retrieve all cars from the database
        var listsPrompts = await prompts.GetAllAsync(searchText);

        // Serialize the cars to JSON format
        return Json(listsPrompts);
    }


}