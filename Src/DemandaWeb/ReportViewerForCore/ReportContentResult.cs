using System;
using System.Collections.Generic;
using System.Text;

namespace ReportViewerForCore
{
    public class ReportContentResult
    {
        public ReportContentResult() { }

        public ReportContentResult(int currentPage, int totalPages, string content)
        {
            this.CurrentPage = currentPage;
            this.TotalPages = totalPages;
            this.Content = content;
        }

        public int CurrentPage { get; set; }
        public int TotalPages { get; set; }
        public string Content { get; set; }
    }
}
