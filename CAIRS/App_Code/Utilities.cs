using System;
using System.Collections;
using System.Collections.Specialized;
using System.Collections.Generic;
using System.Configuration;
using System.Data;
using System.Data.Odbc;
using System.Data.OleDb;
using System.Data.SqlClient;
using System.Diagnostics;
using System.IO;
using System.Net;
using System.Text;
using System.Web;
using System.Net.Mail;
using System.Web.SessionState;
using System.Web.UI;
using System.Web.UI.WebControls;
using System.Xml;
using System.Linq;
using System.Security.Principal;
using SQL = System.Data.SqlClient;
using CRYPT = System.Security.Cryptography;
using System.Security.Cryptography;
using CAIRS.Navigation;
using System.Text.RegularExpressions;
using Microsoft.Reporting.WebForms;
using Microsoft.ReportingServices;
using System.Threading;


namespace CAIRS
{
    /// <summary>
    /// Summary description for Utilities.
    /// </summary>
    public class Utilities
    {
        public static string GetSetLoggedOnUser = "";

        public static string GetSetAppOffline = "";

        public static string GetSetAppLoggingOff = "";

        //Encryption Key
        private static string key = "74DB3B81C971C57116FF4F2CCD1C7";

        public static string Encrypt(string toEncrypt, bool useHashing)
        {
            byte[] keyArray;
            byte[] toEncryptArray = UTF8Encoding.UTF8.GetBytes(toEncrypt);

            if (useHashing)
            {
                MD5CryptoServiceProvider hashmd5 = new MD5CryptoServiceProvider();
                keyArray = hashmd5.ComputeHash(UTF8Encoding.UTF8.GetBytes(key));
                hashmd5.Clear();
            }
            else
                keyArray = UTF8Encoding.UTF8.GetBytes(key);

            TripleDESCryptoServiceProvider tdes = new TripleDESCryptoServiceProvider();
            tdes.Key = keyArray;
            tdes.Mode = CipherMode.ECB;

            tdes.Padding = PaddingMode.PKCS7;
            ICryptoTransform cTransform = tdes.CreateEncryptor();

            byte[] resultArray = cTransform.TransformFinalBlock(toEncryptArray, 0, toEncryptArray.Length);
            tdes.Clear();

            return Convert.ToBase64String(resultArray, 0, resultArray.Length);
        }

        public static string Decrypt(string cipherString, bool useHashing)
        {
            byte[] keyArray;
            byte[] toEncryptArray = Convert.FromBase64String(cipherString);

            if (useHashing)
            {
                MD5CryptoServiceProvider hashmd5 = new MD5CryptoServiceProvider();
                keyArray = hashmd5.ComputeHash(UTF8Encoding.UTF8.GetBytes(key));
                hashmd5.Clear();
            }
            else
                keyArray = UTF8Encoding.UTF8.GetBytes(key);

            TripleDESCryptoServiceProvider tdes = new TripleDESCryptoServiceProvider();
            tdes.Key = keyArray;
            tdes.Mode = CipherMode.ECB;
            tdes.Padding = PaddingMode.PKCS7;

            ICryptoTransform cTransform = tdes.CreateDecryptor();
            byte[] resultArray = cTransform.TransformFinalBlock(toEncryptArray, 0, toEncryptArray.Length);
            tdes.Clear();
            return UTF8Encoding.UTF8.GetString(resultArray);
        }

        public static string StripPhoneChars(string str)
        {
            string s = str.Replace("(", "");
            s = s.Replace(")", "");
            s = s.Replace("-", "");
            s = s.Replace(" ", "");
            s = s.Replace(".", "");
            s = s.Replace("ext", "");
            s = s.Replace("EXT", "");
            s = s.Replace("Ext", "");
            s = s.Replace("x", "");
            s = s.Replace("X", "");
            s = s.Replace("/", "");
            return s;
        }
        
        public static string FormatPhoneNumber(string phone)
        {
            //also see function Prettyphonenumber
            string strippedPhone = StripPhoneChars(phone);

            if (strippedPhone.Length == 10)
            {
                return "(" + strippedPhone.Substring(0, 3) + ") " + strippedPhone.Substring(3, 3) + "-" + strippedPhone.Substring(6);
            }
            else
            {
                if (strippedPhone.Length > 10)
                {
                    return "(" + strippedPhone.Substring(0, 3) + ") " + strippedPhone.Substring(3, 3) + "-" + strippedPhone.Substring(6, 4) + " x" + strippedPhone.Substring(10);
                }
                if (strippedPhone.Length == 7)
                {
                    return strippedPhone.Substring(0, 3) + "-" + strippedPhone.Substring(3);
                }
                return strippedPhone;
            }
        }
        
        public static string FormatDollarAmount(double d)
        {
            return d.ToString("c");
        }
        
        public static string FormatDollarAmount(string s)
        {
            if (isNull(s))
            {
                return null;
            }
            decimal sDecimal = Convert.ToDecimal(s);
            sDecimal = decimal.Round(sDecimal, 2);
            return FormatDollarAmount(double.Parse(sDecimal.ToString()));
        }

        public static string GetRealLoggedOnUser()
        {
            string sUser = HttpContext.Current.User.Identity.Name;
            if (!isNull(sUser))
            {
                int pos = sUser.IndexOf("\\");
                if (pos >= 0)
                {
                    sUser = sUser.Substring(pos + 1).ToLower();
                }
                else
                {
                    sUser = sUser.ToLower();
                }
            }

            return sUser;
        }

        public static string GetLoggedOnUser()
        {
            string impersonateuser = GetSetLoggedOnUser;//GetAppSettingFromConfig("IMPERSONATE");
            string environment = GetAppSettingFromConfig("ENVIRONMENT").Trim().ToLower();
            string sUser = "";

            //Get Current logged on user
            sUser = GetRealLoggedOnUser();
            
            //If impersonate value is empty return the real logged on user
            if (isNull(impersonateuser))
            {
                return sUser;
            }
            else
            {
                //only impersonate if environment is not PRODUCTION
                if (!IsEnvironmentProductionMode())
                {
                    return impersonateuser;
                }
                return sUser;
            } 
        }

        public static string GetDocumentationFolderLocation()
        {
            string folder = @"\\MCS-APPS-TEST\C$\Project\CAIRS\Documentation\";
            string db_environment = GetAppSettingFromConfig("DB_SERVER").Trim().ToUpper();

            //Production Database
            if (db_environment.Equals("RENO-SQLIS"))
            {
                folder = @"\\MCS-APPS\C$\Project\CAIRS\Documentation";
            }

            return folder;
        }

        public static string GetAssetAttachmentFolderLocation()
        {
            string folder = @"\\MCS-APPS-TEST\C$\Project\CAIRS\Asset_Attachment";
            string db_environment = GetAppSettingFromConfig("DB_SERVER").Trim().ToUpper();

            //Production Database
            if (db_environment.Equals("RENO-SQLIS"))
            {
                folder = @"\\MCS-APPS\C$\Project\CAIRS\Asset_Attachment";
            }

            return folder;
        }

        public static string GetAppSettingFromConfig(string sKey)
        {
            return ConfigurationManager.AppSettings[sKey];
        }

        private static bool IsValidConfigKey(ArrayList arr_keys, ArrayList arr_values)
        {
            bool IsConfigKeysValid = true;
            string error_msg = "";

            //Check to see if both the array has the same number of counts
            if (!arr_keys.Count.Equals(arr_values.Count))
            {
                IsConfigKeysValid = false;
                error_msg = error_msg + "Array count mismatch: Key Array contains: " + arr_keys.Count.ToString() + " Value Array: " + arr_values.Count.ToString() + ", ";
            }

            string keys_not_exist = "";
            
            //Check to see if all the key exist. We are not creating any keys, it should just be updating
            foreach (string single_key in arr_keys)
            {
                //If key does not exist
                if (!ConfigurationManager.AppSettings.AllKeys.Contains(single_key))
                {
                    IsConfigKeysValid = false;
                    keys_not_exist = keys_not_exist + single_key + ", ";
                }
            }

            //If any of the keys does not exist
            if (!isNull(keys_not_exist))
            {
                //remove last comma
                keys_not_exist = "The following key(s) does not exist: " + keys_not_exist.Substring(0, keys_not_exist.Length - 2);
                error_msg = error_msg + keys_not_exist;
            }

            Assert(IsConfigKeysValid, error_msg);

            return IsConfigKeysValid;
        }

        public static void RemoveAssetTempFolderByID(string asset_id)
        {
            string root_folder = GetAssetAttachmentFolderLocation() + "\\TEMP\\" + asset_id;
            if (Directory.Exists(root_folder))
            {
                //delete all files in root
                string[] files_in_root = Directory.GetFiles(root_folder);
                foreach (string single_file_in_root in files_in_root)
                {
                    File.Delete(single_file_in_root);
                }

                //check to see if there are any other folders to delete
                string[] folders = Directory.GetDirectories(root_folder);

                //loop thru the folder in root
                foreach (string folder in folders)
                {
                    string[] files = Directory.GetFiles(folder);
                    foreach (string file in files)
                    {
                        File.Delete(file);
                    }
                    //delete sub folder
                    Directory.Delete(folder);
                }

                //delete root folder
                Directory.Delete(root_folder);
            }
        }

        public static void UpdateConfigKeys(ArrayList arr_keys, ArrayList arr_values)
        {
            //don't process if there are no array values
            if (arr_keys.Count.Equals(0))
            {
                return;
            }

            if (IsValidConfigKey(arr_keys, arr_values))
            {
                string appsettings = "appSettings";

                Configuration objConfig = System.Web.Configuration.WebConfigurationManager.OpenWebConfiguration("~");
                AppSettingsSection config_AppSettings = (AppSettingsSection)objConfig.GetSection(appsettings);
                
                //loop thru your array of keys being pass in and set the value
                for (int iAppSetting = 0; iAppSetting < arr_keys.Count; iAppSetting++)
                {
                    if (config_AppSettings != null)
                    {
                        config_AppSettings.Settings[arr_keys[iAppSetting].ToString()].Value = arr_values[iAppSetting].ToString();
                        objConfig.Save();
                    }
                }

                //refresh appsettings
                ConfigurationManager.RefreshSection(appsettings);
            }
        }

        public static bool isNull(string s)
        {
            if (String.IsNullOrEmpty(s))
            {
                return true;
            }
            return String.IsNullOrEmpty(s.Trim());
        }
        
        public static string getDbValueNull(string value)
        {
            if (!isNull(value))
            {
                return value;
            }
            return Constants.MCSDBNULL;
        }
        
        public static string GetAppPathURL()
        {
            string tmpURL = "";
            HttpRequest r = HttpContext.Current.Request;
            if (r.ServerVariables["HTTPS"].ToLower() == "on")
                tmpURL = "https://";
            else
                tmpURL = "http://";

            tmpURL += r.ServerVariables["SERVER_NAME"] + r.ApplicationPath;
            return tmpURL;
        }
        
        public static string GetAppPathURL(HttpRequest request)
        {
            string tmpURL = "";
            HttpRequest r = HttpContext.Current.Request;
            if (request.ServerVariables["HTTPS"].ToLower() == "on")
                tmpURL = "https://";
            else
                tmpURL = "http://";

            tmpURL += request.ServerVariables["SERVER_NAME"] + r.ApplicationPath;
            return tmpURL;
        }

        private static string p_ConvertURL(string sURL)
        {
            Uri u = new Uri(sURL);
            return u.AbsoluteUri;
        }

        public static string BuildURL(string url)
        {
            //this function takes a url that a user is going to use and appends
            // the session id, account id, and user id to it.
            string tempAppPathUrl = GetAppPathURL();

            if (tempAppPathUrl.Length > 2)
            {
                if (tempAppPathUrl.LastIndexOf("/") == tempAppPathUrl.Length - 1)
                {
                    tempAppPathUrl = tempAppPathUrl.Substring(0, tempAppPathUrl.Length - 1);
                }
            }
            url = tempAppPathUrl + url;

            return p_ConvertURL(url);
        }

        public static string BuildURL(string url, HttpRequest request)
        {
            //this function takes a url that a user is going to use and appends
            // the session id, account id, and user id to it.
            string tempAppPathUrl = GetAppPathURL(request);

            if (tempAppPathUrl.Length > 2)
            {
                if (tempAppPathUrl.LastIndexOf("/") == tempAppPathUrl.Length - 1)
                {
                    tempAppPathUrl = tempAppPathUrl.Substring(0, tempAppPathUrl.Length - 1);
                }
            }
            url = tempAppPathUrl + url;

            return p_ConvertURL(url);
        }

        public static bool VerifyPassword(string sPass)
        {
            bool HasUpperCase = false;
            bool HasLowerCase = false;
            bool HasNumber = false;
            bool Has8characters = false;

            if (sPass.Length == 8)
            {
                Has8characters = true;
            }

            for (int i = 0; i < sPass.Length; i++)
            {
                if (char.IsUpper(sPass[i]))
                {
                    HasUpperCase = true;
                }
                if (char.IsLower(sPass[i]))
                {
                    HasLowerCase = true;
                }
                if (char.IsNumber(sPass[i]))
                {
                    HasNumber = true;
                }
            }

            if (Has8characters && HasUpperCase && HasLowerCase && HasNumber)
            {
                return true;
            }
            else
            {
                return false;
            }
        }
        
        public static void Assert(bool b)
        {
            if (!b)
            {
                throw new Exception("Assertion Failed");
            }
        }
        
        public static void Assert(bool b, string message)
        {
            if (!b)
            {
                throw new Exception("Assertion Failed: " + message);
            }
        }
        
        public static string FormatDate(DateTime dt)
        {
            return dt.ToShortDateString();
        }
        
        public static string FormatNumMonth(int NumDate)
        {
            if (isNull(NumDate.ToString()))
            {
                return "";
            }
            if (NumDate == 1)
            {
                return "Jan";
            }
            if (NumDate == 2)
            {
                return "Feb";
            }
            if (NumDate == 3)
            {
                return "Mar";
            }
            if (NumDate == 4)
            {
                return "Apr";
            }
            if (NumDate == 5)
            {
                return "May";
            }
            if (NumDate == 6)
            {
                return "Jun";
            }
            if (NumDate == 7)
            {
                return "Jul";
            }
            if (NumDate == 8)
            {
                return "Aug";
            }
            if (NumDate == 9)
            {
                return "Sep";
            }
            if (NumDate == 10)
            {
                return "Oct";
            }
            if (NumDate == 11)
            {
                return "Nov";
            }
            if (NumDate == 12)
            {
                return "Dec";
            }
            return NumDate.ToString();
        }
        
        public static string FormatTime(string sTime)
        {
            if (isNull(sTime))
            {
                return "";
            }
            return FormatTime(DateTime.Parse(sTime));
        }
        
        public static string FormatTime(DateTime sDate)
        {
            return sDate.ToShortTimeString();
        }

        public static string FormatDate(string sDate)
        {
            if (isNull(sDate))
            {
                return "";
            }
            return FormatDate(DateTime.Parse(sDate));
        }

        public static string FormatDateTime(DateTime dt)
        {
            return FormatDate(dt) + " " + dt.Hour.ToString().PadLeft(2, '0')
                + ":" + dt.Hour.ToString().PadLeft(2, '0');
        }

        public static string FormatDateTime(string sDate)
        {
            if (isNull(sDate))
            {
                return "";
            }
            return FormatDateTime(DateTime.Parse(sDate));
        }

        public static bool IsEnvironmentProductionMode()
        {
            return GetAppSettingFromConfig("ENVIRONMENT").ToLower().Trim() == Constants.ENVIRONMENT_PROD.ToLower().Trim();
        }

        public static bool IsEnvironmentQAMode()
        {
            return GetAppSettingFromConfig("Environment").ToLower() == Constants.ENVIRONMENT_QA;
        }

        public static bool IsEnvironmentDEVMode()
        {
            return GetAppSettingFromConfig("Environment").ToLower() == Constants.ENVIRONMENT_DEV;
        }

        /// <summary>
        /// send email
        /// </summary>
        /// <param name="to">receiver</param>
        /// <param name="subject">subject</param>
        /// <param name="body">email body</param>
        /// <param name="attachments">attachement as a list of string</param>
        /// <returns>true if email sent, false otherwise</returns>
        public static bool SendEmail(string to, string subject, string body, string[] attachments, bool isHtml)
        {
            try
            {
                // get the current real user login id to send email
                string qaEmail = GetRealLoggedOnUser() + "@" + GetAppSettingFromConfig("EMAIL_DOMAIN");
                string qaMessage = string.Empty;

                if (!IsEnvironmentProductionMode())
                {
                    qaMessage = "<p style='color:red'>QA MODE: This message is intended to send to: " + (to + "@" + GetAppSettingFromConfig("EMAIL_DOMAIN")) + "</p>";
                    to = qaEmail;
                }
                else {
                    to = to + "@" + GetAppSettingFromConfig("EMAIL_DOMAIN");
                }

                string from = GetAppSettingFromConfig("EMAIL_FROM");

                // get the mail server settings from config.ini file
                string mailServer = GetAppSettingFromConfig("EMAIL_SERVER");
                int port = int.Parse(GetAppSettingFromConfig("EMAIL_PORT"));

                MailMessage email = new MailMessage(from, to);
                email.Subject = subject;
                email.Body = qaMessage + body + EmailSignature();
                email.IsBodyHtml = isHtml;

                // send bcc copy of email to QA admin
                string emailForQA = GetAppSettingFromConfig("EMAIL_BCC_FOR_QA");
                if (!isNull(emailForQA)) 
                { 
                    email.Bcc.Add(emailForQA);
                }

                // add attachments
                if (attachments != null)
                {
                    foreach (string attach in attachments)
                        email.Attachments.Add(new Attachment(attach));
                }

                string sITSWorkerUser = Decrypt(GetAppSettingFromConfig("ITS_USER"), true);
                string sPW = Decrypt(GetAppSettingFromConfig("ITS_USER_PW"), true);

                SmtpClient smtp = new SmtpClient(mailServer, port);
                smtp.Credentials = new System.Net.NetworkCredential(sITSWorkerUser, sPW);

                smtp.Send(email);

                string recordtype = Constants.SECURITY_RECORDTYPE_STANDARD_OPERATION;
                string module = Constants.CAIRS_APP_MODULE_SEND_EMAIL;

                //Save Email Event
                Utilities.LogEvent(
                    recordtype,
                    module,
                    to
                );


                return true;
            }
            catch (Exception)
            {
                return false;
            }
        }

        public static void Log_App_Activity(HttpRequest r)
        {
            string url = r.Url.ToString();
            string page_name = Path.GetFileName(r.Path);
            string page_parameter = r.Url.Query;
            string emp_id = Utilities.GetEmployeeIdByLoggedOn(GetLoggedOnUser());
            string date = DateTime.Now.ToString();

            DatabaseUtilities.Insert_App_Activity(
                url,
                page_name,
                page_parameter,
                emp_id,
                date
            );

        }

        public static void LogEvent(string recordtype, string module, string description)
        {
            string p_appid = GetApplicationID();
            string p_recordtype = recordtype;
            string p_module = module;
            string p_description = description;
            string p_userid = GetLoggedOnUser();
            string p_usermachinename = Dns.GetHostEntry(HttpContext.Current.Request.UserHostAddress).HostName;
            string p_useripaddress = HttpContext.Current.Request.UserHostAddress;

            DatabaseUtilities.Insert_Log_Event(
                 p_appid,
                 p_recordtype,
                 p_module,
                 p_description,
                 p_userid,
                 p_usermachinename,
                 p_useripaddress
             );
        }

        public static string RecordApplicationException(Exception exc)
        {
            string p_application_name = GetAppSettingFromConfig("APPLICATION_NAME");
            string p_pagename = HttpContext.Current.Request.Url.ToString();
            string p_exceptiontype = "Type Not Available";
            string p_stacktrace = "Stack Trace Not Available";
            string p_exceptionmessage = "Message Not Available";
            string p_exceptiondate = DateTime.Now.ToString();
            string p_networklogin = GetLoggedOnUser();
            string p_machinename = "";
            string p_ipaddress = "";

            //exceptionmessage
            if (exc.Message != null)
            {
                p_exceptionmessage = exc.Message;
                p_exceptiontype = exc.GetType().Name;
                p_stacktrace = exc.StackTrace;
            }
            //machinename
            try
            {
                IPHostEntry host = Dns.GetHostEntry(HttpContext.Current.Request.UserHostAddress);
                p_machinename = host.HostName;
                p_ipaddress = HttpContext.Current.Request.UserHostAddress;
            }
            catch
            {
                p_machinename = "NOT_FOUND";
                p_ipaddress = "NOT_FOUND";
            }

            string id = DatabaseUtilities.Insert_Security_SP_Insert_Application_Exceptions(
                p_application_name,
                p_pagename,
                p_exceptiontype,
                p_stacktrace,
                p_exceptionmessage,
                p_exceptiondate,
                p_networklogin,
                p_machinename,
                p_ipaddress
            );

            return id;
        }

        public static string RecordEmailException(Exception exc, string to, string cc, string bcc, string from, string subject, string body, bool isHTML, string loggedOnUser)
        {
            /*DO_Security.EMailEvents record = new DO_Security.EMailEvents();
            record.Recipient = to;
            record.CCRecipient = cc;
            record.BCCRecipient = bcc;
            record.Sender = from;
            record.Subject = subject;
            record.Body = body;
            if (isHTML == true)
            {
                record.MailFormat = "HTML";
            }
            else
            {
                record.MailFormat = "TEXT";
            }
            record.FirstSendAttempt = DateTime.Now.ToString();
            record.SentFlag = "0";
            record.NetworkLogin = loggedOnUser;
            if (exc != null && !isNull(exc.ToString()))
            {

                if (exc.Message != null)
                {
                    record.ExceptionMessage = exc.Message;
                }
                else
                {
                    record.ExceptionMessage = "Message Not Available";
                }
                if (exc.GetType().Name != null)
                {
                    record.ExceptionType = exc.GetType().Name;
                }
                else
                {
                    record.ExceptionType = "Type Not Available";
                }

            }
            else
            {
                record.ExceptionType = "Type Not Available";
                record.ExceptionMessage = "Message Not Available";
            }
            record.ExceptionDate = DateTime.Now.ToString();

            record.Insert();

            return record.Id;
             * */

            return "";
        }

        public static string ConvertCheckBoxToBitField(System.Web.UI.WebControls.CheckBox chk)
        {
            if (chk.Checked)
            {
                return "1";
            }
            else
            {
                return "0";
            }
        }

        public static double Round(double val, int digits)
        {
            // preround
            val = Math.Round(val, digits + 2);
            // real round
            int multiplier = (int)Math.Pow(10, digits);
            val = val * multiplier;
            val = Math.Floor(val + .5);
            val = val / multiplier;
            return val;
        }

        /// <summary>
        /// Removes the prefixed "10" from the employee id
        /// </summary>
        /// <param name="empId"></param>
        /// <returns></returns>
        public static string stripEmpId(string empId)
        {
            if (empId.StartsWith("10"))
            {
                empId = empId.Substring(2);
            }
            return empId;
        }

        /// <summary>
        /// identify if the input string is numeric
        /// </summary>
        /// <param name="str">input string</param>
        /// <returns>true if numeric, false otherwise</returns>
        public static bool IsNumeric(string text)
        {
            if (!isNull(text))
            {
                int n;
                return int.TryParse(text.Trim(), out n);
            }
            return true;
        }

        /// <summary>
        /// email signature
        /// </summary>
        /// <returns></returns>
        public static string EmailSignature()
        {
            return File.ReadAllText(AppDomain.CurrentDomain.BaseDirectory + ConfigurationManager.AppSettings["EMAIL_SIGNATURE"].ToString());
        }

        public static void WriteTraceLine(string message)
        {
            DateTime now = DateTime.Now;

            Trace.WriteLine(now.ToShortDateString() + " " + now.ToShortTimeString() + message);
        }

        public static string GetApplicationID()
        {
            DataSet ds = DatabaseUtilities.DsGetCAIRSAppInfo();
            if (ds.Tables[0].Rows.Count > 0)
            {
                return ds.Tables[0].Rows[0]["ID"].ToString();
            }
            return "";
        }

        public static string GetApplicationName()
        {
            string appname = GetAppSettingFromConfig("APPLICATION_NAME");
            if (!isNull(appname))
            {
                return appname;
            }
            return "";
        }

        public static string GetApplicationHomePage(string appid)
        {
            string homepage = ConfigurationManager.AppSettings["APPLICATION_HOMEPAGE"];
            if (!isNull(homepage))
            {
                return homepage;
            }
            return "";
        }

        public static string GetURLFolderLocation()
        {
            string folder = ConfigurationManager.AppSettings["URLFOLDERLOCATION"];
            if (!isNull(folder))
            {
                return folder;
            }
            return "";
        }

        public static URLManager GetURLManagerFromSession(HttpSessionState Session)
        {
            const string URLMANAGER = "urlmanager";
            URLManager um = Session[URLMANAGER] as URLManager;
            if (um == null)
            {
                um = new URLManager();
                Session[URLMANAGER] = um;
            }

            return um;
        }

        public static string ConcatWithComma(string sStr1, string sStr2)
        {
            //concatenate 2 strings with an intervning comma unless oen of teh strinds is null.
            string sResult = sStr1;
            if (!isNull(sStr1) && !isNull(sStr2))
                sResult += ", ";
            sResult += sStr2;
            return sResult;
        }

        public static string getApplicationNameById(string appid)
        {
            string sSQL = "Select * from apps where id = '" + appid + "'";
            DataSet ds = DatabaseUtilities.ExecuteSQLStatement("security", sSQL);
            if (ds.Tables[0].Rows.Count > 0)
            {
                return ds.Tables[0].Rows[0]["appname"].ToString();
            }
            return "";
        }

        public static string ToProperCase(string mText)
        {
            string rText = "";
            if (!isNull(mText))
            {
                mText = mText.ToLower();
                try
                {
                    System.Globalization.CultureInfo cultureInfo = System.Threading.Thread.CurrentThread.CurrentCulture;
                    System.Globalization.TextInfo TextInfo = cultureInfo.TextInfo;
                    rText = TextInfo.ToTitleCase(mText);
                }
                catch
                {
                    rText = mText;
                }
            }
            return rText;
        }

        public static bool isElementaryStudent(string studentid)
        {
            ArrayList paramNames = new ArrayList();
            ArrayList paramValues = new ArrayList();
            paramNames.Add("studentId");
            paramValues.Add(studentid);
            DataSet ds = DatabaseUtilities.ExecuteStoredProc("DataWarehouse", "procGetStudentInfo", paramNames, paramValues);
            if (ds.Tables[0].Rows.Count > 0)
            {
                string grade = ds.Tables[0].Rows[0]["grade"].ToString();
                if ((grade == "KN" || grade == "PS") || Convert.ToInt16(grade) <= 6)
                {
                    return true;
                }
                else
                {
                    return false;
                }
            }
            else
            {
                return false;
            }
        }

        public static bool isJHSStudent(string studentid)
        {
            ArrayList paramNames = new ArrayList();
            ArrayList paramValues = new ArrayList();
            paramNames.Add("studentId");
            paramValues.Add(studentid);
            DataSet ds = DatabaseUtilities.ExecuteStoredProc("DataWarehouse", "procGetStudentInfo", paramNames, paramValues);
            if (ds.Tables[0].Rows.Count > 0)
            {
                string grade = ds.Tables[0].Rows[0]["grade"].ToString();
                if (grade == "07" || grade == "08")
                {
                    return true;
                }
                else
                {
                    return false;
                }
            }
            else
            {
                return false;
            }
        }

        public static bool isK8Student(string studentid)
        {
            //must equate to a student who would be in Power school K8 district 
            ArrayList paramNames = new ArrayList();
            ArrayList paramValues = new ArrayList();
            paramNames.Add("studentId");
            paramValues.Add(studentid);
            DataSet ds = DatabaseUtilities.ExecuteStoredProc("DataWarehouse", "procGetStudentInfo", paramNames, paramValues);
            if (ds.Tables[0].Rows.Count > 0)
            {
                string grade = ds.Tables[0].Rows[0]["grade"].ToString();
                if ((grade == "KN" || grade == "PS") || Convert.ToInt16(grade) <= 8)
                {
                    return true;
                }
                else
                {
                    return false;
                }
            }
            else
            {
                return false;
            }
        }

        public static bool isHSStudent(string studentid)
        {
            //must equate to a studnet who would eb in Power school High School district 
            ArrayList paramNames = new ArrayList();
            ArrayList paramValues = new ArrayList();
            paramNames.Add("studentId");
            paramValues.Add(studentid);
            DataSet ds = DatabaseUtilities.ExecuteStoredProc("DataWarehouse", "procGetStudentInfo", paramNames, paramValues);
            if (ds.Tables[0].Rows.Count > 0)
            {
                string grade = ds.Tables[0].Rows[0]["grade"].ToString();
                if ((grade == "KN" || grade == "PS") || Convert.ToInt16(grade) <= 8)
                {
                    return false;
                }
                else
                {
                    return true;
                }
            }
            else
            {
                return true;
            }
        }

        public static string GetStudentNameByID(string studentid)
        {
            //must equate to a studnet who would eb in Power school High School district 
            ArrayList paramNames = new ArrayList();
            ArrayList paramValues = new ArrayList();
            paramNames.Add("studentId");
            paramValues.Add(studentid);
            DataSet ds = DatabaseUtilities.ExecuteStoredProc("DataWarehouse", "procGetStudentInfo", paramNames, paramValues);
            if (ds.Tables[0].Rows.Count > 0)
            {
                string student_name = ds.Tables[0].Rows[0]["Student_Name_ID"].ToString();
                if(!isNull(student_name))
                {
                    return student_name;
                }
            }
            return "";
        }

        public static string GetStudentIDAssignByTransactionID(string asset_student_transaction_id)
        {
            DataSet ds = DatabaseUtilities.DsGetByTableColumnValue(Constants.DB_VIEW_ASSET_STUDENT_ASSIGNMENT, Constants.COLUMN_V_ASSET_STUDENT_ASSIGNMENT_ID, asset_student_transaction_id, "");
            if (ds.Tables[0].Rows.Count > 0)
            {
                return ds.Tables[0].Rows[0][Constants.COLUMN_V_ASSET_STUDENT_ASSIGNMENT_Student_ID].ToString();
            }
            return "";
        }

        //Exporting To Excel
        public static void ExportDataGridToExcel(DataGrid dg, HttpResponse Response, string filename)
        {
            Response.Buffer = true;
            Response.ClearContent();
            Response.ClearHeaders();

            Response.ContentType = "application/vnd.ms-excel";
            Response.AddHeader("content-disposition", "attachment;filename=" + filename + ".xls");

            StringWriter sw = new StringWriter();
            HtmlTextWriter hw = new HtmlTextWriter(sw);

            dg.RenderControl(hw);

            //---Utilize the Response Object to write the StringWriter to the page
            Response.Write(sw.ToString());
            Response.Flush();
            Response.Close();
            Response.End();
        }

        public static void ExportDataTableToExcel(DataTable dt, HttpResponse Response, string fileName)
        {
            StringBuilder sb = new StringBuilder();
            ArrayList arrList = new ArrayList();
            foreach (DataColumn c in dt.Columns)
            {
                sb.Append(c.ColumnName + ",");
                arrList.Add(c.ColumnName);
            }
            sb.Append("\n");

            foreach (DataRow row in dt.Rows)
            {
                bool firstColumn = true;
                foreach (DataColumn dc in dt.Columns)
                {
                    if (firstColumn)
                    {
                        firstColumn = false;
                        sb.Append("\"" + row[dc.ColumnName].ToString() + "\"");
                    }
                    else
                    {
                        sb.Append(",\"" + row[dc.ColumnName].ToString() + "\"");
                    }
                }
                sb.Append("\n");
            }
            Response.Clear();
            Response.Buffer = true;
            Response.AddHeader("Content-Disposition", "inline;filename=" + fileName + ".csv");
            Response.AddHeader("Content-Type", "application/Excel");
            Response.ContentType = "text/csv";
            Response.Write(sb.ToString());
            Response.End();
        }

        public static void ExportDataSetToExcel(DataSet ds, HttpResponse Response, ListItemCollection collection, string filename)
        {
            StringBuilder sbNames = new StringBuilder();
            sbNames.Append(getCollectionList(collection, false, ","));

            ExportDataSetToExcel(ds, Response, sbNames, arrListFromListItemCollection(collection, true), filename);

        }

        public static void ExportDataSetToExcel(DataSet ds, HttpResponse Response, string fileName)
        {
            StringBuilder sb = new StringBuilder();
            ArrayList arrList = new ArrayList();
            foreach (DataColumn c in ds.Tables[0].Columns)
            {
                sb.Append(c.ColumnName + ",");
                arrList.Add(c.ColumnName);
            }
            ExportDataSetToExcel(ds, Response, sb, arrList, fileName);

        }

        public static void ExportDataSetToExcel(DataSet ds, HttpResponse Response, StringBuilder sbNiceNamesToDisplay, ArrayList arrColumnNames, string filename)
        {
            StringBuilder sb = new StringBuilder();

            sb.Append(sbNiceNamesToDisplay.ToString());
            sb.Append("\n");

            foreach (DataRow row in ds.Tables[0].Rows)
            {
                bool firstColumn = true;

                foreach (String item in arrColumnNames)
                {
                    string sValue = row[item].ToString().Replace("\"", "''");
                    if (firstColumn)
                    {
                        firstColumn = false;
                        sb.Append("\"" + sValue + "\"");
                    }
                    else
                    {
                        sb.Append(",\"" + sValue + "\"");
                    }
                }
                sb.Append("\n");
            }

            Response.Clear();
            Response.Buffer = true;
            Response.AddHeader("Content-Disposition", "inline;filename=" + filename + ".csv");
            Response.AddHeader("Content-Type", "application/Excel");
            Response.ContentType = "text/csv";
            Response.Write(sb.ToString());
            Response.End();

        }

        /// <summary>
        /// Sort Drop Down List in alpha order
        /// </summary>
        /// <param name="ddl">Drop Down List ID</param>
        public static void sortDDL(DropDownList ddl)
        {
            ArrayList textList = new ArrayList();
            ArrayList valueList = new ArrayList();

            foreach (ListItem li in ddl.Items)
            {
                textList.Add(li.Text);
            }

            textList.Sort();

            foreach (object item in textList)
            {
                string value = ddl.Items.FindByText(item.ToString()).Value;
                valueList.Add(value);
            }
            ddl.Items.Clear();

            for (int i = 0; i < textList.Count; i++)
            {
                ListItem objItem = new ListItem(textList[i].ToString(), valueList[i].ToString());
                ddl.Items.Add(objItem);
            }

        }

        /// <summary>
        /// Return a list of values in a listbox control
        /// </summary>
        /// <param name="lstBox">listbox ID</param>
        /// <param name="isReturnOnlySelectedValue">Do you only want to return selected values</param>
        /// <param name="returnValue">True will return you value, False will return you name</param>
        /// <param name="separator">Separator for each of the values</param>
        /// <returns></returns>
        public static string buildListInListBox(ListBox lstBox, bool isReturnOnlySelectedValue, bool returnValue, string separator)
        {
            string list = "";
            foreach (ListItem item in lstBox.Items)
            {
                if (isReturnOnlySelectedValue)
                {
                    if (item.Selected)
                    {
                        if (returnValue)
                        {
                            list += item.Value + separator;
                        }
                        else
                        {
                            list += item.Text + separator;
                        }
                    }
                }
                else
                {
                    if (returnValue)
                    {
                        list += item.Value + separator;
                    }
                    else
                    {
                        list += item.Text + separator;
                    }
                }
            }
            if (!isNull(list))
            {
                list = list.Substring(0, list.Length - separator.Length);
            }
            return list;
        }

        /// <summary>
        /// Return a list of values in a drop down list
        /// </summary>
        /// <param name="lstBox">listbox ID</param>
        /// <param name="isReturnOnlySelectedValue">Do you only want to return selected values</param>
        /// <param name="returnValue">True will return you value, False will return you name</param>
        /// <param name="separator">Separator for each of the values</param>
        /// <returns></returns>
        public static string buildListInDropDownList(DropDownList ddl, bool returnValue, string separator)
        {
            string list = "";
            foreach (ListItem item in ddl.Items)
            {
                if (returnValue)
                {
                    list += item.Value + separator;
                }
                else
                {
                    list += item.Text + separator;
                }
            }
            if (!isNull(list))
            {
                list = list.Substring(0, list.Length - separator.Length);
            }
            return list;
        }

        /// <summary>
        /// Return a list of values in collection
        /// </summary>
        /// <param name="collection">Collection ID</param>
        /// <param name="returnValue">True will return value, False will return you the name</param>
        /// <param name="separator">Separator for each of the values</param>
        /// <returns></returns>
        public static string getCollectionList(ListItemCollection collection, bool returnValue, string separator)
        {
            string list = "";
            foreach (ListItem item in collection)
            {
                if (returnValue)
                {
                    list += item.Value + separator;
                }
                else
                {
                    list += item.Text + separator;
                }
            }
            if (!isNull(list))
            {
                list = list.Substring(0, list.Length - separator.Length);
            }
            return list;
        }

        /// <summary>
        /// Add a list of collection in your array list
        /// </summary>
        /// <param name="collection">Collection ID</param>
        /// <param name="returnValue">True will add value, False will add text from collection</param>
        /// <returns></returns>
        public static ArrayList arrListFromListItemCollection(ListItemCollection collection, bool returnValue)
        {
            ArrayList arr = new ArrayList();
            foreach (ListItem item in collection)
            {
                if (returnValue)
                {
                    arr.Add(item.Value);
                }
                else
                {
                    arr.Add(item.Text);
                }
            }
            return arr;
        }

        /// <summary>
        /// This will load any Drop Down List and style the inactive status
        /// </summary>
        /// <param name="ddl"></param>
        public static void loadInactiveStyleDDL(DropDownList ddl)
        {
            foreach (ListItem item in ddl.Items)
            {
                if (item.Text.ToLower().Contains("(inactive)"))
                {
                    item.Attributes.Add("style", "color:red");
                }
            }
        }

        /// <summary>
        /// Add Bootstrap styling for drop down list
        /// </summary>
        /// <param name="ddl"></param>
        public static void AddBootStrapCSSForDDL(DropDownList ddl)
        {
            ddl.Attributes.Add("class", "form-control");
            
        }

        /// <summary>
        /// Add Bootstrap styling for Txtbox
        /// </summary>
        /// <param name="ddl"></param>
        public static void AddBootStrapCSSForTXT(TextBox txt)
        {
            txt.Attributes.Add("class", "form-control");

        }

        public static void SelectTextBox(TextBox txt)
        {
            txt.Page.ClientScript.RegisterStartupScript(txt.Page.GetType(),
                                          "Select-" + txt.ClientID,
                                          String.Format("document.getElementById('{0}').select();", txt.ClientID),
                                          true);
        }

        public static string GetEmployeeDisplayName(string empIdOrloggedOnUser)
        {
            DataSet ds = DatabaseUtilities.DsGetEmployeeInfoByIdOrLoggedOnUsert(empIdOrloggedOnUser);
            if (ds.Tables[0].Rows.Count > 0)
            {
                return ds.Tables[0].Rows[0]["DisplayName"].ToString();
            }
            return "";
        }

        public static string GetEmployeeIdByLoggedOn(string loginUser)
        {
            DataSet ds = DatabaseUtilities.DsGetEmployeeInfoByIdOrLoggedOnUsert(loginUser);
            if (ds.Tables[0].Rows.Count > 0)
            {
                return ds.Tables[0].Rows[0]["EmpDistID"].ToString();
            }
            return "";
        }

        public static string GetEmployeeLoginById(string empid)
        {
            DataSet ds = DatabaseUtilities.DsGetEmployeeInfoByIdOrLoggedOnUsert(empid);
            if (ds.Tables[0].Rows.Count > 0)
            {
                string login = ds.Tables[0].Rows[0]["emp_login"].ToString();
                if (!isNull(login))
                {
                    return login;
                }
            }
            return "";
        }

        public static bool IsAppOffLine()
        {
            //Default app off line to false
            bool isAppOffLine = false;
            
            //get config value and set it to a variable to be processed
            string app_setting_app_offline = GetAppSettingFromConfig("APPLICATION_OFF_LINE");

            //check to see if it's empty
            if (!isNull(app_setting_app_offline))
            {
                //try to parse the key, if it cannot parse, it will defalt to false
                if (bool.TryParse(app_setting_app_offline, out isAppOffLine))
            {
                    isAppOffLine = bool.Parse(app_setting_app_offline);
            }
            }
            return isAppOffLine;
        }

        public static string GetFileTypeIDFromName(string name)
        {
            DataSet ds = DatabaseUtilities.DsGetByTableColumnValue(Constants.DBNAME_ASSET_TRACKING, Constants.TBL_CT_FILE_TYPE, Constants.COLUMN_CT_FILE_TYPE_Name, name, "");
            if (ds.Tables[0].Rows.Count > 0)
            {
                return ds.Tables[0].Rows[0][Constants.COLUMN_CT_FILE_TYPE_ID].ToString();
            }
            return "";
        }

        public static string GetAttachmentFileFullNameByID(string id)
        {
            DataSet ds = DatabaseUtilities.DsGetAssetAttachmentInfoByID(id);
            if (ds.Tables[0].Rows.Count > 0)
            {
                return ds.Tables[0].Rows[0]["FileNameType"].ToString();
            }
            return "";
        }

        //Validation Method
        #region Validation Method

        public static string ValidateOnAddAssetToTemp(string headerid, string tagid, string serial_number, string bin_id, string is_leased, string asset_type)
        {
            string errorMsg = "";
            string separator = "<br>";
            DataSet ds = DatabaseUtilities.DsValidateOnAddAssetToTemp(headerid, tagid, serial_number, bin_id, is_leased, asset_type);
            if (ds.Tables[0].Rows.Count > 0)
            {
                foreach (DataRow r in ds.Tables[0].Rows)
                {
                    errorMsg += r["Message_Error"].ToString() + separator;
                }
            }

            if (!isNull(errorMsg))
            {
                errorMsg = errorMsg.Substring(0, errorMsg.Length - separator.Length);
            }

            return errorMsg;
        }

        public static bool ValidateOnSubmitAdd(string headerid)
        {
            //string sMessage = "";
            DataSet ds = DatabaseUtilities.DsGetAssetTempHeaderDetailByHeaderID(headerid);
            if (ds.Tables[0].Rows.Count > 0)
            {
                foreach (DataRow r in ds.Tables[0].Rows)
                {
                    string smsg = r["Message_Error"].ToString();
                    if (!isNull(smsg))
                    {
                        //sMessage += smsg;
                        return false;
                    }
                }
            }
            //return sMessage;
            return true;
        }

        public static string ValidateOnEditAssetTemp(string headerid, string bin_id, string separator)
        {
            string sMessage = "";
            DataSet ds = DatabaseUtilities.DsValidateEditAssetTemp(headerid, bin_id);
            if (ds.Tables[0].Rows.Count > 0)
            {
                foreach (DataRow r in ds.Tables[0].Rows)
                {
                    sMessage += r["Message_Error"].ToString() + separator;
                }

                sMessage = sMessage.Substring(0, sMessage.Length - separator.Length);
            }
            return sMessage;
        }

        #endregion

        public static string CreateFiltersXML(NameValueCollection filters)
        {
            XmlDocument doc = new XmlDocument();
            XmlNode node = doc.CreateNode(XmlNodeType.XmlDeclaration, "", "");
            doc.AppendChild(node);
            XmlElement root = doc.CreateElement("", "AssetSearch", "");
            doc.AppendChild(root);
            XmlElement elFilters = doc.CreateElement("", "Filters", "");
            int i = 0;
            foreach (string filter in filters.AllKeys)
            {
                XmlElement elFilter = doc.CreateElement("", "Filter", "");
                XmlAttribute controlname = doc.CreateAttribute("", "FilterName", "");
                controlname.Value = filter;
                XmlAttribute controlValue = doc.CreateAttribute("", "FilterValue", "");
                controlValue.Value = filters.Get(filter);
                i++;
                elFilter.SetAttributeNode(controlname);
                elFilter.SetAttributeNode(controlValue);
                elFilters.AppendChild(elFilter);
            }
            root.AppendChild(elFilters);
            StringWriter sw = new StringWriter();
            XmlTextWriter xw = new XmlTextWriter(sw);
            doc.WriteTo(xw);
            return sw.ToString();
        }

        /// <summary>
        /// This will only databind for forms that return one record. The purpose for this is to load a Form. It will also clear form if it the dataset doesn't equal 1
        /// </summary>
        /// <param name="panel">Panel that you want to databind</param>
        /// <param name="ds">Dataset to bind the panel to. This must return only 1 record to bind.</param>
        //public static void DataBindForm(System.Web.UI.WebControls.Panel panel, DataSet ds)
        public static void DataBindForm(System.Web.UI.Control div, DataSet ds)    
        {
            if (ds.Tables[0].Rows.Count.Equals(1) && div != null)
            {
                #region Set Controls
                foreach (Control c in div.Controls)
                {
                    bool hasChildControl = c.HasControls();
                    if (hasChildControl)
                    {
                        DataBindForm(c, ds);
                    }
                    else
                    {
                        #region Search for Control Type
                        //Label
                        if (c is Label)
                        {
                            Label lbl = (Label)c;
                            string datacolumn = lbl.Attributes["data_column"];
                            if (datacolumn != null && ds.Tables[0].Columns.Contains(datacolumn))
                            {
                                lbl.Text = ds.Tables[0].Rows[0][datacolumn].ToString();
                            }

                        }
                        //Textbox
                        if (c is TextBox)
                        {
                            TextBox txt = (TextBox)c;
                            string datacolumn = txt.Attributes["data_column"];
                            if (datacolumn != null && ds.Tables[0].Columns.Contains(datacolumn))
                            {
                                txt.Text = ds.Tables[0].Rows[0][datacolumn].ToString();
                            }

                        }
                        //Drop Down List
                        if (c is DropDownList)
                        {
                            DropDownList ddl = (DropDownList)c;
                            string datacolumn = ddl.Attributes["data_column"];
                            if (datacolumn != null && ds.Tables[0].Columns.Contains(datacolumn))
                            {
                                string selectedValue = ds.Tables[0].Rows[0][datacolumn].ToString();
                                ListItem i = ddl.Items.FindByValue(selectedValue);
                                if (ddl.Items.Contains(i))
                                {
                                    ddl.SelectedValue = selectedValue;
                                }
                            }
                        }

                        //CheckBox
                        if (c is CheckBox)
                        {
                            CheckBox chk = (CheckBox)c;
                            string datacolumn = chk.Attributes["data_column"];
                            if (datacolumn != null && ds.Tables[0].Columns.Contains(datacolumn))
                            {
                                string selectedValue = ds.Tables[0].Rows[0][datacolumn].ToString().ToLower().Trim();
                                bool isCheck = selectedValue.Equals("1") || selectedValue.Equals("true") || selectedValue.Equals("yes");

                                chk.Checked = isCheck;
                            }
                        }

                        //Hidden Values
                        if (c is HiddenField)
                        {
                            //Because hiddent fields does not have value, it will look at the value and reset the value to the database value
                            HiddenField hdn = (HiddenField)c;
                            string datacolumn = hdn.Value;
                            if (datacolumn != null && ds.Tables[0].Columns.Contains(datacolumn))
                            {
                                hdn.Value = ds.Tables[0].Rows[0][datacolumn].ToString();
                            }
                        }

                        //Listbox
                        if (c is ListBox)
                        {
                            ListBox lst = (ListBox)c;
                            string datacolumn = lst.Attributes["data_column"];
                            if (datacolumn != null && ds.Tables[0].Columns.Contains(datacolumn))
                            {
                                string selectedValue = ds.Tables[0].Rows[0][datacolumn].ToString();
                                //Handle comma separated list to select from
                                if (selectedValue.Contains(","))
                                {
                                    //loop thru the string
                                    string[] arrSelectedValues = selectedValue.Split(',');
                                    foreach (string sVal in arrSelectedValues)
                                    {
                                        //loop thru the list item
                                        foreach (ListItem item in lst.Items)
                                        {
                                            if (sVal.Equals(item.Value))
                                            {
                                                item.Selected = true;
                                            }
                                        }
                                    }
                                }
                                else
                                {
                                    ListItem i = lst.Items.FindByValue(selectedValue);
                                    if (lst.Items.Contains(i))
                                    {
                                        lst.SelectedValue = selectedValue;
                                    }
                                }
                            }
                        }

                        //CheckBoxList
                        if (c is CheckBoxList)
                        {
                            CheckBoxList chklst = (CheckBoxList)c;
                            string datacolumn = chklst.Attributes["data_column"];
                            if (datacolumn != null && ds.Tables[0].Columns.Contains(datacolumn))
                            {
                                string selectedValue = ds.Tables[0].Rows[0][datacolumn].ToString();
                                //Handle comma separated list to select from
                                if (selectedValue.Contains(","))
                                {
                                    //loop thru the string
                                    string[] arrSelectedValues = selectedValue.Split(',');
                                    foreach (string sVal in arrSelectedValues)
                                    {
                                        //loop thru the list item
                                        foreach (ListItem item in chklst.Items)
                                        {
                                            if (sVal.Equals(item.Value))
                                            {
                                                item.Selected = true;
                                            }
                                        }
                                    }
                                }
                                else
                                {
                                    ListItem i = chklst.Items.FindByValue(selectedValue);
                                    if (chklst.Items.Contains(i))
                                    {
                                        chklst.SelectedValue = selectedValue;
                                    }
                                }
                            }
                        }
                        #endregion
                    }
                }
                #endregion
            }
            else
            {
                //Clear all control
                #region Clear Controls
                foreach (Control c in div.Controls)
                {
                    bool hasChildControl = c.HasControls();
                    if (hasChildControl)
                    {
                        DataBindForm(c, ds);
                    }
                    else
                    {
                        #region Search for Control Type
                        //Label
                        if (c is Label)
                        {
                            Label lbl = (Label)c;
                            string datacolumn = lbl.Attributes["data_column"];
                            if (datacolumn != null && ds.Tables[0].Columns.Contains(datacolumn))
                            {
                                lbl.Text = "";
                            }

                        }
                        //Textbox
                        if (c is TextBox)
                        {
                            TextBox txt = (TextBox)c;
                            string datacolumn = txt.Attributes["data_column"];
                            if (datacolumn != null && ds.Tables[0].Columns.Contains(datacolumn))
                            {
                                txt.Text = "";
                            }

                        }
                        //Drop Down List
                        if (c is DropDownList)
                        {
                            DropDownList ddl = (DropDownList)c;
                            string datacolumn = ddl.Attributes["data_column"];
                            if (datacolumn != null && ds.Tables[0].Columns.Contains(datacolumn) && ddl.Items.Count > 0)
                            {
                                ddl.SelectedIndex = 0;
                            }
                        }

                        //CheckBox
                        if (c is CheckBox)
                        {
                            CheckBox chk = (CheckBox)c;
                            string datacolumn = chk.Attributes["data_column"];
                            if (datacolumn != null && ds.Tables[0].Columns.Contains(datacolumn))
                            {
                                chk.Checked = false;
                            }
                        }

                        //Hidden Values
                        if (c is HiddenField)
                        {
                            //Because hiddent fields does not have value, it will look at the value and reset the value to the database value
                            HiddenField hdn = (HiddenField)c;
                            hdn.Value = "";
                        }

                        //Listbox
                        if (c is ListBox)
                        {
                            ListBox lst = (ListBox)c;
                            string datacolumn = lst.Attributes["data_column"];
                            if (datacolumn != null && ds.Tables[0].Columns.Contains(datacolumn) && lst.Items.Count > 0)
                            {
                                lst.ClearSelection();
                            }
                        }

                        //CheckBoxList
                        if (c is CheckBoxList)
                        {
                            CheckBoxList chklst = (CheckBoxList)c;
                            string datacolumn = chklst.Attributes["data_column"];
                            if (datacolumn != null && ds.Tables[0].Columns.Contains(datacolumn) && chklst.Items.Count > 0)
                            {
                                chklst.ClearSelection();
                            }
                        }
                        #endregion
                    }
                }
                #endregion
            }
        }

        public static bool ViewAnyDocument(string filePath, HttpResponse r)
        {
            bool IsFileExist = false;
            FileInfo file = new FileInfo(filePath);
            if (file.Exists)
            {
                r.Clear();
                r.AddHeader("Content-Disposition", "attachment; filename=" + file.Name);
                r.AddHeader("Content-Length", file.Length.ToString());
                r.AddHeader("Content-Transfer-Encoding", "binary");
                r.ContentType = "application/octet-stream";
                r.WriteFile(file.FullName);
                r.Flush();
                r.End();

                IsFileExist = true;
            }

            if (!IsFileExist)
            {
                //Log event if file does not exist.
                string recordtype = Constants.SECURITY_RECORDTYPE_APPLICATION_ERROR; 
                string module = "File Not Exist"; 
                string description = "Cannot find file: " + filePath;

                Utilities.LogEvent(recordtype, module, description);
            }

            return IsFileExist;
        }

        public static string ConvertStringToDBNull(string value)
        {
            if (isNull(value))
            {
                return Constants.MCSDBNULL;
            }
            return value;
        }

        public static string ConvertContainsDashValueToDBNull(string value)
        {
            if (value.Contains("-"))
            {
                return Constants.MCSDBNULL;
            }
            return value;
        }

        public static string GetSiteNameByID(string site_id)
        {
            DataSet ds = DatabaseUtilities.DsGetByTableColumnValue(Constants.TBL_CT_SITE, Constants.COLUMN_CT_SITE_ID, site_id, "");
            if (ds.Tables[0].Rows.Count > 0)
            {
                return ds.Tables[0].Rows[0][Constants.COLUMN_CT_SITE_Name].ToString();
            }
            return "";
        }

        public static string GetFileTypeFromUploadControl(FileUpload fupload)
        {
            string filetype = "";
            if (fupload.HasFile)
            {
                string[] parts = fupload.FileName.Split('.');
                filetype = parts[parts.Length - 1];
            }
            return filetype;
        }

        public static string SanitizeStudentIds(string studentIds)
        {
            try
            {
                studentIds = Regex.Replace(studentIds, "[^0-9]", ","); // replace non-digits with comma
                studentIds = Regex.Replace(studentIds.Replace("\n", ","), ",,+", ","); // replace new line with comma and replace commas with comma

                return studentIds.TrimEnd(',').TrimStart(',').Replace(" ", ""); // remove first and last comma and replace spaces with nothing
            }
            catch
            {
                return null;
            }
        }

        public static void DDL_SetValueIfExist(DropDownList ddl, string sValue)
        {
            //Check to see if the selected value exists before setting it.
            ListItem i = ddl.Items.FindByValue(sValue);
            if (ddl.Items.Contains(i))
            {
                ddl.SelectedValue = sValue;
            }
        }

        /// <summary>
        /// Return CSV list of selected text or value
        /// </summary>
        /// <param name="IsReturnValue">true - return value, false - return text</param>
        /// <returns>String CSV List of selected item</returns>
        public static string GetListItemFromListBox(ListBox lstBox, bool IsReturnValue)
        {
            //string to return
            string selecteditem = "";

            //loop through the listbox
            foreach (ListItem item in lstBox.Items)
            {
                if (item.Selected)
                {
                    if (IsReturnValue)
                    {
                        selecteditem += item.Value + ",";
                    }
                    else
                    {
                        selecteditem += item.Text + ",";
                    }
                }
            }

            //check to see if any items were selected
            if (!Utilities.isNull(selecteditem))
            {
                //remove the last comma
                selecteditem = selecteditem.Substring(0, selecteditem.Length - 1);
            }

            //return the value
            return selecteditem;
        }

        public static void SelectAllFromPage(DataGrid dg, bool isCheckAll, string chkId)
        {
             //loop thru each of the check box on the grid and set it to the same value as the select all
            foreach (DataGridItem item in dg.Items)
            {
                CheckBox chk = (CheckBox)item.FindControl(chkId);
                if (chk != null)
                {
                    chk.Checked = isCheckAll;
                }
            }
        }

        public static bool ValidateIsAtLeastOneItemCheckFromGrid(DataGrid dg, string chkId, HiddenField hdnNumberOfItemSelected)
        {
            bool isOneItemSelected = false;
            int iNumberOfItemSelected = 0;
            //loop thru each of the check box on the grid and check to see if at least one item is selected
            foreach (DataGridItem item in dg.Items)
            {
                CheckBox chk = (CheckBox)item.FindControl("chkAsset");
                if (chk != null)
                {
                    if (chk.Checked)
                    {
                        iNumberOfItemSelected = iNumberOfItemSelected + 1;
                        isOneItemSelected = true;
                    }
                }
            }

            if (hdnNumberOfItemSelected != null) {
                hdnNumberOfItemSelected.Value = iNumberOfItemSelected.ToString();
            }
            return isOneItemSelected;
        }

        public static int MaxAllowAssetTransfer()
        {
            string maxallow = GetAppSettingFromConfig("MAX_ALLOW_TRANSFER_ASSET");
            if (!IsNumeric(maxallow))
            {
                maxallow = "1";//Default 1 if value is not set.
            }

            return int.Parse(maxallow);
        }

        public static void RevertPreviousDispositionByAssetID(string asset_id)
        {
            //Update asset to previous disposition
            string previous_disposition = DatabaseUtilities.GetPreviousDispositionFromAuditByAssetID(asset_id);

            //If it can't find the previous disposition, set to Available
            if (Utilities.isNull(previous_disposition))
            {
                previous_disposition = Constants.DISP_AVAILABLE;
            }

            //Save to database
            DatabaseUtilities.SaveAssetDisposition(asset_id, previous_disposition, GetLoggedOnUser());
        }

        public static int GetCountOfCheckItemInInDatagrid(DataGrid dg, string chkboxid)
        {
            int iNumberOfItemSelected = 0;
            //loop thru each of the check box on the grid and check to see if at least one item is selected
            foreach (DataGridItem item in dg.Items)
            {
                CheckBox chk = (CheckBox)item.FindControl(chkboxid);
                if (chk != null)
                {
                    if (chk.Checked)
                    {
                        iNumberOfItemSelected = iNumberOfItemSelected + 1;
                    }
                }
            }

            return iNumberOfItemSelected;
        }

        public static void CloseModal(Page p, string modal_id)
        {
            ScriptManager.RegisterStartupScript(p, p.GetType(), "closePopup_" + modal_id, "$('#" + modal_id + "').modal('hide');", true);
        }

        private static void RemoveAttachmentFromServer(string attachment_id, string asset_id)
        {
            string sFileNameType = GetAttachmentFileFullNameByID(attachment_id);
            string sFile = GetAssetAttachmentFolderLocation() + "\\" + asset_id + "\\" + sFileNameType;

            FileInfo f = new FileInfo(sFile);
            if (f.Exists)
            {
                f.Delete();
            }
        }

        public static void DeleteAssetAttachmentByID(string attachment_id, string asset_id)
        {
            RemoveAttachmentFromServer(attachment_id, asset_id);
            DatabaseUtilities.DeleteAsset_Attachment(attachment_id);
        }

        public static string GetAssetSiteCodeByAssetID(string asset_id)
        {
            string asset_site_code = "";
            DataSet ds = DatabaseUtilities.DsGetAssetInfoByID(asset_id);
            if (ds.Tables[0].Rows.Count.Equals(1))
            {
                asset_site_code = ds.Tables[0].Rows[0][Constants.COLUMN_V_ASSET_MASTER_LIST_Asset_Site_Code].ToString();
            }
            return asset_site_code;
        }

        public static bool PrintCheckInReceiptSSRS(string student_id, string from_date, string to_date, HttpResponse r)
        {
             DataSet ds = DatabaseUtilities.DsGetStudentCheckInReceipt(student_id, from_date, to_date);
             if (ds.Tables[0].Rows.Count > 0)
             {
                 string sReportName = "StudentCheckInReceipt_Single";
                 string sReportFolder = "CAIRSReports";

                 string urldbServer = "http://" + System.Configuration.ConfigurationManager.AppSettings.Get("DB_SERVER");
                 string reportServerName = System.Configuration.ConfigurationManager.AppSettings.Get("REPORTSERVER_URL");
                 string urlReportServer = urldbServer + reportServerName;

                 ReportViewer rv = new ReportViewer();
                 rv.ProcessingMode = ProcessingMode.Remote;
                 rv.ServerReport.ReportServerUrl = new System.Uri(urlReportServer);
                 rv.ServerReport.ReportPath = "/" + sReportFolder + "/" + sReportName;
                 ReportParameter[] rptparam = new ReportParameter[3];

                 rptparam[0] = new ReportParameter("Student_ID", student_id);
                 rptparam[1] = new ReportParameter("FromDate", from_date);
                 rptparam[2] = new ReportParameter("ToDate", to_date);

                 rv.ServerReport.SetParameters(rptparam);
                 string format = "PDF",
                        devInfo = @"<DeviceInfo><Toolbar>True</Toolbar></DeviceInfo>";

                 //out parameters

                 string mimeType = "",
                     encoding = "",
                     fileNameExtn = "";
                 string[] stearms = null;
                 Microsoft.Reporting.WebForms.Warning[] warnings = null;

                 byte[] result = null;

                 //render report, it will returns bite array
                 result = rv.ServerReport.Render(format,
                     devInfo, out mimeType, out encoding,
                     out fileNameExtn, out stearms, out warnings);

                 r.Clear();
                 r.AddHeader("Content-Disposition", "attachment; filename=StudentCheckIn_" + student_id + ".pdf");
                 r.AddHeader("Content-Transfer-Encoding", "binary");
                 r.ContentType = "application/octet-stream";
                 r.OutputStream.Write(result, 0, result.Length);
                 r.Flush();
                 r.End();

                 return true;

             }
             return false;
        }

        #region Validating Attachment
        
        private static bool HasDuplicateFileName(string asset_attachment_id, string asset_id, string file_name, string file_type, CustomValidator cvDuplicate, FileUpload file_upload)
        {
            bool hasDuplicate = false;

            DataSet ds = DatabaseUtilities.DsValidateDuplicateAttachmentName(asset_id, asset_attachment_id, file_name, file_type);
            if (ds.Tables[0].Rows.Count > 0)
            {
                hasDuplicate = true;
                cvDuplicate.IsValid = false;
            }

            return hasDuplicate;
        }

        private static bool ValidateFileSize(FileUpload file_upload, CustomValidator cvFileSize)
        {
            bool IsValid = true;
            if (file_upload.HasFile)
            {
                HttpPostedFile file = (HttpPostedFile)(file_upload.PostedFile);

                int iMaxFileSIze = int.Parse(Utilities.GetAppSettingFromConfig("MAX_FILE_SIZE_UPLOAD"));

                int iFileSize = file.ContentLength;
                if (iFileSize > iMaxFileSIze)
                {
                    IsValid = false;
                }

            }

            cvFileSize.IsValid = IsValid;

            return IsValid;
        }

        public static bool ValidateSaveAttachment(string asset_attachment_id, string asset_id, string file_name, string file_type, CustomValidator cvDuplicate, CustomValidator cvFileSize, FileUpload file_upload)
        {
            bool IsValid = true;

            //Check for duplicate file name
            if (HasDuplicateFileName(asset_attachment_id, asset_id, file_name, file_type, cvDuplicate, file_upload))
            {
                IsValid = false;
            }

            //check for file size
            if (ValidateFileSize(file_upload, cvFileSize))
            {
                IsValid = false;
            }

            return IsValid;
        }

        public static void UploadFileToServer(string asset_id, string asset_attachment_id, string fileNameAndType, bool is_insert, FileUpload file_upload)
        {
            string folder = Utilities.GetAssetAttachmentFolderLocation() + "\\" + asset_id;
            string oldFileName = Utilities.GetAttachmentFileFullNameByID(asset_attachment_id).ToLower().Trim();
            string sanitizeFileName = fileNameAndType.ToLower().Trim();
            bool IsFileNameChanged = !oldFileName.Equals(sanitizeFileName);
            string sOldFileName = folder + "\\" + oldFileName;
            string sNewFileName = folder + "\\" + fileNameAndType;

            //Check to see if there is a file to be uploaded
            if (file_upload.HasFile && !Utilities.isNull(fileNameAndType))
            {
                //Check to see if folder exist. If not, create

                if (!Directory.Exists(folder))
                {
                    Directory.CreateDirectory(folder);
                }
                file_upload.SaveAs(sNewFileName);
            }
            else
            {
                //Check to see if file needs to be rename for existing attachment
                if (!is_insert && IsFileNameChanged)
                {
                    FileInfo f = new FileInfo(sOldFileName);
                    if (f.Exists)
                    {
                        File.Copy(sOldFileName, sNewFileName);
                        f.Delete();
                    }
                }
            }
        }
       
        
        #endregion

    }

}

