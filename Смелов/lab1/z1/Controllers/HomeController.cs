using Microsoft.AspNetCore.Mvc;
using System.Diagnostics;
using z1.Models;

namespace z1.Controllers
{
    
    public class HomeController : Controller
    {
        
        [HttpGet("/SAI")] // Указываем маршрут
        public IActionResult Index(string ParmA, string ParmB)
        {
            // Формируем HTTP-ответ
            string responseText = $"GET-Http-SAI:ParmA = {ParmA},ParmB = {ParmB}";

            // Возвращаем ответ с типом text/plain
            return Content(responseText, "text/plain");
        }

       
    }
}