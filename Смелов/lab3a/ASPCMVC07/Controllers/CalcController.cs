using Microsoft.AspNetCore.Mvc;

namespace ASPCMVC07.Controllers
{
    public class CalcController : Controller
    {
        public IActionResult Index()
        {
            ViewBag.press = "+";
            return View("Calc");
        }


        [HttpGet]
        [HttpPost]
        public IActionResult Sum(float? x, float? y)
        {
            if (x == null || y == null)
            {
                ViewBag.Error = "--ERROR: Invalid input!";
                ViewBag.press = "+";
                return View("Calc");
            }
            ViewBag.x = x;
            ViewBag.y = y;
            ViewBag.z = x + y;
            ViewBag.press = "+";
           
            return View("Calc");
            
        }
        [HttpGet]
        [HttpPost]
        public IActionResult Sub(float? x, float? y)
        {
            if (x == null || y == null)
            {
                ViewBag.Error = "--ERROR: Invalid input!";
                ViewBag.press = "-";
                return View("Calc");
            }

            ViewBag.x = x;
            ViewBag.y = y;
            ViewBag.z = x - y;
            ViewBag.press = "-";
            return View("Calc");
        }

        [HttpGet]
        [HttpPost]
        public IActionResult Mul(float? x, float? y)
        {
            if (x == null || y == null)
            {
                ViewBag.Error = "--ERROR: Invalid input!";
                ViewBag.press = "*";
                return View("Calc");
            }

            ViewBag.x = x;
            ViewBag.y = y;
            ViewBag.z = x * y;
            ViewBag.press = "*";
            return View("Calc");
        }
        [HttpGet]
        [HttpPost]
        public IActionResult Div(float? x, float? y)
        {
            
            if (x == null || y == null)
            {
                ViewBag.Error = "--ERROR: Invalid input!";
                ViewBag.press = "/";
                return View("Calc");
            }

            ViewBag.x = x;
            ViewBag.y = y;
            ViewBag.z = x / y;
            ViewBag.press = "/";
            return View("Calc");
        }
    }

}
