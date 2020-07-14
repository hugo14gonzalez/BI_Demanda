using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace ReportViewerForCore
{

	public class ReportExportResult
	{
		public int CurrentPage { get; set; }
		public List<string> StreamIDs { get; set; }
		public ReportExecutionService.ExecutionInfo ExecutionInfo { get; set; }
		public byte[] ReportData { get; set; }
		public string Format { get; set; }
		public ReportFormats FormatType { get { return this.Format.NameToEnum<ReportFormats>(); } }
		public string MimeType { get; set; }
		public List<ReportExecutionService.Warning> Warnings { get; set; }
		public int TotalPages { get; set; }
		public List<ReportParameterInfo> Parameters { get; set; }

		public ReportExportResult()
		{
			this.Parameters = new List<ReportParameterInfo>();
			this.StreamIDs = new List<string>();
			this.Warnings = new List<ReportExecutionService.Warning>();
		}

		internal void SetParameters(ReportService.ItemParameter[] definedReportParameters, Dictionary<string, string[]> userParameters)
		{
			ReportExecutionService.ParameterTypeEnum paramType;

			if (definedReportParameters != null)
			{
				foreach (var definedReportParameter in definedReportParameters)
				{
					var reportParameter = new ReportParameterInfo();
					reportParameter.AllowBlank = definedReportParameter.AllowBlank;
					reportParameter.Dependencies = definedReportParameter.Dependencies;
					reportParameter.MultiValue = definedReportParameter.MultiValue;
					reportParameter.Name = definedReportParameter.Name;
					reportParameter.Nullable = definedReportParameter.Nullable;
					reportParameter.Prompt = definedReportParameter.Prompt;
					reportParameter.PromptUser = ((definedReportParameter.PromptUser && !definedReportParameter.Prompt.HasValue()) ? false : definedReportParameter.PromptUser);
					if (!Enum.TryParse<ReportExecutionService.ParameterTypeEnum>(definedReportParameter.ParameterTypeName, out paramType))
					{
						paramType = ReportExecutionService.ParameterTypeEnum.String;
					}
					reportParameter.Type = paramType;

					if (definedReportParameter.ValidValues != null)
					{
						foreach (var validValue in definedReportParameter.ValidValues)
						{
							reportParameter.ValidValues.Add(new ValidValue(validValue.Label, validValue.Value));
						}
					}

					if (userParameters != null && userParameters.ContainsKey(definedReportParameter.Name))
					{
						reportParameter.SelectedValues = userParameters[definedReportParameter.Name].ToList();
					}
					else if (definedReportParameter.DefaultValues != null && definedReportParameter.DefaultValues.Any())
					{
						reportParameter.SelectedValues = definedReportParameter.DefaultValues.ToList();
					}

					if (!reportParameter.SelectedValues.Any() && reportParameter.Type == ReportExecutionService.ParameterTypeEnum.Boolean && !reportParameter.Nullable)
					{
						//Set the default value to false if it's a boolean parameter
						reportParameter.SelectedValues = new List<string>() { "False" };
					}

					this.Parameters.Add(reportParameter);
				}
			}
		}
	}
}
