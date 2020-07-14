using System;
using System.Collections.Generic;
using System.Linq;
using System.Threading.Tasks;
using Microsoft.AspNetCore.Mvc;
using Microsoft.AspNetCore.Mvc.RazorPages;
using Microsoft.Extensions.Configuration;
using Microsoft.Extensions.Logging;
using ReportViewerForCore;

namespace DemandaWeb.Areas.Bitacora.Pages
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


        public IActionResult OnGetBitacora()
        {
            ViewData["Message"] = "Bitacora";

            if (!ModelState.IsValid)
            {
                return Page();
            }

            ReportViewModel = ReportHelper.GetReportViewerModel(this.Request);
            ReportViewModel.ReportPath = ReportServiceHelpers.AddCharacterStartEnd(_configuration["Report:BitacoraFolder"], true, true, "/")
                + _configuration["Report:ReportName_Audit_Bitacora"]; // "/DemandaBI/Auditoria/Audit_Bitacora";
            ReportViewModel.Title = "Bitácora";

            return Page();
        }

        public IActionResult OnGetBitacoraTabla()
        {
            ViewData["Message"] = "BitacoraTabla";

            if (!ModelState.IsValid)
            {
                return Page();
            }

            ReportViewModel = ReportHelper.GetReportViewerModel(this.Request);
            ReportViewModel.ReportPath = ReportServiceHelpers.AddCharacterStartEnd(_configuration["Report:BitacoraFolder"], true, true, "/")
                + _configuration["Report:ReportName_Audit_BitacoraTabla"]; // "/DemandaBI/Auditoria/Audit_BitacoraTabla";
            ReportViewModel.Title = "Bitácora inconsistencias en tablas";

            return Page();
        }

        public IActionResult OnGetBitacoraArchivo()
        {
            ViewData["Message"] = "BitacoraArchivo";

            if (!ModelState.IsValid)
            {
                return Page();
            }

            ReportViewModel = ReportHelper.GetReportViewerModel(this.Request);
            ReportViewModel.ReportPath = ReportServiceHelpers.AddCharacterStartEnd(_configuration["Report:BitacoraFolder"], true, true, "/")
                + _configuration["Report:ReportName_Audit_BitacoraArchivo"]; // "/DemandaBI/Auditoria/Audit_BitacoraArchivo";
            ReportViewModel.Title = "Bitácora de archivos procesados";

            return Page();
        }

        public IActionResult OnGetBitacoraEstadistica()
        {
            ViewData["Message"] = "BitacoraEstadistica";

            if (!ModelState.IsValid)
            {
                return Page();
            }

            ReportViewModel = ReportHelper.GetReportViewerModel(this.Request);
            ReportViewModel.ReportPath = ReportServiceHelpers.AddCharacterStartEnd(_configuration["Report:BitacoraFolder"], true, true, "/")
                + _configuration["Report:ReportName_Audit_BitacoraEstadisticas"]; // "/DemandaBI/Auditoria/Audit_BitacoraEstadisticas";
            ReportViewModel.Title = "Bitácora estadísticas de procesos";

            return Page();
        }

        public IActionResult OnGetBitacoraDetalle()
        {
            ViewData["Message"] = "BitacoraDetalle";

            if (!ModelState.IsValid)
            {
                return Page();
            }

            ReportViewModel = ReportHelper.GetReportViewerModel(this.Request);
            ReportViewModel.ReportPath = ReportServiceHelpers.AddCharacterStartEnd(_configuration["Report:BitacoraFolder"], true, true, "/")
                + _configuration["Report:ReportName_Audit_BitacoraDetalle"]; // "/DemandaBI/Auditoria/Audit_BitacoraDetalle";
            ReportViewModel.Title = "Bitácora detalles de ejecución";

            return Page();
        }
    }
}
