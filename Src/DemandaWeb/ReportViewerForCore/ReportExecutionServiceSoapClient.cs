/*
using System.Collections.Generic;
using System.Linq;
using System.Threading.Tasks;
using System.ServiceModel;

namespace ReportViewerForCore.ReportExecutionService
{
    public partial class ReportExecutionServiceSoapClient
    {
		public Task<int> FindString(string executionID, int startPage, int endPage, string findValue)
		{
			ExecutionHeader executionHeaderData = new ExecutionHeader()
			{
				ExecutionID = executionID,
				//ExecutionIDForWcfSoapHeader = executionID
			};
			TrustedUserHeader trusteduserHeader = new TrustedUserHeader();

			using (OperationContextScope context = SetMessageHeaders(executionID))
			{
				return Task<int>.FromResult(this.FindStringAsync(executionHeaderData, trusteduserHeader, startPage, endPage, findValue).Result.PageNumber);
			}
		}

		public Task<ExecutionInfo> GetExecutionInfo(string executionID)
		{
			ExecutionHeader executionHeaderData = new ExecutionHeader()
			{
				ExecutionID = executionID,
				//ExecutionIDForWcfSoapHeader = executionID
			};
			TrustedUserHeader trusteduserHeader = new TrustedUserHeader();

			using (OperationContextScope context = SetMessageHeaders(executionID))
			{
				return Task<ExecutionInfo>.FromResult(this.GetExecutionInfoAsync(executionHeaderData, trusteduserHeader).Result.executionInfo);
			}
		}

		public Task<RenderResponse> Render(string executionID, ReportExecutionService.RenderRequest request)
		{
			using (OperationContextScope context = SetMessageHeaders(executionID))
			{
				return this.RenderAsync(request);
			}
		}

		public Task<Render2Response> Render2(string executionID, ReportExecutionService.Render2Request request)
		{
			using (OperationContextScope context = SetMessageHeaders(executionID))
			{
				return this.Render2Async(request);
			}
		}

		public Task<ExecutionInfo> SetReportParameters(string executionID, IEnumerable<ParameterValue> parameterValues, string parameterLanguage)
		{
			ExecutionHeader executionHeaderData = new ExecutionHeader()
			{
				ExecutionID = executionID,
				//ExecutionIDForWcfSoapHeader = executionID
			};
			TrustedUserHeader trusteduserHeader = new TrustedUserHeader();

			using (OperationContextScope context = SetMessageHeaders(executionID))
			{
				ParameterValue[] parameterValuesArray = parameterValues.ToArray();
				if (parameterLanguage == null || parameterLanguage == "")
				{
					parameterLanguage = System.Globalization.CultureInfo.CurrentUICulture.Name;
				}

				return Task<ExecutionInfo>.FromResult(this.SetExecutionParametersAsync(executionHeaderData, trusteduserHeader, parameterValuesArray, parameterLanguage).Result.executionInfo);
			}
		}

		private OperationContextScope SetMessageHeaders(string executionID)
		{
			OperationContextScope context = new OperationContextScope(this.InnerChannel);

			ExecutionHeader executionHeaderData = new ExecutionHeader()
			{
				ExecutionID = executionID,
				//ExecutionIDForWcfSoapHeader = executionID
			};

#if true
			// add the ExecutionHeader entry to the soap headers
			OperationContext.Current.OutgoingMessageHeaders.Add(executionHeaderData.CreateMessageHeader());
#else
				// this does not appear to affect the soap headers
				OperationContext.Current.OutgoingMessageProperties.Add(ExecutionHeader.HeaderName, executionHeaderData);
#endif

			return context;
		}
	}
}
*/