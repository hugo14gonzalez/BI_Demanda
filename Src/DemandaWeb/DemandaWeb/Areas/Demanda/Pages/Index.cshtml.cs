using System;
using System.Collections.Generic;
using System.ComponentModel.DataAnnotations;
using System.Linq;
using System.Threading.Tasks;
using Microsoft.AspNetCore.Mvc;
using Microsoft.AspNetCore.Mvc.RazorPages;
using Microsoft.Extensions.Configuration;
using Microsoft.Extensions.Logging;
using ReportViewerForCore;

namespace DemandaWeb.Areas.Demanda.Pages
{
    public class IndexModel : PageModel
    {
        private readonly IConfiguration _configuration;
        private readonly ILogger<IndexModel> _logger;

        public IndexModel(IConfiguration configuration, ILogger<IndexModel> logger)
        {
            _configuration = configuration;
            _logger = logger;
            ReportHelper = new ReportViewerHelper(_configuration["Report:URLReportServer"]);
        }

        public ReportViewerHelper ReportHelper { get; set; }

        public ReportViewerModel ReportViewModel { get; set; }

        public IActionResult OnGetDemandaRealComercialPerdida()
        {
            ViewData["Message"] = "DemandaRealComercialPerdida";

            if (!ModelState.IsValid)
            {
                return Page();
            }

            ReportViewModel = ReportHelper.GetReportViewerModel(this.Request);
            ReportViewModel.ReportPath = ReportServiceHelpers.AddCharacterStartEnd(_configuration["Report:DemandaFolder"], true, true, "/") 
                + _configuration["Report:ReportName_DemandaRealComercialPerdida"]; // "/DemandaBI/DemandaRealComercialPerdida";
            ReportViewModel.Title = "Demanda real comercial y pérdidas";

            return Page();
        }

        public IActionResult OnGetDemandaComercialAgente(string agente)
        {
            ViewData["Message"] = "DemandaComercialAgente" + " - Agente: " + agente;

            if (!ModelState.IsValid)
            {
                return Page();
            }

            ReportViewModel = ReportHelper.GetReportViewerModel(this.Request);
            ReportViewModel.ReportPath = ReportServiceHelpers.AddCharacterStartEnd(_configuration["Report:DemandaFolder"], true, true, "/")
                + _configuration["Report:ReportName_DemandaComercialAgente"]; // "/DemandaBI/DemandaComercialAgente";
            ReportViewModel.Title = "Demanda comercial por agente";

            return Page();
        }

        public IActionResult OnGetDemandaDepartamento()
        {
            ViewData["Message"] = "DemandaDepartamento";

            if (!ModelState.IsValid)
            {
                return Page();
            }

            ReportViewModel = ReportHelper.GetReportViewerModel(this.Request);
            ReportViewModel.ReportPath = ReportServiceHelpers.AddCharacterStartEnd(_configuration["Report:DemandaFolder"], true, true, "/")
                + _configuration["Report:ReportName_DemandaDepartamento"]; // "/DemandaBI/DemandaDepartamento";
            ReportViewModel.Title = "Demanda por geografía";

            return Page();
        }
    }
}
