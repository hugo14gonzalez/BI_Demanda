using System;
using System.Collections.Generic;
using System.Linq;
using System.Net;
using System.Threading.Tasks;
using Microsoft.AspNetCore.Mvc;
using Microsoft.AspNetCore.Mvc.RazorPages;
using Microsoft.Extensions.Configuration;
using Microsoft.Extensions.Logging;
using ReportViewerForCore;

namespace DemandaWeb.Pages
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

        public void OnGet()
        {
            ViewData["Message"] = "Indicadores de demanda de energía";
            ReportViewModel = ReportHelper.GetReportViewerModel(this.Request);

            ReportViewModel.ReportPath = ReportServiceHelpers.AddCharacterStartEnd(_configuration["Report:DemandaFolder"], true, true, "/")
                + _configuration["Report:ReportName_DashBoardBI"]; // "/DemandaBI/DashBoardBI";
            ReportViewModel.Title = "Indicadores de demanda de energía";
        }
    }
}
