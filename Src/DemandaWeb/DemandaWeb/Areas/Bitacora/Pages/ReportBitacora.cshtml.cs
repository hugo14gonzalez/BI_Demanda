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
    public class ReportBitacoraModel : PageModel
    {
        private readonly IConfiguration _configuration;
        private readonly ILogger<IndexModel> _logger;

        public ReportBitacoraModel(IConfiguration configuration, ILogger<IndexModel> logger)
        {
            _configuration = configuration;
            _logger = logger;
            ReportHelper = new ReportViewerHelper(_configuration["Report:URLReportServer"]);
            Init();
        }

        public string ControllerPath { get; set; }

        public ReportViewerHelper ReportHelper { get; set; }

        [BindProperty(SupportsGet = true)]
        public ReportViewerModel ReportViewModel { get; set; }

        private void Init()
        {
            ReportViewModel = ReportHelper.GetReportViewerModel(this.Request);
            ReportViewModel.ReportPath = ReportServiceHelpers.AddCharacterStartEnd(_configuration["Report:BitacoraFolder"], true, true, "/")
                + _configuration["Report:ReportName_Audit_Bitacora"]; // "/DemandaBI/Auditoria/Audit_Bitacora";
            ReportViewModel.Title = "Bitácora";
            this.ControllerPath = "/Bitacora/ReportBitacora";
            ReportViewModel.ControllerPath = this.ControllerPath;
        }

        public void OnGet()
        {
            ViewData["Message"] = "Bitacora";
            Init();
        }


        public JsonResult OnGetViewReportPage(string reportPath, int? page = 0)
        //public ActionResult OnGetViewReportPage(string reportPath, int? page = 0)
        {
            var result = ReportHelper.ViewReportPage(this.Request, reportPath, page);

            //var settings = new Newtonsoft.Json.JsonSerializerSettings
            //{
            //    //ContractResolver = new CamelCasePropertyNamesContractResolver()
            //    ContractResolver = new Newtonsoft.Json.Serialization.DefaultContractResolver()
            //};

            //            JsonResult jsonR = new JsonResult(result)
            //            {
            //                ContentType = "text/html; charset=utf-8",
            ////                ContentType = "application/json; charset=utf-8",
            //                StatusCode = 200,
            //                //SerializerSettings = settings
            //            };

            return result;

            //return new ContentResult() { Content = result, ContentType = "text/html; charset=utf-8", StatusCode = 200 };
        }

        public FileResult OnGetExportReport(string reportPath, string format)
        {
            return ReportHelper.ExportReport(reportPath, format, this.Request);
        }

        public JsonResult OnGetFindStringInReport(string reportPath, string searchText, int? page = 0)
        {
            return ReportHelper.FindStringInReport(reportPath, searchText, this.Request, page);
        }

        public JsonResult OnGetReloadParameters(string reportPath)
        {
            return ReportHelper.ReloadParameters(reportPath, this.Request);
        }

        public ActionResult OnGetPrintReport(string reportPath)
        {
            try
            {
                return ReportHelper.PrintReport(reportPath, this.Request);
            }
            catch (Exception ex)
            {
                return BadRequest(ex.Message);
            }
        }

        public FileContentResult OnGetReportImage(string originalPath)
        {
            return ReportHelper.ReportImage(originalPath, this.Request);
        }
    }
}
