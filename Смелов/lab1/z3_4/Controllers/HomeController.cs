using Microsoft.AspNetCore.Mvc;
using System.Diagnostics;
using z3_4.Models;

namespace z3_4.Controllers
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
    [Route("SAI")]
    public class XYZController : ControllerBase
    {
        [HttpPut]
        public IActionResult Index([FromBody] XYZRequestModel model)
        {
            if (model != null)
            {
                string responseText = $"PUT-Http-SAI:ParmA = {model.ParmA},ParmB = {model.ParmB}";
                return Content(responseText, "text/plain");
            }
            else
            {
                return BadRequest("Invalid request data");
            }
        }
    }

    public class XYZRequestModel
    {
        public string ParmA { get; set; }
        public string ParmB { get; set; }
    }

    [Route("api/calculator")]
    public class CalculatorController : ControllerBase
    {
        [HttpPost]
        public IActionResult AddNumbers([FromBody] NumbersModel numbers)
        {
            if (numbers != null)
            {
                int sum = numbers.X + numbers.Y;
                return Ok(sum);
            }
            else
            {
                return BadRequest("Invalid input data");
            }
        }
    }

    public class NumbersModel
    {
        public int X { get; set; }
        public int Y { get; set; }
    }
}