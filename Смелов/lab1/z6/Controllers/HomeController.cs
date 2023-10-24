using Microsoft.AspNetCore.Mvc;
using System.Diagnostics;
using z6.Models;

namespace z6.Controllers
{
    public class HomeController : Controller
    {
        private readonly ILogger<HomeController> _logger;

        public HomeController(ILogger<HomeController> logger)
        {
            _logger = logger;
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
    }
    public class CalculatorController : Controller
    {
        [HttpGet]
        public IActionResult Index()
        {
            // Возвращаем HTML-страницу для GET-запроса
            return View();
        }

        [HttpPost]
        public IActionResult Calculate(int x, int y)
        {
            // Вычисляем произведение чисел x и y для POST-запроса
            int result = x * y;
            return Content(result.ToString());
        }
    }
}