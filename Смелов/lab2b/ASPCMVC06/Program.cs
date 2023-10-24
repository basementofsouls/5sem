var builder = WebApplication.CreateBuilder(args);

// Add services to the container.
builder.Services.AddControllersWithViews();

var app = builder.Build();

// Configure the HTTP request pipeline.
if (!app.Environment.IsDevelopment())
{
    app.UseExceptionHandler("/Home/Error");
}
app.UseStaticFiles();

app.UseRouting();

app.UseAuthorization();

app.MapControllerRoute(
    name: "default",
    pattern: "{controller=Home}/{action=Index}/{id?}");

app.UseEndpoints(endpoints =>
{
    endpoints.MapControllerRoute(
        name: "default",
        pattern: "{controller=Home}/{action=Index}/{id?}");
    endpoints.MapControllerRoute(
               name: "M01",
               pattern: "MResearch/M01/{param?}",
               defaults: new { controller = "TMResearch", action = "M01" }
           );

    endpoints.MapControllerRoute(
        name: "M02",
        pattern: "V2/MResearch/M02/{param?}",
        defaults: new { controller = "TMResearch", action = "M02" }
    );

    endpoints.MapControllerRoute(
        name: "M03",
        pattern: "V3/MResearch/string/M03",
        defaults: new { controller = "TMResearch", action = "M03" }
    );

    endpoints.MapControllerRoute(
        name: "MXX",
        pattern: "TMResearch/{*path}",
        defaults: new { controller = "TMResearch", action = "MXX" }
    );
});



app.Run();
