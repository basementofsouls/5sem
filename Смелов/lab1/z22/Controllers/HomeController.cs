using Microsoft.AspNetCore.Mvc;
using System.Diagnostics;
using z2.Models;

namespace z2.Controllers
{

    [Route("SAI")]
    public class XYZController : ControllerBase
    {
        [HttpPost]
        public IActionResult Index([FromBody] XYZRequestModel model)
        {
            if (model != null)
            {
                string responseText = $"POST-Http-SAI:ParmA = {model.ParmA},ParmB = {model.ParmB}";
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

}