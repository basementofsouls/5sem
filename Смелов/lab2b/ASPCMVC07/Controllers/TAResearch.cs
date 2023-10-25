using Microsoft.AspNetCore.Mvc;

namespace ASPCMVC07.Controllers
{
    [Route("it")]
    public class TAResearch : Controller
    {
        [HttpGet("{n:int}/{str}")]
        public IActionResult M04(int n, string str)
        {
            return Content($"GET:M04:/{n}/{str}");
        }

        [HttpPost("{b:bool}/{letters}")]
        public IActionResult M05(bool b, string letters)
        {
            return Content($"XXX:M05:/{b}/{letters}");
        }

        [HttpDelete("{f:float}/{str:length(2,5)}")]
        public IActionResult M06(float f, string str)
        {
            return Content($"XXX:M06:/{f}/{str}");
        }

        [HttpPut("{letters:length(3,4)}/{n:int:range(100,200)}")]
        public IActionResult M07(string letters, int n)
        {
            return Content($"PUT:M07:/{letters}/{n}");
        }

        [HttpPost]
        [Route("{mail:regex(^\\w+([[-+.']]\\w+)*@\\w+([[-.]]\\w+)*\\.\\w+([[-.]]\\w+)*$)}")]
        public IActionResult M08(string mail)
        {
            return Content($"POST:M08:{mail}");
        }




    }
}
