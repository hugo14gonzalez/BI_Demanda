using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace ReportViewerForCore
{
	public enum ReportFormats
	{
		[EnumName("")]
		NotSet,

		/// <summary>
		/// XML file with report data
		/// </summary>
		[EnumName("XML")]
		XML,

		/// <summary>
		/// CSV (comma delimited)
		/// </summary>
		[EnumName("CSV")]
		CSV,

		/// <summary>
		/// Data Feed (rss)
		/// </summary>
		[EnumName("ATOM")]
		ATOM,

		/// <summary>
		/// PDF
		/// </summary>
		[EnumName("PDF")]
		PDF,

		/// <summary>
		/// Remote GDI+ file
		/// </summary>
		[EnumName("RGDI")]
		RGDI,

		/// <summary>
		/// HTML 4.0
		/// </summary>
		[EnumName("HTML4.0")]
		HTML4_0,

		/// <summary>
		/// HTML 4.0
		/// </summary>
		[EnumName("HTML5")]
		HTML5,

		/// <summary>
		/// MHTML (web archive)
		/// </summary>
		[EnumName("MHTML")]
		MHTML,

		/// <summary>
		/// Excel 2003 (.xls)
		/// </summary>
		[EnumName("EXCEL")]
		EXCEL,

		/// <summary>
		/// Excel (.xlsx)
		/// </summary>
		[EnumName("EXCELOPENXML")]
		EXCELOPENXML,

		/// <summary>
		/// RPL Renderer
		/// </summary>
		[EnumName("RPL")]
		RPL,

		/// <summary>
		/// TIFF file
		/// </summary>
		[EnumName("IMAGE")]
		IMAGE,

		/// <summary>
		/// PowerPoint
		/// </summary>
		[EnumName("PPTX")]
		PPTX,

		/// <summary>
		/// Word 2003 (.doc)
		/// </summary>
		[EnumName("WORD")]
		WORD,

		/// <summary>
		/// Word (.docx)
		/// </summary>
		[EnumName("WORDOPENXML")]
		WORDOPENXML,
	}

	public enum ReportViewModes
	{
		Export,
		Print,
		View
	}
}
