using System;
using System.Data;
using CAIRS.Exceptions;

namespace CAIRS.Navigation
{
	[Serializable]
	public class URLManager
	{
		public const int MAXSIZE = 30;
		public static UrlDataSet ds = new UrlDataSet();

		public URLManager() {
			ds = new UrlDataSet();
		}
		public static long InsertUrl(string sUrl) {
			DataRow urlRow = ds.urlTable.NewRow();
			urlRow["urlstring"] = sUrl;
			ds.urlTable.Rows.Add(urlRow);
			if(ds.urlTable.Rows.Count > MAXSIZE) {
				ds.RemoveOldestRow();
			}
			return (long)urlRow["id"];
		}
		public static string GetUrl(long id) {
			DataView dv = new DataView(ds.urlTable);
			if(id < 0 || ds.urlTable.Rows.Count == 0) {
				return "";
			}
			dv.RowFilter = "id = " + id;
			if(dv.Count == 0) {
				throw new NoPageInHistoryException("The page has been removed from the history");
			}
			return (string)dv[0]["urlstring"];
		}
		public static void SetUrl(long id, string sUrl) {
			DataView dv = new DataView(ds.urlTable);
			dv.RowFilter = "id = " + id;
			dv[0]["urlstring"] = sUrl;
		}
        public static void SetUrl(long id, MCSUrl url)
        {
			SetUrl(id, url.ToString());
		}

	}
}
