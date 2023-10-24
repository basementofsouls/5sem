using Microsoft.AspNetCore.Mvc;

public class TMResearchController : Controller
{
    public IActionResult M01(string param)
    {
        // Логика для M01
        return Content($"GET:M01 {param}");
    }

    public IActionResult M02(string param)
    {
        // Логика для M02
        return Content($"GET:M02 {param}");
    }

    public IActionResult M03()
    {
        // Логика для M03
        return Content("GET:M03");
    }

    public IActionResult MXX()
    {
        // Логика для MXX (любой другой URI)
        return Content("GET:MXX");
    }
}
