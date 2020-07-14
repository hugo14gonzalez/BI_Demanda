using Microsoft.AspNetCore.Mvc;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;
using Microsoft.AspNetCore.Http;
using Microsoft.AspNetCore.Http.Extensions;
using System.Net.Http;

namespace ReportViewerForCore
{
	public class ReportViewerHelper
	{
		public ReportViewerHelper()
		{
			this.ReportServerUrl = "http://localhost/ReportServer/";

			// this.ClientCredentialType = System.ServiceModel.HttpClientCredentialType.Ntlm;
			this.ClientCredentialType = System.ServiceModel.HttpClientCredentialType.Windows;

			this.Credentials = System.Net.CredentialCache.DefaultNetworkCredentials;
			this.AjaxLoadInitialReport = true;
			
			this.Encoding = Encoding.ASCII;
			//this.Encoding = Encoding.UTF8;
		}

		public ReportViewerHelper(string serverUrl) : this()
		{
			this.ReportServerUrl = serverUrl;
		}

		public ReportViewerHelper(string serverUrl, string domain, string user, string password) 
		{
			this.ReportServerUrl = serverUrl;

			// this.ClientCredentialType = System.ServiceModel.HttpClientCredentialType.Ntlm;
			this.ClientCredentialType = System.ServiceModel.HttpClientCredentialType.Windows;

			this.Credentials = new System.Net.NetworkCredential(user, password, domain);
			this.AjaxLoadInitialReport = true;

			this.Encoding = Encoding.ASCII;
			//this.Encoding = Encoding.UTF8;
		}

		public ReportViewerHelper(string serverUrl, System.Net.ICredentials credentials)
		{
			this.ReportServerUrl = serverUrl;

			//this.ClientCredentialType = System.ServiceModel.HttpClientCredentialType.Ntlm;
			this.ClientCredentialType = System.ServiceModel.HttpClientCredentialType.Windows;

			this.Credentials = credentials;
			this.AjaxLoadInitialReport = true;

			this.Encoding = Encoding.ASCII;
			//this.Encoding = Encoding.UTF8;
		}

		public System.Net.ICredentials Credentials { get; set; }

		public System.ServiceModel.HttpClientCredentialType ClientCredentialType { get; set; }

		public System.Text.Encoding Encoding { get; set; }

		public bool AjaxLoadInitialReport { get; set; }

		public string ReportServerUrl { get; set;  }

		/// <summary>
		/// This indicates whether or not to replace image urls from your report server to image urls on your local site to act as a proxy
		/// *useful if your report server is not accessible publicly*
		/// </summary>
		protected virtual bool UseCustomReportImagePath { get { return false; } }
		

		protected virtual string ReportImagePath
		{
			get
			{
				return "/Report/ReportImage/?originalPath={0}";
			}
		}

		protected virtual int? Timeout
		{
			get
			{
				return null;
			}
		}

		public JsonResult ViewReportPage(HttpRequest request, string reportPath, int? page = 0)
		//public string ViewReportPage(HttpRequest request, string reportPath, int? page = 0)
		{
			try
			{
				ReportViewerModel model = this.GetReportViewerModel(request);
				model.ViewMode = ReportViewModes.View;
				model.ReportPath = reportPath;

				var contentData = ReportServiceHelpers.ExportReportToFormat(model, ReportFormats.HTML5, page, page);

				var content = model.Encoding.GetString(contentData.ReportData);
				if (model.UseCustomReportImagePath && model.ReportImagePath.HasValue())
				{
					content = ReportServiceHelpers.ReplaceImageUrls(model, content);
				}

				var sb = new System.Text.StringBuilder();
				sb.AppendLine("<div>");
				sb.AppendLine($"{content}");
				sb.AppendLine("</div>");

				//var settings = new Newtonsoft.Json.JsonSerializerSettings
				//{
				//    //ContractResolver = new CamelCasePropertyNamesContractResolver()
				//    ContractResolver = new Newtonsoft.Json.Serialization.DefaultContractResolver()
				//};

				JsonResult jsonR = new JsonResult(new
					{
						CurrentPage = contentData.CurrentPage,
						Content = sb.ToString(),
						TotalPages = contentData.TotalPages
					}
				)
				{
					//ContentType = "text/html; charset=utf-8",
					ContentType = "application/json; charset=utf-8",
					StatusCode = 200,
					//SerializerSettings = settings
				};

				return jsonR;
				//return sb.ToString();

				/*
				var json = Newtonsoft.Json.JsonConvert.SerializeObject(new ReportContentResult(contentData.CurrentPage, contentData.TotalPages, content));
				return json;

				JsonResult jsonResult = new JsonResult(
					Newtonsoft.Json.JsonConvert.SerializeObject(new ReportContentResult(contentData.CurrentPage, contentData.TotalPages, content))
					, new Newtonsoft.Json.JsonSerializerSettings()
					{
						ContractResolver = new Newtonsoft.Json.Serialization.DefaultContractResolver()
					});

				JsonResult jsonResult2 = new JsonResult(
					new
					{
						CurrentPage = contentData.CurrentPage,
						Content = content,
						TotalPages = contentData.TotalPages
					}
					, new Newtonsoft.Json.JsonSerializerSettings()
					{
						ContractResolver = new Newtonsoft.Json.Serialization.DefaultContractResolver()
					});

				return jsonResult;
				*/
			}
			catch (Exception ex)
			{
				//return new JsonResult(new { Status = 500, statusText = ex.Message });
				throw;
			}
		}

		public FileResult ExportReport(string reportPath, string format, HttpRequest request)
		{
			var model = this.GetReportViewerModel(request);
			model.ViewMode = ReportViewModes.Export;
			model.ReportPath = reportPath;

			string extension = "";
			switch (format.ToUpper())
			{
				case "CSV":
					format = "CSV";
					extension = ".csv";
					break;
				case "MHTML":
					format = "MHTML";
					extension = ".mht";
					break;
				case "PDF":
					format = "PDF";
					extension = ".pdf";
					break;
				case "PPTX":
					format = "PPTX";
					extension = ".pptx";
					break;
				case "TIFF":
					format = "IMAGE";
					extension = ".tif";
					break;
				case "XML":
					format = "XML";
					extension = ".xml";
					break;
				case "WORDOPENXML":
					format = "WORDOPENXML";
					extension = ".docx";
					break;
				case "EXCELOPENXML":
				default:
					format = "EXCELOPENXML";
					extension = ".xlsx";
					break;
			}

			var contentData = ReportServiceHelpers.ExportReportToFormat(model, format);

			string filename = reportPath;
			if (filename.Contains("/"))
			{
				filename = filename.Substring(filename.LastIndexOf("/"));
				filename = filename.Replace("/", "");
			}

			filename += extension;

			//return File(contentData.ReportData, contentData.MimeType, filename);
			return new FileContentResult(contentData.ReportData, contentData.MimeType) { FileDownloadName = filename };
		}
		
		public JsonResult FindStringInReport(string reportPath, string searchText, HttpRequest request, int? page = 0)
		{
			var model = this.GetReportViewerModel(request);
			model.ViewMode = ReportViewModes.View;
			model.ReportPath = reportPath;

			//return Json(ReportServiceHelpers.FindStringInReport(model, searchText, page).ToInt32());
			return new JsonResult(ReportServiceHelpers.FindStringInReport(model, searchText, page).ToInt32());
		}

		public JsonResult ReloadParameters(string reportPath, HttpRequest request)
		{
			var model = this.GetReportViewerModel(request);
			model.ViewMode = ReportViewModes.View;
			model.ReportPath = reportPath;

			//return Json(CoreHtmlHelpers.ParametersToHtmlString(null, model));
			return new JsonResult(CoreHtmlHelpers.ParametersToHtmlString(null, model));
		}

		public ActionResult PrintReport(string reportPath, HttpRequest request)
		{
			var model = this.GetReportViewerModel(request);
			model.ViewMode = ReportViewModes.Print;
			model.ReportPath = reportPath;

			var contentData = ReportServiceHelpers.ExportReportToFormat(model, ReportFormats.HTML5);
			var content = model.Encoding.GetString(contentData.ReportData);
			content = ReportServiceHelpers.ReplaceImageUrls(model, content);

			var sb = new System.Text.StringBuilder();
			sb.AppendLine("<html>");
			sb.AppendLine("	<body>");
			sb.AppendLine($"	{content}");
			sb.AppendLine("		<script type='text/javascript'>");
			sb.AppendLine("			(function() {");

			sb.AppendLine("				var beforePrint = function() {");
			sb.AppendLine("					console.log('Before print ...');");
			sb.AppendLine("				};");

			sb.AppendLine("				var afterPrint = function() {");
			sb.AppendLine("					console.log('Apter print.');");
			//sb.AppendLine("					window.onfocus = function() { window.close(); };");
			//sb.AppendLine("					window.onmousemove = function() { window.close(); };");
			sb.AppendLine("				};");

			sb.AppendLine("				if (window.matchMedia) {");
			sb.AppendLine("					var mediaQueryList = window.matchMedia('print');");
			sb.AppendLine("					mediaQueryList.addListener(function(mql) {");
			sb.AppendLine("						if (mql.matches) {");
			sb.AppendLine("							beforePrint();");
			sb.AppendLine("						} else {");
			sb.AppendLine("							afterPrint();");
			sb.AppendLine("						}");
			sb.AppendLine("					});");
			sb.AppendLine("				}");

			sb.AppendLine("				window.onbeforeprint = beforePrint;");
			sb.AppendLine("				window.onafterprint = afterPrint;");

			sb.AppendLine("			}());");
			sb.AppendLine("			window.print();");
			sb.AppendLine("		</script>");
			sb.AppendLine("	</body>");

			sb.AppendLine("</html>");

			//return Content(sb.ToString(), "text/html");
			return new ContentResult() { Content = sb.ToString(), ContentType = "text/html", StatusCode = 200 };
		}

		public FileContentResult ReportImage(string originalPath, HttpRequest request)
		{
			var rawUrl = request.GetDisplayUrl().UrlDecode();
			var startIndex = rawUrl.IndexOf(originalPath);
			if (startIndex > -1)
			{
				originalPath = rawUrl.Substring(startIndex);
			}

			var clientHandler = new HttpClientHandler { Credentials = this.Credentials };
			using (var client = new HttpClient(clientHandler))
			{
				var imageData = client.GetByteArrayAsync(originalPath).Result;

				return new FileContentResult(imageData, "image/png");
			}
		}

		public ReportViewerModel GetReportViewerModel(HttpRequest request)
		{
			var model = new ReportViewerModel();
			model.ServerUrl = this.ReportServerUrl;
			model.AjaxLoadInitialReport = this.AjaxLoadInitialReport;
			model.ClientCredentialType = this.ClientCredentialType;
			model.Credentials = this.Credentials;

			var enablePagingResult = _getRequestValue(request, "ReportEnablePaging");
			if (enablePagingResult.HasValue())
			{
				model.EnablePaging = enablePagingResult.ToBoolean();
			}
			else
			{
				model.EnablePaging = true;
			}
			model.Encoding = this.Encoding;
			model.ReportImagePath = this.ReportImagePath;
			model.Timeout = this.Timeout;
			model.UseCustomReportImagePath = this.UseCustomReportImagePath;
			model.BuildParameters(request);

			return model;
		}

		private string _getRequestValue(HttpRequest request, string key)
		{
			if (request != null && request.Query != null && request.Query.Keys != null && request.Query.Keys.Contains(key))
			{
				var values = request.Query[key].ToSafeString().Split(',');
				if (values != null && values.Count() > 0)
				{
					return values[0].ToSafeString();
				}
			}

			try
			{
				if (request.Form != null && request.Form.Keys != null && request.Form.Keys.Contains(key))
				{
					return request.Form[key].ToSafeString();
				}
			}
			catch
			{
				//No need to throw errors, just no Form was passed in and it's unhappy about that
			}

			return string.Empty;
		}
	}
}
