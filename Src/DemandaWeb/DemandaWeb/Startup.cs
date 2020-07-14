using System;
using System.Collections.Generic;
using System.Globalization;
using System.Linq;
using System.Threading.Tasks;
using Microsoft.AspNetCore.Builder;
using Microsoft.AspNetCore.Hosting;
using Microsoft.AspNetCore.Localization;
using Microsoft.Extensions.Configuration;
using Microsoft.Extensions.DependencyInjection;
using Microsoft.Extensions.Hosting;

namespace DemandaWeb
{
    public class Startup
    {
        public Startup(IConfiguration configuration)
        {
            Configuration = configuration;
        }

        public IConfiguration Configuration { get; }

        // This method gets called by the runtime. Use this method to add services to the container.
        public void ConfigureServices(IServiceCollection services)
        {
            // Variables sesion
            services.AddSession(options => {
                options.IdleTimeout = TimeSpan.FromMinutes(120);
                options.Cookie.Name = "DemandaWeb";
            });
            services.AddMemoryCache();

            services.AddRazorPages();
        }

        // This method gets called by the runtime. Use this method to configure the HTTP request pipeline.
        public void Configure(IApplicationBuilder app, IWebHostEnvironment env)
        {
            CultureInfo cultureInfo = CultureInfo.CreateSpecificCulture(Configuration.GetValue<string>("cultureInfo:culture", "es-CO"));
            DateTimeFormatInfo dateFormat = new DateTimeFormatInfo
            {
                ShortDatePattern = Configuration.GetValue<string>("cultureInfo:ShortDatePattern", "yyyy-MM-dd"),
                LongDatePattern = Configuration.GetValue<string>("cultureInfo:LongDatePattern", "yyyy-MM-dd hh:mm:ss tt")
            };
            NumberFormatInfo numberFormat = new NumberFormatInfo
            {
                NumberDecimalDigits = Configuration.GetValue<int>("cultureInfo:NumberDecimalDigits", 2),
                NumberDecimalSeparator = Configuration.GetValue<string>("cultureInfo:NumberDecimalSeparator", "."),
                NumberGroupSeparator = Configuration.GetValue<string>("cultureInfo:NumberGroupSeparator", ","),
                CurrencySymbol = Configuration.GetValue<string>("cultureInfo:CurrencySymbol", "$"),
                CurrencyDecimalDigits = Configuration.GetValue<int>("cultureInfo:NumberDecimalDigits", 2),
                CurrencyDecimalSeparator = Configuration.GetValue<string>("cultureInfo:NumberDecimalSeparator", "."),
                CurrencyGroupSeparator = Configuration.GetValue<string>("cultureInfo:NumberGroupSeparator", ",")
            };

            cultureInfo.NumberFormat = numberFormat;
            cultureInfo.DateTimeFormat = dateFormat;

            var supportedCultures = new List<CultureInfo>
            {
                cultureInfo,
                new CultureInfo("en"),
                new CultureInfo("fr")
            };

            CultureInfo.DefaultThreadCurrentCulture = cultureInfo;
            CultureInfo.DefaultThreadCurrentUICulture = cultureInfo;

            app.UseRequestLocalization(new RequestLocalizationOptions
            {
                DefaultRequestCulture = new RequestCulture(cultureInfo),
                SupportedCultures = supportedCultures,
                SupportedUICultures = supportedCultures
            });

            /*
            if (env.IsDevelopment())
            {
                // app.UseDeveloperExceptionPage();
                app.UseExceptionHandler("/Error");
                app.UseStatusCodePagesWithReExecute("/Error/{0}");
            }
            else
            {
                app.UseExceptionHandler("/Error");
                app.UseStatusCodePagesWithReExecute("/Error/{0}");

                // The default HSTS value is 30 days. You may want to change this for production scenarios, see https://aka.ms/aspnetcore-hsts.
                //app.UseHsts();
            }
            */
            app.UseStaticFiles();
            app.UseRouting();
            app.UseAuthorization();

            //Variables sesion
            app.UseSession();

            app.UseEndpoints(endpoints =>
            {
                endpoints.MapRazorPages();
            });
        }
    }
}
