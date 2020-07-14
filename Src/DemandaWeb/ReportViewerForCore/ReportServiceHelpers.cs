using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace ReportViewerForCore
{
	public static class ReportServiceHelpers
	{
		public static string AddCharacterStartEnd(string value, bool toStart, bool toEnd, string charAdd = "/")
		{
			string result = value;

			if (result == null)
			{
				return null;
			}
			if (toStart)
			{
				result = ((result.StartsWith(charAdd)) ? "" : charAdd) + result;
			}
			if (toEnd)
			{
				result += ((result.EndsWith(charAdd)) ? "" : charAdd);
			}
			return result;
		}

		private static System.ServiceModel.HttpBindingBase _initializeHttpBinding(string url, ReportViewerModel model)
		{
			if (url.ToLower().StartsWith("https"))
			{
				var binding = new System.ServiceModel.BasicHttpsBinding(System.ServiceModel.BasicHttpsSecurityMode.Transport);
				binding.Security.Transport.ClientCredentialType = model.ClientCredentialType; // System.ServiceModel.HttpClientCredentialType.Ntlm; // model.ClientCredentialType;
				binding.MaxReceivedMessageSize = int.MaxValue; // 10MB size limit on response to allow for larger PDFs (Valor por defecto: 65536)
				if (model.Timeout.HasValue)
				{
					if (model.Timeout == System.Threading.Timeout.Infinite)
					{
						binding.CloseTimeout = TimeSpan.MaxValue;
						binding.OpenTimeout = TimeSpan.MaxValue;
						binding.ReceiveTimeout = TimeSpan.MaxValue;
						binding.SendTimeout = TimeSpan.MaxValue;
					}
					else
					{
						binding.CloseTimeout = new TimeSpan(0, 0, model.Timeout.Value);
						binding.OpenTimeout = new TimeSpan(0, 0, model.Timeout.Value);
						binding.ReceiveTimeout = new TimeSpan(0, 0, model.Timeout.Value);
						binding.SendTimeout = new TimeSpan(0, 0, model.Timeout.Value);
					}
				}
				else
				{
					binding.CloseTimeout = TimeSpan.MaxValue;
					binding.OpenTimeout = TimeSpan.MaxValue;
					binding.ReceiveTimeout = TimeSpan.MaxValue;
					binding.SendTimeout = TimeSpan.MaxValue;
				}
				return binding;
			}
			else
			{
				var binding = new System.ServiceModel.BasicHttpBinding(System.ServiceModel.BasicHttpSecurityMode.TransportCredentialOnly);
				binding.Security.Transport.ClientCredentialType = model.ClientCredentialType; // System.ServiceModel.HttpClientCredentialType.Ntlm; // model.ClientCredentialType;
				binding.MaxReceivedMessageSize = int.MaxValue; // 10MB size limit on response to allow for larger PDFs (Valor por defecto: 65536)
				if (model.Timeout.HasValue)
				{
					if (model.Timeout == System.Threading.Timeout.Infinite)
					{
						binding.CloseTimeout = TimeSpan.MaxValue;
						binding.OpenTimeout = TimeSpan.MaxValue;
						binding.ReceiveTimeout = TimeSpan.MaxValue;
						binding.SendTimeout = TimeSpan.MaxValue;
					}
					else
					{
						binding.CloseTimeout = new TimeSpan(0, 0, model.Timeout.Value);
						binding.OpenTimeout = new TimeSpan(0, 0, model.Timeout.Value);
						binding.ReceiveTimeout = new TimeSpan(0, 0, model.Timeout.Value);
						binding.SendTimeout = new TimeSpan(0, 0, model.Timeout.Value);
					}
				}
				else
				{
					binding.CloseTimeout = TimeSpan.MaxValue;
					binding.OpenTimeout = TimeSpan.MaxValue;
					binding.ReceiveTimeout = TimeSpan.MaxValue;
					binding.SendTimeout = TimeSpan.MaxValue;
				}
				return binding;
			}
		}

		public static ReportService.ItemParameter[] GetReportParameters(ReportViewerModel model, bool forRendering = false)
		{
			ReportService.ItemParameter[] parameters;
			try
			{
				ReportViewerForCore.ReportService.TrustedUserHeader trusteduserHeader = null;

				var url = AddCharacterStartEnd(model.ServerUrl, false, true, "/") + "ReportService2010.asmx";

				var basicHttpBinding = _initializeHttpBinding(url, model);
				var service = new ReportService.ReportingService2010SoapClient(basicHttpBinding, new System.ServiceModel.EndpointAddress(url));
				service.ClientCredentials.Windows.AllowedImpersonationLevel = System.Security.Principal.TokenImpersonationLevel.Impersonation;
				service.ClientCredentials.Windows.ClientCredential = (System.Net.NetworkCredential)(model.Credentials ?? System.Net.CredentialCache.DefaultCredentials);

				string historyID = null;
				ReportService.ParameterValue[] values = null;
				ReportService.DataSourceCredentials[] rsCredentials = null;

				parameters = service.GetItemParametersAsync(trusteduserHeader, model.ReportPath, historyID, false, values, rsCredentials).Result.Parameters;
				//set it to load the not for rendering so that it's hopefully quicker than the whole regular call

				if (model != null && model.Parameters != null && model.Parameters.Any())
				{
					var tempParameters = new List<ReportService.ParameterValue>();
					foreach (var parameter in parameters)
					{
						if (model.Parameters.ContainsKey(parameter.Name))
						{
							var providedParameter = model.Parameters[parameter.Name];
							if (providedParameter != null)
							{
								foreach (var value in providedParameter.Where(x => !String.IsNullOrEmpty(x)))
								{
									tempParameters.Add(new ReportService.ParameterValue()
									{
										Label = parameter.Name,
										Name = parameter.Name,
										Value = value
									});
								}
							}
						}
					}

					values = tempParameters.ToArray();
				}

				parameters = service.GetItemParametersAsync(trusteduserHeader, model.ReportPath, historyID, forRendering, values, rsCredentials).Result.Parameters;

				return parameters;
			}
			catch 
			{
				return null;
			}
		}

		public static ReportExportResult ExportReportToFormat(ReportViewerModel model, ReportFormats format, int? startPage = 0, int? endPage = 0)
		{
			return ExportReportToFormat(model, format.GetName(), startPage, endPage);
		}

		public static ReportExportResult ExportReportToFormat(ReportViewerModel model, string format, int? startPage = 0, int? endPage = 0)
		{
			ReportExportResult exportResult = new ReportExportResult();
			try
			{
				string resultHTML;
				ReportViewerForCore.ReportExecutionService.TrustedUserHeader trusteduserHeader = null;

				var url = AddCharacterStartEnd(model.ServerUrl, false, true, "/") + "ReportExecution2005.asmx";
				var basicHttpBinding = _initializeHttpBinding(url, model);
				var service = new ReportExecutionService.ReportExecutionServiceSoapClient(basicHttpBinding, new System.ServiceModel.EndpointAddress(url));
				service.ClientCredentials.Windows.AllowedImpersonationLevel = System.Security.Principal.TokenImpersonationLevel.Impersonation;
				service.ClientCredentials.Windows.ClientCredential = (System.Net.NetworkCredential)(model.Credentials ?? System.Net.CredentialCache.DefaultCredentials);

				// https://stackoverflow.com/questions/44036903/using-reporting-services-ssrs-as-a-reference-in-an-asp-net-core-site/49202193
				service.Endpoint.EndpointBehaviors.Add(new ReportingServicesEndpointBehavior());

				var definedReportParameters = GetReportParameters(model, true);
				exportResult.CurrentPage = (startPage.ToInt32() <= 0 ? 1 : startPage.ToInt32());
				exportResult.SetParameters(definedReportParameters, model.Parameters);

				if (startPage == 0)
				{
					startPage = 1;
				}

				if (endPage == 0)
				{
					endPage = startPage;
				}

				if (string.IsNullOrWhiteSpace(format))
				{
					format = "HTML5";
				}

				string outputFormat = $"<OutputFormat>{format}</OutputFormat>";
				string encodingFormat = $"<Encoding>{model.Encoding.EncodingName}</Encoding>";
				
				/* Remueve tagas HTML, Body y otros, y retorna tabla para ser ebebida en una pagina */
				string htmlFragment = (((format.ToUpper() == "HTML4.0" || format.ToUpper() == "HTML5") && model.UseCustomReportImagePath == false && model.ViewMode == ReportViewModes.View) ? "<HTMLFragment>true</HTMLFragment>" : "");

				string deviceConfig = "<ExpandContent>true</ExpandContent><AccessibleTablix>g</AccessibleTablix>";
				deviceConfig += "<StyleStream>false</StyleStream><StreamRoot>/</StreamRoot>";
				deviceConfig = "<Parameters>Collapsed</Parameters>";

				var deviceInfo = $"<DeviceInfo>{outputFormat}{encodingFormat}<Toolbar>false</Toolbar>{htmlFragment}{deviceConfig}</DeviceInfo>";
				if (model.ViewMode == ReportViewModes.View && startPage.HasValue && startPage > 0)
				{
					if (model.EnablePaging)
					{
						deviceInfo = $"<DeviceInfo>{outputFormat}<Toolbar>false</Toolbar>{htmlFragment}{deviceConfig}<Section>{startPage}</Section></DeviceInfo>";
					}
					else
					{
						deviceInfo = $"<DeviceInfo>{outputFormat}<Toolbar>false</Toolbar>{htmlFragment}{deviceConfig}</DeviceInfo>";
					}
				}

				var reportParameters = new List<ReportExecutionService.ParameterValue>();
				foreach (var parameter in exportResult.Parameters)
				{
					bool addedParameter = false;
					foreach (var value in parameter.SelectedValues)
					{
						var reportParameter = new ReportExecutionService.ParameterValue();
						reportParameter.Name = parameter.Name;
						reportParameter.Value = value;
						reportParameters.Add(reportParameter);

						addedParameter = true;
					}

					if (!addedParameter)
					{
						var reportParameter = new ReportExecutionService.ParameterValue();
						reportParameter.Name = parameter.Name;
						reportParameters.Add(reportParameter);
					}
				}

				ReportViewerForCore.ReportExecutionService.ServerInfoHeader serverInfoHeader = new ReportViewerForCore.ReportExecutionService.ServerInfoHeader();
				ReportExecutionService.ExecutionHeader executionHeader = new ReportExecutionService.ExecutionHeader();
				ReportExecutionService.ExecutionInfo executionInfo = new ReportExecutionService.ExecutionInfo();
				ReportExecutionService.LoadReportResponse loadResponse = new ReportExecutionService.LoadReportResponse();
				ReportExecutionService.Render2Response render2Response;
				string historyID = null;
				string extension = null;
				string encoding = null;
				string mimeType = null;
				string[] streamIDs = null;
				ReportExecutionService.Warning[] warnings = null;

				try
				{
					//executionHeader = service.LoadReport(trusteduserHeader, model.ReportPath, historyID, out serverInfoHeader, out executionInfo);

					loadResponse = service.LoadReportAsync(trusteduserHeader, model.ReportPath, historyID).Result;
					executionInfo = loadResponse.executionInfo;
					executionHeader = loadResponse.ExecutionHeader;

					//var executionParameterResult = service.SetReportParameters(executionInfo.ExecutionID, reportParameters.ToArray(), "en-us").Result;
					serverInfoHeader = service.SetExecutionParameters(executionHeader, trusteduserHeader, reportParameters.ToArray(), "en-us", out executionInfo);

					if (model.EnablePaging)
					{
						var render2Request = new ReportExecutionService.Render2Request(executionHeader, trusteduserHeader, format, deviceInfo, ReportExecutionService.PageCountMode.Actual);
						//var render2Response = service.Render2(executionInfo.ExecutionID, render2Request).Result;
						render2Response = service.Render2Async(render2Request).Result;

						extension = render2Response.Extension;
						mimeType = render2Response.MimeType;
						encoding = render2Response.Encoding;
						warnings = render2Response.Warnings;
						streamIDs = render2Response.StreamIds;

						exportResult.ReportData = render2Response.Result;
					}
					else
					{
						var renderRequest = new ReportExecutionService.RenderRequest(executionHeader, trusteduserHeader, format, deviceInfo);
						//var renderResponse = service.Render(executionInfo.ExecutionID, renderRequest).Result;
						var renderResponse = service.RenderAsync(renderRequest).Result;

						extension = renderResponse.Extension;
						mimeType = renderResponse.MimeType;
						encoding = renderResponse.Encoding;
						warnings = renderResponse.Warnings;
						streamIDs = renderResponse.StreamIds;

						exportResult.ReportData = renderResponse.Result;
					}

					resultHTML = model.Encoding.GetString(exportResult.ReportData);
					//executionInfo = service.GetExecutionInfo(executionHeader.ExecutionID).Result;
				}
				catch (Exception ex2)
				{
					Console.WriteLine(ex2.Message);
				}

				exportResult.ExecutionInfo = executionInfo;
				exportResult.Format = format;
				exportResult.MimeType = mimeType;
				exportResult.StreamIDs = (streamIDs == null ? new List<string>() : streamIDs.ToList());
				exportResult.Warnings = (warnings == null ? new List<ReportExecutionService.Warning>() : warnings.ToList());

				if (executionInfo != null)
				{
					exportResult.TotalPages = executionInfo.NumPages;
				}

				resultHTML = model.Encoding.GetString(exportResult.ReportData);

				return exportResult;
			}
			catch (Exception ex)
			{
				Console.WriteLine(ex.Message);
				return exportResult;
			}
		}

		/// <summary>
		/// Searches a specific report for your provided searchText and returns the page that it located the text on.
		/// </summary>
		/// <param name="model"></param>
		/// <param name="searchText">The text that you want to search in the report</param>
		/// <param name="startPage">Starting page for the search to begin from.</param>
		/// <returns></returns>
		public static int? FindStringInReport(ReportViewerModel model, string searchText, int? startPage = 0)
		{
			try
			{
				int endPage;
				ReportViewerForCore.ReportExecutionService.TrustedUserHeader trusteduserHeader = null;

				var url = AddCharacterStartEnd(model.ServerUrl, false, true, "/") + "ReportExecution2005.asmx";

				var basicHttpBinding = _initializeHttpBinding(url, model);
				var service = new ReportExecutionService.ReportExecutionServiceSoapClient(basicHttpBinding, new System.ServiceModel.EndpointAddress(url));
				service.ClientCredentials.Windows.AllowedImpersonationLevel = System.Security.Principal.TokenImpersonationLevel.Impersonation;
				service.ClientCredentials.Windows.ClientCredential = (System.Net.NetworkCredential)(model.Credentials ?? System.Net.CredentialCache.DefaultCredentials);

				// https://stackoverflow.com/questions/44036903/using-reporting-services-ssrs-as-a-reference-in-an-asp-net-core-site/49202193
				service.Endpoint.EndpointBehaviors.Add(new ReportingServicesEndpointBehavior());

				var definedReportParameters = GetReportParameters(model, true);

				if (!startPage.HasValue || startPage == 0)
				{
					startPage = 1;
				}

				var exportResult = new ReportExportResult();
				exportResult.CurrentPage = startPage.ToInt32();
				exportResult.SetParameters(definedReportParameters, model.Parameters);

				var format = "HTML5";
				var outputFormat = $"<OutputFormat>{format}</OutputFormat>";
				var encodingFormat = $"<Encoding>{model.Encoding.EncodingName}</Encoding>";
				var htmlFragment = (((format.ToUpper() == "HTML4.0" || format.ToUpper() == "HTML5") && model.UseCustomReportImagePath == false && model.ViewMode == ReportViewModes.View) ? "<HTMLFragment>true</HTMLFragment>" : "");
				
				var deviceInfo = $"<DeviceInfo>{outputFormat}{encodingFormat}<Toolbar>False</Toolbar>{htmlFragment}</DeviceInfo>";
				if (model.ViewMode == ReportViewModes.View && startPage.HasValue && startPage > 0)
				{
					deviceInfo = $"<DeviceInfo>{outputFormat}<Toolbar>False</Toolbar>{htmlFragment}<Section>{startPage}</Section></DeviceInfo>";
				}

				var reportParameters = new List<ReportExecutionService.ParameterValue>();
				foreach (var parameter in exportResult.Parameters)
				{
					bool addedParameter = false;
					foreach (var value in parameter.SelectedValues)
					{
						var reportParameter = new ReportExecutionService.ParameterValue();
						reportParameter.Name = parameter.Name;
						reportParameter.Value = value;
						reportParameters.Add(reportParameter);

						addedParameter = true;
					}

					if (!addedParameter)
					{
						var reportParameter = new ReportExecutionService.ParameterValue();
						reportParameter.Name = parameter.Name;
						reportParameters.Add(reportParameter);
					}
				}

				ReportViewerForCore.ReportExecutionService.ServerInfoHeader serverInfoHeader = new ReportViewerForCore.ReportExecutionService.ServerInfoHeader();
				ReportExecutionService.ExecutionHeader executionHeader = new ReportExecutionService.ExecutionHeader();
				ReportExecutionService.ExecutionInfo executionInfo = new ReportExecutionService.ExecutionInfo();
				ReportExecutionService.LoadReportResponse loadResponse = new ReportExecutionService.LoadReportResponse();
				ReportExecutionService.Render2Response render2Response;
				string historyID = null;
				string extension = null;
				string encoding = null;
				string mimeType = null;
				string[] streamIDs = null;
				ReportExecutionService.Warning[] warnings = null;

				try
				{
					//executionHeader = service.LoadReport(trusteduserHeader, model.ReportPath, historyID, out serverInfoHeader, out executionInfo);
					loadResponse = service.LoadReportAsync(trusteduserHeader, model.ReportPath, historyID).Result;
					executionInfo = loadResponse.executionInfo;
					executionHeader = loadResponse.ExecutionHeader;

					//var executionParameterResult = service.SetReportParameters(executionInfo.ExecutionID, reportParameters.ToArray(), "en-us").Result;
					serverInfoHeader = service.SetExecutionParameters(executionHeader, trusteduserHeader, reportParameters.ToArray(), "en-us", out executionInfo);

					var render2Request = new ReportExecutionService.Render2Request(executionHeader, trusteduserHeader, format, deviceInfo, ReportExecutionService.PageCountMode.Actual);
					//var render2Response = service.Render2(executionInfo.ExecutionID, render2Request).Result;
					render2Response = service.Render2Async(render2Request).Result;

					extension = render2Response.Extension;
					mimeType = render2Response.MimeType;
					encoding = render2Response.Encoding;
					warnings = render2Response.Warnings;
					streamIDs = render2Response.StreamIds;

					// executionInfo = service.GetExecutionInfo(executionHeader.ExecutionID).Result;

					endPage = executionInfo.NumPages;
					if (endPage < 1)
					{
						endPage = startPage.Value;
					}

					return service.FindStringAsync(executionHeader, trusteduserHeader, startPage.Value, endPage, searchText).Result.PageNumber;
				}
				catch (Exception ex2)
				{
					Console.WriteLine(ex2.Message);
				}

				return 0;
			}
			catch (Exception ex)
			{
				Console.WriteLine(ex.Message);
				return 0;
			}
		}

		/// <summary>
		/// I'm using this method to run images through a "proxy" on the local site due to credentials used on the report being different than the currently running user.
		/// I ran into issues where my domain account was different than the user that executed the report so the images gave 500 errors from the website. Also my report server
		/// is only internally available so this solved that issue for me as well.
		/// </summary>
		/// <param name="model"></param>
		/// <param name="reportContent">This is the raw html output of your report.</param>
		/// <returns></returns>
		public static string ReplaceImageUrls(ReportViewerModel model, string reportContent)
		{
			try
			{
				var reportServerDomainUri = new Uri(model.ServerUrl);
				var searchForUrl = $"SRC=\"{reportServerDomainUri.Scheme}://{reportServerDomainUri.DnsSafeHost}/";
				//replace image urls with image data instead due to having issues accessing the images as a different authenticated user
				var imagePathIndex = reportContent.IndexOf(searchForUrl);
				while (imagePathIndex > -1)
				{
					var endIndex = reportContent.IndexOf("\"", imagePathIndex + 5);   //account for the length of src="
					if (endIndex > -1)
					{
						var imageUrl = reportContent.Substring(imagePathIndex + 5, endIndex - (imagePathIndex + 5));
						reportContent = reportContent.Replace(imageUrl, $"{String.Format(model.ReportImagePath, imageUrl)}");
					}

					imagePathIndex = reportContent.IndexOf(searchForUrl, imagePathIndex + 5);
				}

				return reportContent;
			}
			catch (Exception ex)
			{
				Console.WriteLine(ex.Message);
				return reportContent;
			}
		}
	}
}
