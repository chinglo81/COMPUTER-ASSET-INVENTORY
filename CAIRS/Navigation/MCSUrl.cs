using System;
using System.Collections;
using System.Web;
using System.Text;

namespace CAIRS.Navigation
{
	/// <summary>
	/// Summary description for MCSUrl.
	/// </summary>
	public class MCSUrl
	{
		private string url;
		/// <summary>
		/// Note: Do not use this.  This is for Copying the parameters from 
		/// one url to another.
		/// </summary>
		internal Hashtable _ht;
		//Note: DO not use "ReturnURL" that is used by Forms Authentication and it screws up the site.
		// Albert 01/23/04
		public const string ReturnUrl = "rtrnURL";

		#region Constructor
		/// <summary>
		/// Uses the url that is passed in.
		/// </summary>
		/// <param name="sUrl"></param>
		public MCSUrl(string sUrl) {
			_ht = new Hashtable();
			char[] splitChar = new char[1];
			splitChar[0] = '?';
			string[] parts = sUrl.Split(splitChar,2);
			url = parts[0];

			if(parts.Length > 1) {
				string sParams = parts[1];
				splitChar[0] = '&';
				parts = sParams.Split(splitChar);
				for(int i=0; i<parts.Length; i++) {
					splitChar[0] = '=';
					string[] nv = parts[i].Split(splitChar, 2);
					switch(nv.Length) {
						case 0:
							// do nothing: this shouldn't happen
							break;
						case 1:
							SetParameterUnencoded(nv[0], "");
							break;
						case 2:
							SetParameterUnencoded(nv[0], nv[1]);
							break;
						default:
							throw new Exception("This should really never happen.");
					}
				}
			}
		}

		#endregion

		#region Hastable stuff
		private Hashtable p_BuildQSArray(string[] sNameValues) {
			Hashtable htTemp = new Hashtable();
			string[] sarrTemp;

			for(int i=0;i < sNameValues.Length; i++) {
				sarrTemp = sNameValues[i].Split('=');
				if(sarrTemp.Length > 1)
					htTemp.Add(sarrTemp[0], sarrTemp[1]);
			}
			return htTemp;
		}

		#endregion

		#region Get and Set Parameter
		public void SetParameterUnencoded(string name, string val) {
			if(_ht.Contains(name.ToLower())) {
				_ht[name.ToLower()] = val;
			}
			else {
				_ht.Add(name.ToLower(), val);
			}
		}

		public void SetParameter(string name, string val) {
			string sNameLower = name.ToLower();
			if(_ht.Contains(sNameLower)) {
				_ht[sNameLower] = HttpUtility.UrlEncode(val);
			}
			else {
				_ht.Add(sNameLower, HttpUtility.UrlEncode(val));
			}
		}
		public void SetParameter(string name, long val) {
			SetParameter(name, val.ToString());
		}
		public void SetParameter(string name, bool val) {
			string sVal = val ? "true" : "false";

			SetParameter(name, sVal);
		}
		public class ParamHolder {
			private Hashtable _ht;
			internal ParamHolder(Hashtable ht) {
				_ht = ht;
			}

			public string this[string name] {
				get {
					return p_GetParameter(_ht, name);
				}
			}
		}
		public ParamHolder Params {
			get {
				return new ParamHolder(_ht);
			}
		}
		static string p_GetParameter(Hashtable ht, string name) {
			string sNameLower = name.ToLower();
			if(ht.Contains(sNameLower)) {
				return (string)ht[sNameLower];
			}
			else {
				return null;
			}
		}
		public string GetParameter(string name) {
			return p_GetParameter(_ht, name);
		}
		public string GetParameterUnencoded(string name) {
			string sNameLower = name.ToLower();
			if(_ht.Contains(sNameLower)) {
				return HttpUtility.UrlDecode((string)_ht[sNameLower]);
			}
			else {
				return null;
			}
		}

		#endregion

		#region Building the URL
		/// <summary>
		/// Note: this does not add the path or the session info.
		/// Use Build URL for that.
		/// </summary>
		/// <returns>the unaltered verison of the URL</returns>
		public override string ToString() {
			StringBuilder sb = new StringBuilder(url);
			IDictionaryEnumerator iDict = _ht.GetEnumerator();

			//only bother appending anything, if the hashtable has content
			if (_ht.Count > 0) {
				sb.Append("?");
				while(iDict.MoveNext()) {
					sb.Append((string)iDict.Key);
					sb.Append("=");
					sb.Append((string)iDict.Value);
					sb.Append("&");
				}
			}
			string sTemp = sb.ToString();

			if (sTemp.Substring(sTemp.Length - 1, 1) == "&")
				sTemp = sTemp.Substring(0, sTemp.Length - 1);

			return sTemp;
		}
		/// <summary>
		/// This will include the App Path and Session info.
		/// </summary>
		/// <param name="s">Session Object</param>
		/// <param name="r">Request Object</param>
		/// <returns>The full url that you can navigate to.</returns>
		public string BuildURL() {
			return Utilities.BuildURL(ToString());
		}
		public static void AppendQueryParam(ref string url, string parm, string val) {
			if (url.IndexOf("?") != -1) {
				url += "&";
			}
			else {
				url += "?";
			}
			url += parm + "=" + val;
		}
		#endregion

		#region Copy Params from one URL to another
		/// <summary>
		/// Note: This can be used to copy the parameters from one URL to another.
		/// </summary>
		/// <param name="oldURL"></param>
		public void CopyParameters(MCSUrl oldURL) {
			Hashtable htOld = oldURL._ht;
			foreach (object key in htOld.Keys) {
				_ht.Add(key, htOld[key]);
			}
		}
		#endregion
	}
}
