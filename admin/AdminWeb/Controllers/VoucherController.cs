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
public class VoucherController : Controller
{

    private readonly VoucherRepository vouchers;
    public VoucherController(FirestoreDb db)
    {
        vouchers = new VoucherRepository(db);

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
    public async Task<IActionResult> Create(Voucher voucher)
    {
        ViewBag.Action = "Create";

        if (ModelState.IsValid)
        {
            if (voucher.validFrom >= voucher.validUntil)
            {
                ModelState.AddModelError("validFrom", "Ngày hết hạn phải nhỏ hơn hoặc bằng ngày hiện tại.");
            }
            else if (voucher.usedCount > voucher.usageLimit)
            {
                ModelState.AddModelError("usedCount", "Số lần sử dụng đã vượt quá giới hạn.");
            }
            else
            {
                try
                {
                
                        await vouchers.AddVouchers(voucher);
                   

                }
                catch (Exception ex)
                {
                    ModelState.AddModelError("Voucher", ex.Message);
                    return View(voucher);
                }

                return RedirectToAction(nameof(Index));
            }
        }

        return View(voucher);
    }


    public async Task<IActionResult> Edit(string id)
    {

        var voucher = await vouchers.GetByIdAsync(id);
        ViewBag.Action = "Edit";
        TempData["OldCode"] = voucher.code;
        return View(voucher);
    }

    [HttpPost]
    [ValidateAntiForgeryToken]

    public async Task<IActionResult> Edit(Voucher voucher)
    {
        ViewBag.Action = "Edit";
            string oldCode = TempData["OldCode"] as string; // Retrieve the old code from TempData

        if (ModelState.IsValid)
        {
            if (voucher.validFrom >= voucher.validUntil)
            {
                ModelState.AddModelError("validFrom", "Ngày hết hạn phải nhỏ hơn hoặc bằng ngày hiện tại.");
            }
            else if (voucher.usedCount > voucher.usageLimit)
            {
                ModelState.AddModelError("usedCount", "Số lần sử dụng đã vượt quá giới hạn.");
            }
            else
            {
                try
                {
                    await vouchers.EditVouchers(voucher,oldCode);
                }
                catch (Exception ex)
                {
                    ModelState.AddModelError("Voucher", ex.Message);
                    TempData["OldCode"] = voucher.code;
                    return View(voucher);
                }

                return RedirectToAction(nameof(Index));
            }
        }
TempData["OldCode"] = voucher.code; 
        return View(voucher);
    }


    private async Task<bool> SaveCarAsync(Voucher voucher, string mode)
    {
        if (ModelState.IsValid)
        {
            if (mode == "Create")
            {


            }
            else
            {
            }



        }
        return false;


    }
    public async Task<IActionResult> GetVouchers(string searchText = "", string discountTypeFilter = "", bool? isActiveFilter = null)
    {
        // Retrieve all cars from the database
        var listsVouchers = await vouchers.GetAllAsync(searchText, discountTypeFilter, isActiveFilter);

        // Serialize the cars to JSON format
        return Json(listsVouchers);
    }


}