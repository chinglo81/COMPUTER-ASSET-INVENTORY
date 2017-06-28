using System;
using System.Data;

namespace CAIRS.Navigation
{
	/// <summary>
	/// Summary description for URLDataSet.
	/// </summary>
	[Serializable]
	public class UrlDataSet {
		public DataTable urlTable;
		public UrlDataSet() {
			urlTable = new DataTable("url");
			DataColumn idColumn = urlTable.Columns.Add("id");
			idColumn.AutoIncrement = true;
			idColumn.DataType = typeof(long);
			idColumn.Unique = true;
			DataColumn[] pKey = new DataColumn[1];
			pKey[0] = idColumn;
			urlTable.PrimaryKey = pKey;
			DataColumn urlColumn = urlTable.Columns.Add("urlstring");
			urlColumn.DataType = typeof(string);
		}
		public void RemoveOldestRow() {
			/*
			 * DataView dv = new DataView(urlTable);
			dv.Sort = "id";
			urlTable.Rows.Remove(dv[0].Row);
			*/
			urlTable.Rows.RemoveAt(0);
		}
	}
}
