using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;
using Microsoft.AspNetCore.Html;
using Microsoft.AspNetCore.Mvc.Rendering;
using Newtonsoft.Json;
using Newtonsoft.Json.Serialization;

namespace ReportViewerForCore
{
	public static class CoreHtmlHelpers
	{
		public static HtmlString ToJson(this IHtmlHelper helper, object obj)
		{
			var settings = new JsonSerializerSettings
			{
				//ContractResolver = new CamelCasePropertyNamesContractResolver()
				ContractResolver = new Newtonsoft.Json.Serialization.DefaultContractResolver()
			};
			return (HtmlString) helper.Raw(JsonConvert.SerializeObject(obj, settings));
			//return helper.Raw(JsonConvert.SerializeObject(obj, settings));
		}

		public static HtmlString RenderContentReport(this IHtmlHelper helper, string content)
		{
			StringBuilder sb = new StringBuilder();
			sb.AppendLine("<div>");
			sb.AppendLine($" {content}");
			sb.AppendLine("</div>");
			return new HtmlString(sb.ToString());
		}

		public static HtmlString RenderScriptReportViewer(this IHtmlHelper helper, ReportViewerModel model)
		{
			StringBuilder sb = new StringBuilder();
			var contentData = ReportServiceHelpers.ExportReportToFormat(model, ReportFormats.HTML5, 1, 1);

			if (model.AjaxLoadInitialReport)
			{
				sb.AppendLine("<script type='text/javascript'>$(document).ready(function () { viewReportPage(1); });</script>");
			}

			sb.AppendLine("<script type='text/javascript'>");
			sb.AppendLine("	function ReportViewer_Register_OnChanges() {");

			var dependencyFieldKeys = new List<string>();
			foreach (var parameter in contentData.Parameters.Where(x => x.Dependencies != null && x.Dependencies.Any()))
			{
				foreach (var key in parameter.Dependencies)
				{
					if (!dependencyFieldKeys.Contains(key))
					{
						dependencyFieldKeys.Add(key);
					}
				}
			}

			foreach (var queryParameter in contentData.Parameters.Where(x => dependencyFieldKeys.Contains(x.Name)))
			{
				sb.AppendLine("		$('#" + queryParameter.Name + "').change(function () {");
				sb.AppendLine("			reloadParameters();");
				sb.AppendLine("		});");
			}

			sb.AppendLine("	}");
			sb.AppendLine("</script>");

			string s = sb.ToString();
			return new HtmlString(sb.ToString());
		}

		public static HtmlString RenderReportViewer_Borrar(this IHtmlHelper helper, ReportViewerModel model, int? startPage = 1)
		{
			string tagsParameters;
			StringBuilder sb = new StringBuilder();
			var contentData = ReportServiceHelpers.ExportReportToFormat(model, ReportFormats.HTML5, startPage, startPage);

			sb.AppendLine("<form class='d-flex form-inline' id='frmReportViewer' name='frmReportViewer'>");
			sb.AppendLine(" <div class='d-flex flex-column align-items-start'>");

			tagsParameters = ParametersToHtmlString(contentData.Parameters, model);
			if (!string.IsNullOrWhiteSpace(tagsParameters))
			{
				sb.AppendLine(tagsParameters);
			}

			sb.AppendLine("   <div class='container-fluid reportToolbar'>");
			sb.AppendLine("    <div class='btn-toolbar' role='toolbar'>");
			if (model.EnablePaging)
			{
				sb.AppendLine("     <div class='btn-group btn-group-sm reportToolbarGroup' role='group'>");
				sb.AppendLine("      <div class='btn-group btn-group-sm' role='group'>");
				sb.AppendLine($"	    <button name='ReportFirstPage' id='ReportFirstPage'  title='Primera página' type='button' class='btn btn-light'{(contentData.TotalPages == 1 ? " disabled='disabled'" : "")}><i class='fa fa-step-backward'></i></button>");
				sb.AppendLine($"	    <button name='ReportPreviousPage' id='ReportPreviousPage' title='Página anterior' type='button' class='btn btn-light'{(contentData.TotalPages == 1 ? " disabled='disabled'" : "")}><i class='fa fa-chevron-left'></i></button>");
				sb.AppendLine("      </div>");
				sb.AppendLine("		 <div class='input-group'>");
				sb.AppendLine($"	   <span class='pagerNumbers'><input type='text' id='ReportCurrentPage' name='ReportCurrentPage' class='form-control' value='{contentData.CurrentPage}' /> de <span id='ReportTotalPages'>{contentData.TotalPages}</span></span>");
				sb.AppendLine("		 </div>");
				sb.AppendLine("      <div class='btn-group btn-group-sm mr-2' role='group'>");
				sb.AppendLine($"	    <button name='ReportNextPage' id='ReportNextPage' title='Página siguiente' type='button' class='btn btn-light'{(contentData.TotalPages == 1 ? " disabled='disabled'" : "")}><i class='fa fa-chevron-right'></i></button>");
				sb.AppendLine($"	    <button name='ReportLastPage' id='ReportLastPage' title='Última página' type='button' class='btn btn-light'{(contentData.TotalPages == 1 ? " disabled='disabled'" : "")}><i class='fa fa-step-forward'></i></button>");
				sb.AppendLine("      </div>");
				sb.AppendLine("     </div>");
			}
			sb.AppendLine("     <div class='btn-group btn-group-sm mr-2 reportToolbarGroup' role='group'>");
			sb.AppendLine("		 <a href='#' name='ReportRefresh' id='ReportRefresh' title='Actualizar' class='btn btn-light'><span style='color: green;'><i class='fa fa-refresh'></i></span></a>");
			sb.AppendLine("		 &nbsp;");
			sb.AppendLine("		 <div class='btn-group' role='group'>");
			sb.AppendLine("		  <button id='ReportExport' name='ReportExport' title='Exportar' type='button' class='btn btn-light dropdown-toggle' data-toggle='dropdown' aria-haspopup='true' aria-expanded='false'>");
			sb.AppendLine("		   <span style='color: steelblue;'>Exportar&nbsp;<i class='fa fa-save'></i></span>");
			sb.AppendLine("		  </button>");
			sb.AppendLine("		  <div class='dropdown-menu' aria-labelledby='btnSave'>");
			sb.AppendLine("		   <a name='ReportExportWordOpenXml' id='ReportExportWordOpenXml' class='dropdown-item' href='#'>Word</a>");
			sb.AppendLine("		   <a name='ReportExportExcelOpenXml' id='ReportExportExcelOpenXml' class='dropdown-item' href='#'>Excel</a>");
			sb.AppendLine("		   <a name='ReportExportPPTX' id='ReportExportPPTX' class='dropdown-item' href='#'>PowerPoint</a>");
			sb.AppendLine("		   <a name='ReportExportPdf' id='ReportExportPdf' class='dropdown-item' href='#'>PDF</a>");
			sb.AppendLine("		   <a name='ReportExportTiff' id='ReportExportTiff' class='dropdown-item' href='#'>Archivo TIFF</a>");
			sb.AppendLine("		   <a name='ReportExportMhtml' id='ReportExportMhtml' class='dropdown-item' href='#'>MHTML (archivo web)</a>");
			sb.AppendLine("		   <a name='ReportExportCsv' id='ReportExportCsv' class='dropdown-item' href='#'>CSV (delimitado por coma)</a>");
			sb.AppendLine("		   <a name='ReportExportXml' id='ReportExportXml' class='dropdown-item' href='#'>XML con datos del informe</a>");
			sb.AppendLine("		  </div>");
			sb.AppendLine("		 </div>");
			sb.AppendLine("		 &nbsp;");
			sb.AppendLine("		 <a name='ReportPrint' id='ReportPrint' href='#' title='Imprimir' class='btn btn-light'><i class='fa fa-print'></i></a>");
			sb.AppendLine("     </div>");

			sb.AppendLine("     <div class='input-group mr-2 reportToolbarGroup' role='group'");
			sb.AppendLine("		 <span class='searchText'>");
			sb.AppendLine($"	  <input type='text' id='ReportSearchText' name='ReportSearchText' class='form-control SearchText' value='' />");
			sb.AppendLine($"	  <a name='ReportFind' id='ReportFind' href='#' title='Buscar' class='btn btn-light'><span style='padding-right: .5em;'>Buscar&nbsp;<i class='fa fa-search'></i></span></a>");
			sb.AppendLine("		 </span>");
			sb.AppendLine("     </div>");

			sb.AppendLine("     <div class='btn-group btn-group-sm reportToolbarGroup' role='group'>");
			sb.AppendLine("		 <button name='ReportShow' id='ReportShow' type='button' class='btn btn-sm btn-primary'>Ver Reporte</button>");
			sb.AppendLine("     </div>");

			sb.AppendLine("    </div>"); /* btn-toolbar */
			sb.AppendLine("	 </div>");   /* container reportToolbar */

			sb.AppendLine("   <div class='container-fluid reportContentContainer'>");
			sb.AppendLine("    <div class='reportContent'>");
			if (model.IsMissingAnyRequiredParameterValues(contentData.Parameters))
			{
				sb.AppendLine("     <div class='reportInformation'>Por favor llene los parámetros y ejecute el reporte ...</div>");
			}
			else
			{
				if (!model.AjaxLoadInitialReport)
				{
					if (contentData == null || contentData.ReportData == null || contentData.ReportData.Length == 0)
					{
						sb.AppendLine("");
					}
					else
					{
						var content = model.Encoding.GetString(contentData.ReportData);
						if (model.UseCustomReportImagePath && model.ReportImagePath.HasValue())
						{
							content = ReportServiceHelpers.ReplaceImageUrls(model, content);
						}
						sb.AppendLine($"    {content}");
					}
				}
			}
			sb.AppendLine("	  </div>");   /* reportContent */
			sb.AppendLine("	 </div>");   /* container--fluid reportContentContainer */

			sb.AppendLine(" </div>");/* d-flex flex-column */
			sb.AppendLine("</form>");

			return new HtmlString(sb.ToString());
		}

		public static HtmlString RenderReportViewer(this IHtmlHelper helper, ReportViewerModel model, int? startPage = 1)
		{
			string tagsParameters;
			StringBuilder sb = new StringBuilder();
			var contentData = ReportServiceHelpers.ExportReportToFormat(model, ReportFormats.HTML5, startPage, startPage);

			sb.AppendLine("<form class='d-flex form-inline' id='frmReportViewer' name='frmReportViewer'>");
			sb.AppendLine(" <div class='d-flex flex-column align-items-start'>");

			tagsParameters = ParametersToHtmlString(contentData.Parameters, model);
			if (!string.IsNullOrWhiteSpace(tagsParameters))
			{
				sb.AppendLine(tagsParameters);
			}

			sb.AppendLine("   <div class='d-flex reportToolbar'>");
			sb.AppendLine("    <div class='d-flex flex-row reportToolbar'>");
			if (model.EnablePaging)
			{
				sb.AppendLine("     <div class='col-auto form-group reportToolbarGroup'>");
				sb.AppendLine($"	 <button name='ReportFirstPage' id='ReportFirstPage'  title='Primera página' type='button' class='btn btn-light mr-1'{(contentData.TotalPages == 1 ? " disabled='disabled'" : "")}><i class='fa fa-step-backward'></i></button>");
				sb.AppendLine($"	 <button name='ReportPreviousPage' id='ReportPreviousPage' title='Página anterior' type='button' class='btn btn-light mr-1'{(contentData.TotalPages == 1 ? " disabled='disabled'" : "")}><i class='fa fa-chevron-left'></i></button>");
 				sb.AppendLine($"	 <span class='pagerNumbers mr-1'><input type='text' id='ReportCurrentPage' name='ReportCurrentPage' class='form-control' value='{contentData.CurrentPage}' /> de <span id='ReportTotalPages'>{contentData.TotalPages}</span></span>");
				sb.AppendLine($"	 <button name='ReportNextPage' id='ReportNextPage' title='Página siguiente' type='button' class='btn btn-light mr-1'{(contentData.TotalPages == 1 ? " disabled='disabled'" : "")}><i class='fa fa-chevron-right'></i></button>");
				sb.AppendLine($"	 <button name='ReportLastPage' id='ReportLastPage' title='Última página' type='button' class='btn btn-light'{(contentData.TotalPages == 1 ? " disabled='disabled'" : "")}><i class='fa fa-step-forward'></i></button>");
				sb.AppendLine("     </div>");
			}
			sb.AppendLine("     <div class='col-auto form-group reportToolbarGroup'>");
			sb.AppendLine("		 <a href='#' name='ReportRefresh' id='ReportRefresh' title='Actualizar' class='btn btn-light mr-1'><span style='color: green;'><i class='fa fa-refresh'></i></span></a>");
			sb.AppendLine("		 <button id='ReportExport' name='ReportExport' title='Exportar' type='button' class='btn btn-light dropdown-toggle mr-1' data-toggle='dropdown' aria-haspopup='true' aria-expanded='false'>");
			sb.AppendLine("		  <span style='color: steelblue;'>Exportar&nbsp;<i class='fa fa-save'></i></span>");
			sb.AppendLine("		 </button>");
			sb.AppendLine("		 <div class='dropdown-menu mr-1' aria-labelledby='btnSave'>");
			sb.AppendLine("		   <a name='ReportExportWordOpenXml' id='ReportExportWordOpenXml' class='dropdown-item' href='#'>Word</a>");
			sb.AppendLine("		   <a name='ReportExportExcelOpenXml' id='ReportExportExcelOpenXml' class='dropdown-item' href='#'>Excel</a>");
			sb.AppendLine("		   <a name='ReportExportPPTX' id='ReportExportPPTX' class='dropdown-item' href='#'>PowerPoint</a>");
			sb.AppendLine("		   <a name='ReportExportPdf' id='ReportExportPdf' class='dropdown-item' href='#'>PDF</a>");
			sb.AppendLine("		   <a name='ReportExportTiff' id='ReportExportTiff' class='dropdown-item' href='#'>Archivo TIFF</a>");
			sb.AppendLine("		   <a name='ReportExportMhtml' id='ReportExportMhtml' class='dropdown-item' href='#'>MHTML (archivo web)</a>");
			sb.AppendLine("		   <a name='ReportExportCsv' id='ReportExportCsv' class='dropdown-item' href='#'>CSV (delimitado por coma)</a>");
			sb.AppendLine("		   <a name='ReportExportXml' id='ReportExportXml' class='dropdown-item' href='#'>XML con datos del informe</a>");
			sb.AppendLine("		 </div>");
			sb.AppendLine("		 <a name='ReportPrint' id='ReportPrint' href='#' title='Imprimir' class='btn btn-light'><i class='fa fa-print'></i></a>");
			sb.AppendLine("     </div>");

			sb.AppendLine("     <div class='col-auto form-group reportToolbarGroup'");
			sb.AppendLine("		 <span class='searchText'>");
			sb.AppendLine($"	  <input type='text' id='ReportSearchText' name='ReportSearchText' class='form-control SearchText mr-1' value='' />");
			sb.AppendLine($"	  <a name='ReportFind' id='ReportFind' href='#' title='Buscar' class='btn btn-light'><span style='padding-right: .5em;'>Buscar&nbsp;<i class='fa fa-search'></i></span></a>");
			sb.AppendLine("		 </span>");
			sb.AppendLine("     </div>");

			sb.AppendLine("     <div class='col-auto form-group reportToolbarGroup'>");
			sb.AppendLine("		 <button name='ReportShow' id='ReportShow' type='button' class='btn btn-sm btn-primary'>Ver Reporte</button>");
			sb.AppendLine("     </div>");

			sb.AppendLine("    </div>"); /* btn-toolbar */
			sb.AppendLine("	 </div>");   /* container reportToolbar */

			sb.AppendLine("   <div class='container-fluid reportContentContainer'>");
			sb.AppendLine("    <div class='reportContent'>");
			if (model.IsMissingAnyRequiredParameterValues(contentData.Parameters))
			{
				sb.AppendLine("     <div class='reportInformation'>Por favor llene los parámetros y ejecute el reporte ...</div>");
			}
			else
			{
				if (!model.AjaxLoadInitialReport)
				{
					if (contentData == null || contentData.ReportData == null || contentData.ReportData.Length == 0)
					{
						sb.AppendLine("");
					}
					else
					{
						var content = model.Encoding.GetString(contentData.ReportData);
						if (model.UseCustomReportImagePath && model.ReportImagePath.HasValue())
						{
							content = ReportServiceHelpers.ReplaceImageUrls(model, content);
						}
						sb.AppendLine($"    {content}");
					}
				}
			}
			sb.AppendLine("	  </div>");   /* reportContent */
			sb.AppendLine("	 </div>");   /* container--fluid reportContentContainer */

			sb.AppendLine(" </div>");/* d-flex flex-column */
			sb.AppendLine("</form>");

			return new HtmlString(sb.ToString());
		}

		public static string ParametersToHtmlString(System.Collections.Generic.List<ReportParameterInfo> parameters, ReportViewerModel model)
		{
			StringBuilder sb = new StringBuilder();
			string selectedValue, tmpDateValue;
			string[] values;

			if (parameters == null)
			{
				var contentData = new ReportExportResult();
				var definedParameters = ReportServiceHelpers.GetReportParameters(model, true);
				contentData.SetParameters(definedParameters, model.Parameters);
				parameters = contentData.Parameters;
			}

			if (parameters != null && parameters.Count > 0)
			{
				sb.AppendLine("<div class='d-flex parametersContainer'>");
				sb.AppendLine(" <div class='d-flex flex-row row-cols-4 parameters'>");

				foreach (var reportParameter in parameters)
				{
					sb.AppendLine("	 <div class='form-group parameter'>");
					if (reportParameter.PromptUser || model.ShowHiddenParameters)
					{
						sb.AppendLine($"	   <label class='pr-1' for='{reportParameter.Name}'>{reportParameter.Prompt.HtmlEncode()}</label>");
						if (reportParameter.ValidValues != null && reportParameter.ValidValues.Any())
						{
							sb.AppendLine($"    <select id='{reportParameter.Name}' name='{reportParameter.Name}' class='form-control' {(reportParameter.MultiValue == true ? "multiple='multiple'" : "")}>");
							foreach (var value in reportParameter.ValidValues)
							{
								sb.AppendLine($"     <option value='{value.Value}' {(reportParameter.SelectedValues.Contains(value.Value) ? "selected='selected'" : "")}>{value.Label.HtmlEncode()}</option>");
							}
							sb.AppendLine($"    </select>");
						}
						else
						{
							selectedValue = reportParameter.SelectedValues.FirstOrDefault();
							if (reportParameter.Type == ReportExecutionService.ParameterTypeEnum.Boolean)
							{
								sb.AppendLine($"    <input type='checkbox' id='{reportParameter.Name}' name='{reportParameter.Name}' class='form-control' {(selectedValue.ToBoolean() ? "checked='checked'" : "")} />");
							}
							else if (reportParameter.Type == ReportExecutionService.ParameterTypeEnum.DateTime)
							{
								// Aplicar formato de fecha
								tmpDateValue = ConvertDateToString(selectedValue);
								sb.AppendLine($"    <input type='datetime' id='{reportParameter.Name}' name='{reportParameter.Name}' class='form-control' value='{tmpDateValue}' />");
							}
							else
							{
								sb.AppendLine($"    <input type='text' id='{reportParameter.Name}' name='{reportParameter.Name}' class='form-control' value='{selectedValue}' />");
							}
						}
					}
					else
					{
						if (reportParameter.SelectedValues != null && reportParameter.SelectedValues.Any())
						{
							values = reportParameter.SelectedValues.Where(x => x != null).Select(x => x).ToArray();
							sb.AppendLine($"  <input type='hidden' id='{reportParameter.Name}' name='{reportParameter.Name}' value='{String.Join(",", values)}' />");
						}
					}
					sb.AppendLine("	 </div>"); /* form-group */
				}

				sb.AppendLine(" </div>");
				sb.AppendLine($"  <input type='hidden' id='ReportEnablePaging' name='ReportEnablePaging' value='{model.EnablePaging}' />");
				sb.AppendLine("</div>");
			}
			return sb.ToString();
		}

		public static string ConvertDateToString(string value)
		{
			try
			{
				DateTime result;
				string[] dateFormats = new string[] {"yyyy-MM-dd", "yyyy-M-dd", "yyyy-MM-d", "yyyy-M-d",
				  "dd/MM/yyyy", "dd/M/yyyy", "d/MM/yyyy", "d/M/yyyy"};
				/* "dd/MM/yyyy hh:mm:ss tt", "dd/M/yyyy hh:mm:ss tt", "d/M/yyyy hh:mm:ss tt", "d/MM/yyyy hh:mm:ss tt", "dd/MM/yy hh:mm:ss tt", "dd/M/yy hh:mm:ss tt", "d/M/yy hh:mm:ss tt", "d/MM/yy hh:mm:ss tt" */
				if (!DateTime.TryParseExact((value ?? "").Split(' ')[0], dateFormats, System.Globalization.CultureInfo.InvariantCulture
					, System.Globalization.DateTimeStyles.None, out result))
				{
					return value;
				}

				return result.ToString("yyyy-MM-dd");
			}
			catch (Exception)
			{
				return value;
			}
		}
	}
}
