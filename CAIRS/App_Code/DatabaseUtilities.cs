using System;
using System.Collections.Generic;
using System.Configuration;
using System.Linq;
using System.Web;
using System.Data;
using System.Data.SqlClient;
using System.Text;
using System.Diagnostics;
using System.Web.UI;
using SQL = System.Data.SqlClient;
using System.Collections;
using System.Net;

namespace CAIRS
{
	public class DatabaseUtilities
	{
		//Global Variables
		private static readonly object LockObject = new object();
		private static string DB_SERVER = ConfigurationManager.AppSettings["DB_SERVER"].ToString();
		private static string DB_USER = ConfigurationManager.AppSettings["DB_USER"].ToString();
		private static string DB_PW = ConfigurationManager.AppSettings["DB_PW"].ToString();
		private static string DB_CONNECTION_TIME_OUT = ConfigurationManager.AppSettings["DB_CONNECTION_TIME_OUT"].ToString();

		public static DataSet ExecuteSQLStatement(string sSQL)
		{
			return ExecuteSQLStatement(Constants.DBNAME_ASSET_TRACKING, sSQL);
		}
		public static DataSet ExecuteSQLStatement(string sDBName, string sSQL)
		{
			string sTimeout = DB_CONNECTION_TIME_OUT;

			Utilities.Assert(!Utilities.isNull(sTimeout) && Utilities.IsNumeric(sTimeout), "You must provide a numeric connection timeout for your database connection in the Web.config file.");

			//Get variables from config file
			string sServer = DB_SERVER;
			string sUserName = Utilities.Decrypt(DB_USER, true);
			string sPassword = Utilities.Decrypt(DB_PW, true);

			//parse connection timeout to integer
			int connectionTimeOut = int.Parse(sTimeout);

			lock (LockObject)
			{
				SqlConnection cnn = new SqlConnection();

				try
				{
					string connectionString = "server=" + sServer + ";UID=" + sUserName + ";PWD=" + sPassword + ";DATABASE=" + sDBName;
					cnn.ConnectionString = connectionString;
					cnn.Open();
					SQL.SqlCommand cmd = cnn.CreateCommand();
					cmd.CommandTimeout = connectionTimeOut;
					cmd.CommandText = sSQL;
					cmd.CommandType = CommandType.Text;
					SQL.SqlDataAdapter aSQL = new SQL.SqlDataAdapter(cmd);
					DataSet ds = new DataSet("sqpDS");
					aSQL.Fill(ds);
					cnn.Close();
					return ds;
				}
				catch (SqlException sql)
				{
					cnn.Close();
					//Timeout Error
					string appid = ConfigurationManager.AppSettings["APPLICATION_ID"];
					if (!Utilities.isNull(appid))
					{
						appid = "?appid=" + appid;
					}

					if (sql.Number.Equals(-2))
					{
						HttpContext.Current.Response.Redirect("/Pages/ErrorPage.aspx?" + appid);
					}
					throw new SQLQueryException(sSQL, sql);

				}
				catch (Exception exc)
				{
					cnn.Close();
					throw new SQLQueryException(sSQL, exc);
				}
			}
		}
		public static DataSet ExecuteStoredProc(string sStoredProcName, string paramName, string paramValue)
		{
			ArrayList arrName = new ArrayList();
			ArrayList arrValue = new ArrayList();

			arrName.Add(paramName);
			arrValue.Add(paramValue);

			return ExecuteStoredProc(Constants.DBNAME_ASSET_TRACKING, sStoredProcName, arrName, arrValue);
		}
		public static DataSet ExecuteStoredProc(string sDbName, string sStoredProcName, string paramName, string paramValue)
		{
			ArrayList arrName = new ArrayList();
			ArrayList arrValue = new ArrayList();

			arrName.Add(paramName);
			arrValue.Add(paramValue);

			return ExecuteStoredProc(sDbName, sStoredProcName, arrName, arrValue);
		}
		public static DataSet ExecuteStoredProc(string sStoredProcName, ArrayList arrName, ArrayList arrValue)
		{
			return ExecuteStoredProc(Constants.DBNAME_ASSET_TRACKING, sStoredProcName, arrName, arrValue);
		}
		public static DataSet ExecuteStoredProc(string sDbName, string sStoredProcName, ArrayList paramNames, ArrayList ParamValues)
		{
			string sTimeout = DB_CONNECTION_TIME_OUT;

			Utilities.Assert(!Utilities.isNull(sTimeout) && Utilities.IsNumeric(sTimeout), "You must provide a numeric connection timeout for your database connection in the Web.config file.");

			//Get variables from config file
			string sServer = DB_SERVER;
			string sUserName = Utilities.Decrypt(DB_USER, true);
			string sPassword = Utilities.Decrypt(DB_PW, true);

			//parse connection timeout to integer
			int connectionTimeOut = int.Parse(sTimeout);

			lock (LockObject)
			{
				SqlConnection cnn = new SqlConnection();

				try
				{
					string connectionString = "server=" + sServer + ";UID=" + sUserName + ";PWD=" + sPassword + ";DATABASE=" + sDbName;
					cnn.ConnectionString = connectionString;
					cnn.Open();
					SQL.SqlCommand cmd = cnn.CreateCommand();
					cmd.CommandTimeout = connectionTimeOut;
					cmd.CommandText = sStoredProcName;
					cmd.CommandType = CommandType.StoredProcedure;
					foreach (SQL.SqlParameter parP in cmd.Parameters)
					{
						cmd.Parameters[parP.ParameterName] = null;
					}

					if (paramNames != null)
					{
						for (int i = 0; i < paramNames.Count; i++)
						{
							if (ParamValues[i] == null)
							{
								ParamValues[i] = "";
							}
							string paramName = "@" + paramNames[i].ToString();
							SqlParameter param;
							if (ParamValues[i].GetType().Equals(typeof(byte[])))
							{
								param = cmd.Parameters.Add(paramName, SqlDbType.VarBinary);
								param.Value = ParamValues[i];
							}
							else
							{
								param = cmd.Parameters.Add(paramName, SqlDbType.NVarChar);
								param.Value = ParamValues[i].ToString();
							}
							param.Direction = ParameterDirection.Input;
						}
					}

					SQL.SqlDataAdapter aSQL = new SQL.SqlDataAdapter(cmd);
					DataSet ds = new DataSet("sqpDS");
					aSQL.Fill(ds);
					cnn.Close();
					return ds;
				}
				catch (SqlException sql)
				{
					cnn.Close();
					//Timeout Error
					string appid = ConfigurationManager.AppSettings["APPLICATIONID"];
					if (!Utilities.isNull(appid))
					{
						appid = "?appid=" + appid;
					}

					if (sql.Number.Equals(-2))
					{
						HttpContext.Current.Response.Redirect("/Pages/ErrorPage.aspx?" + appid);
					}
					throw new SQLQueryException("Store Proc: " + sStoredProcName, sql);

				}
				catch (Exception exc)
				{
					cnn.Close();
					throw new SQLQueryException("Store Proc: " + sStoredProcName, exc);
				}
			}
		}
		public static void ExecuteStoredProcNoResults(string sStoredProcName, string paramName, string paramValue)
		{
			ArrayList arrName = new ArrayList();
			ArrayList arrValue = new ArrayList();

			arrName.Add(paramName);
			arrValue.Add(paramValue);

			ExecuteStoredProcNoResults(Constants.DBNAME_ASSET_TRACKING, sStoredProcName, arrName, arrValue);
		}
		public static void ExecuteStoredProcNoResults(string sDbName, string sStoredProcName, string paramName, string paramValue)
		{
			ArrayList arrName = new ArrayList();
			ArrayList arrValue = new ArrayList();

			arrName.Add(paramName);
			arrValue.Add(paramValue);

			ExecuteStoredProcNoResults(sDbName, sStoredProcName, arrName, arrValue);
		}
		public static void ExecuteStoredProcNoResults(string sStoredProcName, ArrayList arrName, ArrayList arrValue)
		{
			ExecuteStoredProcNoResults(Constants.DBNAME_ASSET_TRACKING, sStoredProcName, arrName, arrValue);
		}
		public static void ExecuteStoredProcNoResults(string sDbName, string sStoredProcName, ArrayList paramNames, ArrayList ParamValues)
		{
			string sTimeout = DB_CONNECTION_TIME_OUT;

			Utilities.Assert(!Utilities.isNull(sTimeout) && Utilities.IsNumeric(sTimeout), "You must provide a numeric connection timeout for your database connection in the Web.config file.");

			//Get variables from config file
			string sServer = DB_SERVER;
			string sUserName = Utilities.Decrypt(DB_USER, true);
			string sPassword = Utilities.Decrypt(DB_PW, true);

			//parse connection timeout to integer
			int connectionTimeOut = int.Parse(sTimeout);

			lock (LockObject)
			{
				SqlConnection cnn = new SqlConnection();

				try
				{

					string connectionString = "server=";
					connectionString += sServer;
					connectionString += ";UID=" + sUserName + ";PWD=" + sPassword + ";DATABASE=" + sDbName;
					//cnn.ConnectionString = "server=admb-dev;UID=" + sUserName + ";PWD=" + sPassword + ";DATABASE=" + sDbName;
					cnn.ConnectionString = connectionString;
					cnn.Open();
					SQL.SqlCommand cmd = new SqlCommand();
					cmd.Connection = cnn;
					cmd.CommandText = sStoredProcName;
					cmd.CommandType = CommandType.StoredProcedure;
					foreach (SQL.SqlParameter parP in cmd.Parameters)
					{
						cmd.Parameters[parP.ParameterName] = null;
					}

					if (paramNames != null)
					{
						for (int i = 0; i < paramNames.Count; i++)
						{
							if (ParamValues[i] == null)
							{
								ParamValues[i] = "";
							}
							string paramName = "@" + paramNames[i].ToString();
							SqlParameter param;

							string test = ParamValues[i].GetType().ToString();
							if (ParamValues[i].GetType().Equals(typeof(byte[])))
							{
								param = cmd.Parameters.Add(paramName, SqlDbType.VarBinary);

								string sVal = ParamValues[i].ToString();
								if (sVal.Equals(Constants.MCSDBNOPARAM))
								{
									param.Value = DBNull.Value;
								}
								else
								{
									param.Value = ParamValues[i];
								}
							}
							else
							{
								param = cmd.Parameters.Add(paramName, SqlDbType.NVarChar);

								string sVal = ParamValues[i].ToString();
								param.Value = sVal;
								if (sVal.Equals(Constants.MCSDBNOPARAM))
								{
									param.Value = DBNull.Value;
								}
								else
								{
									param.Value = sVal;
								}

							}
							param.Direction = ParameterDirection.Input;
						}
					}

					cmd.ExecuteNonQuery();
					cnn.Close();
				}
				catch (SqlException sql)
				{
					cnn.Close();
					//Timeout Error
					
					if (sql.Number.Equals(-2))
					{
						HttpContext.Current.Response.Redirect("/Pages/ErrorPage.aspx?msg=" + sql.Message.ToString());
					}
					throw new SQLQueryException("Store Proc: " + sStoredProcName, sql);

				}
				catch (Exception exc)
				{
					cnn.Close();
					throw new SQLQueryException("Store Proc: " + sStoredProcName, exc);
				}
			}
		}
		public static string ExecuteStoredProcUpsert(string sStoredProcName, string paramNames, string paramValues)
		{
			ArrayList arrName = new ArrayList();
			ArrayList arrValue = new ArrayList();

			arrName.Add(paramNames);
			arrValue.Add(paramValues);

			return ExecuteStoredProcUpsert(Constants.DBNAME_ASSET_TRACKING, sStoredProcName, arrName, arrValue);
		}
		public static string ExecuteStoredProcUpsert(string sStoredProcName, ArrayList arrName, ArrayList arrValue)
		{
			return ExecuteStoredProcUpsert(Constants.DBNAME_ASSET_TRACKING, sStoredProcName, arrName, arrValue);
		}
		public static string ExecuteStoredProcUpsert(string sDbName, string sStoredProcName, string paramNames, string paramValues)
		{
			ArrayList arrName = new ArrayList();
			ArrayList arrValue = new ArrayList();

			arrName.Add(paramNames);
			arrValue.Add(paramValues);

			return ExecuteStoredProcUpsert(sDbName, sStoredProcName, arrName, arrValue);
		}
		public static string ExecuteStoredProcUpsert(string sDbName, string sStoredProcName, ArrayList ParamNames, ArrayList ParamValues)
		{
			string sTimeout = DB_CONNECTION_TIME_OUT;

			Utilities.Assert(!Utilities.isNull(sTimeout) && Utilities.IsNumeric(sTimeout), "You must provide a numeric connection timeout for your database connection in the Web.config file.");

			//Get variables from config file
			string sServer = DB_SERVER;
			string sUserName = Utilities.Decrypt(DB_USER, true);
			string sPassword = Utilities.Decrypt(DB_PW, true);

			//parse connection timeout to integer
			int connectionTimeOut = int.Parse(sTimeout);

			lock (LockObject)
			{
				SqlConnection cnn = new SqlConnection();

				try
				{

					string connectionString = "server=";
					connectionString += sServer;
					connectionString += ";UID=" + sUserName + ";PWD=" + sPassword + ";DATABASE=" + sDbName;
					//cnn.ConnectionString = "server=admb-dev;UID=" + sUserName + ";PWD=" + sPassword + ";DATABASE=" + sDbName;
					cnn.ConnectionString = connectionString;
					cnn.Open();
					SQL.SqlCommand cmd = new SqlCommand();
					cmd.Connection = cnn;
					cmd.CommandText = sStoredProcName;
					cmd.CommandType = CommandType.StoredProcedure;
					foreach (SQL.SqlParameter parP in cmd.Parameters)
					{
						cmd.Parameters[parP.ParameterName] = null;
					}

					if (ParamNames != null)
					{
						for (int i = 0; i < ParamNames.Count; i++)
						{
							if (ParamValues[i] == null)
							{
								ParamValues[i] = "";
							}
							string paramName = "@" + ParamNames[i].ToString();
							SqlParameter param;

							string test = ParamValues[i].GetType().ToString();
							if (ParamValues[i].GetType().Equals(typeof(byte[])))
							{
								param = cmd.Parameters.Add(paramName, SqlDbType.VarBinary);

								string sVal = ParamValues[i].ToString();
								if (sVal.Equals(Constants.MCSDBNOPARAM))
								{
									param.Value = DBNull.Value;
								}
								else
								{
									param.Value = ParamValues[i];
								}
							}
							else
							{
								param = cmd.Parameters.Add(paramName, SqlDbType.NVarChar);

								string sVal = ParamValues[i].ToString();
								param.Value = sVal;
								if (sVal.Equals(Constants.MCSDBNOPARAM))
								{
									param.Value = DBNull.Value;
								}
								else
								{
									param.Value = sVal;
								}

							}
							param.Direction = ParameterDirection.Input;
						}
					}

					string result = cmd.ExecuteScalar().ToString();
					cnn.Close();
					return result;
				}
				catch (SqlException sql)
				{
					cnn.Close();
					//Timeout Error
					string appid = ConfigurationManager.AppSettings["APPLICATIONID"];
					if (!Utilities.isNull(appid))
					{
						appid = "?appid=" + appid;
					}

					if (sql.Number.Equals(-2))
					{
						HttpContext.Current.Response.Redirect("/Pages/ErrorPage.aspx?" + appid);
					}
					throw new SQLQueryException("Store Proc: " + sStoredProcName, sql);

				}
				catch (Exception exc)
				{
					cnn.Close();
					throw new SQLQueryException("Store Proc: " + sStoredProcName, exc);
				}
			}
		}
		
		//Submit from Asset_Temp to Asset
		/// <summary>
		/// Method to submit from Asset_Temp to Asset
		/// </summary>
		/// <param name="headerID">Header ID</param>
		/// <param name="dateSubmitted">Date Submitted</param>
		/// <param name="submittedByEmpID">Subbmited By Employee</param>
		public static void SubmitAssetTempToAsset(string headerID, string dateSubmitted, string submittedByEmpID)
		{
			ArrayList arrParamName = new ArrayList();
			ArrayList arrParmaValue = new ArrayList();

			//Header ID
			arrParamName.Add("Asset_Temp_Header_ID");
			arrParmaValue.Add(headerID);

			//Date Submitted
			arrParamName.Add("Date_Submit");
			arrParmaValue.Add(dateSubmitted);

			//Submitted By
			arrParamName.Add("Submitted_By_Emp_ID");
			arrParmaValue.Add(submittedByEmpID);

			ExecuteStoredProcNoResults(Constants.DBNAME_ASSET_TRACKING, Constants.STORED_PROC_SP_SUBMIT_ASSET_TEMP_TO_ASSET, arrParamName, arrParmaValue);
		}
		
		//Asset Search Detail Save
		public static void SaveAssetSearchDetail(string assetSearchID, string sWhereClause, string sOrderBy)
		{
			string sSQL = @"DECLARE @AssetSearchID as int
							DECLARE @AssetTempTbl as TABLE(
								Asset_Search_ID INT,
								Asset_ID INT,
								Is_Checked BIT
							)
							
							SET @AssetSearchID = " + assetSearchID + @"
							
							INSERT INTO @AssetTempTbl
							Select 
								Asset_Search_ID, 
								Asset_ID, 
								Is_Checked 
							FROM Asset_Search_Detail 
							WHERE Asset_Search_ID = " + assetSearchID + @"

							DELETE FROM Asset_Search_Detail where Asset_Search_ID = @AssetSearchID 

							INSERT INTO Asset_Search_Detail
							select
								@AssetSearchID as Asset_Search_ID,
								v.Asset_ID,
								row_number() over (" + sOrderBy + @") as sort_order,
								case when row_number() over (" + sOrderBy + @") = 1 then 1 else 0 end as Is_Selected,
								tbl.Is_Checked
							from v_Asset_Master_List v 
							left join @AssetTempTbl tbl
								on tbl.Asset_ID = v.Asset_ID
							"
							+ sWhereClause
							+ " order by sort_order";
			ExecuteSQLStatement(Constants.DBNAME_ASSET_TRACKING, sSQL);
		}

		public static void UpdateAssetSearchSelectedAsset(string assetSearchID, string assetid)
		{
			string sSQL = @"DECLARE @AssetSearchID as INT
							DECLARE @AssetID as INT

							SET @AssetSearchID = " + assetSearchID + @"
							SET @AssetID = " + assetid + @"

							Update Asset_Search_Detail SET Is_Selected = 0 WHERE Asset_Search_ID = @AssetSearchID
			
							Update Asset_Search_Detail SET Is_Selected = 1 WHERE Asset_Search_ID = @AssetSearchID and Asset_ID = @AssetID ";
			ExecuteSQLStatement(Constants.DBNAME_ASSET_TRACKING, sSQL);
		}

		public static void UpdateAssetRepairReceived(string ID, string received_disposition, string empid)
		{
			ArrayList arrNames = new ArrayList();
			ArrayList arrValues = new ArrayList();

			//ID
			arrNames.Add("ID");
			arrValues.Add(ID);

            //Received Disposition_ID
            arrNames.Add("Received_Disposition_ID");
            arrValues.Add(received_disposition);

			//Received_By_Emp_ID
			arrNames.Add("Received_By_Emp_ID");
			arrValues.Add(empid);

			ExecuteStoredProcNoResults(Constants.DBNAME_ASSET_TRACKING, Constants.STORED_PROC_UPDATE_ASSET_REPAIR_RECEIVED, arrNames, arrValues);
		}

		public static void UpdateAssetSearchDetailCheck(string assetSearch_ID, string asset_ID, string IsChecked)
		{
			ArrayList arrNames = new ArrayList();
			ArrayList arrValues = new ArrayList();

			//Asset_Search_ID
			arrNames.Add("Asset_Search_ID");
			arrValues.Add(assetSearch_ID);

			//Asset_ID
			arrNames.Add("Asset_ID");
			arrValues.Add(asset_ID);

			//Is_Checked
			arrNames.Add("Is_Checked");
			arrValues.Add(IsChecked);

			ExecuteStoredProcNoResults(Constants.DBNAME_ASSET_TRACKING, Constants.STORED_PROC_UPDATE_ASSET_SEARCH_DETAIL_CHECK, arrNames, arrValues);
		}

		public static void AssignAssetToBin(string p_Bin_ID, string p_Asset_ID, string p_Emp_ID, string p_Date)
		{
			ArrayList arrNames = new ArrayList();
			ArrayList arrValues = new ArrayList();

			//Bin ID
			arrNames.Add("Bin_ID");
			arrValues.Add(p_Bin_ID);

			//Asset_ID
			arrNames.Add("Asset_ID");
			arrValues.Add(p_Asset_ID);

			//Emp ID
			arrNames.Add("Emp_ID");
			arrValues.Add(p_Emp_ID);

			//Date
			arrNames.Add("Date");
			arrValues.Add(p_Date);

			ExecuteStoredProcNoResults(Constants.DBNAME_ASSET_TRACKING, Constants.STORED_PROC_SP_ASSIGN_ASSET_TO_BIN, arrNames, arrValues);
		}

        public static void Unassign_All_Bin_From_Asset_Temp_Detail(string headerid)
        {
            Utilities.Assert(!Utilities.isNull(headerid), "Asset Temp Header ID Expected.");
            ExecuteStoredProcNoResults(Constants.DBNAME_ASSET_TRACKING, Constants.STORED_PROC_SP_UNASSIGN_ALL_BIN_ASSET_TEMP_DETAIL, "HeaderID", headerid);
        }

		public static void AssignAssetToBinMassFromAssetSearch(string p_Asset_Search_ID, string p_Bin_ID, string p_Emp_ID, string p_Date)
		{

			ArrayList arrNames = new ArrayList();
			ArrayList arrValues = new ArrayList();

			//Asset_Search_ID
			arrNames.Add("Asset_Search_ID");
			arrValues.Add(p_Asset_Search_ID);

			//Bin ID
			arrNames.Add("Bin_ID");
			arrValues.Add(p_Bin_ID);

			//Emp ID
			arrNames.Add("Emp_ID");
			arrValues.Add(p_Emp_ID);

			//Date
			arrNames.Add("Date");
			arrValues.Add(p_Date);

			ExecuteStoredProcNoResults(Constants.DBNAME_ASSET_TRACKING, Constants.STORED_PROC_SP_ASSIGN_ASSET_TO_BIN_MASS_FROM_ASSET_SEARCH, arrNames, arrValues);
		}

        public static void SaveAssetDisposition(string asset_id, string disposition_id, string logged_on_user)
        {
            Utilities.Assert(!Utilities.isNull(asset_id), "Asset ID is required");

            string p_Modified_By_Emp_ID = Utilities.GetEmployeeIdByLoggedOn(logged_on_user);
            string p_Date_Modified = DateTime.Now.ToString();

            DatabaseUtilities.Upsert_Asset(
                    asset_id,
                    Constants.MCSDBNOPARAM,
                    disposition_id,
                    Constants.MCSDBNOPARAM,
                    Constants.MCSDBNOPARAM,
                    Constants.MCSDBNOPARAM,
                    Constants.MCSDBNOPARAM,
                    Constants.MCSDBNOPARAM,
                    Constants.MCSDBNOPARAM,
                    Constants.MCSDBNOPARAM,
                    Constants.MCSDBNOPARAM,
                    Constants.MCSDBNOPARAM,
                    Constants.MCSDBNOPARAM,
                    Constants.MCSDBNOPARAM,
                    p_Modified_By_Emp_ID,
                    p_Date_Modified
                );
        }

        //Transfer Asset
        public static void SaveTransferAsset(string p_Asset_Search_ID, string p_Asset_ID, string p_Transfer_Site_ID, string p_Emp_ID, string p_Date)
        {
            ArrayList arrNames = new ArrayList();
            ArrayList arrValues = new ArrayList();

            //Asset Search ID
            arrNames.Add("Asset_Search_ID");
            arrValues.Add(p_Asset_Search_ID);

            //Asset ID
            arrNames.Add("Asset_ID");
            arrValues.Add(p_Asset_ID);

            //Transfer_Site_ID
            arrNames.Add("Transfer_SIte_ID");
            arrValues.Add(p_Transfer_Site_ID);

            //Emp ID
            arrNames.Add("Emp_ID");
            arrValues.Add(p_Emp_ID);

            //Date
            arrNames.Add("Date");
            arrValues.Add(p_Date);

            ExecuteStoredProcNoResults(Constants.DBNAME_ASSET_TRACKING, Constants.STORED_PROC_SP_TRANSFER_ASSET, arrNames, arrValues);
        }

		//Student Check Out
		public static void StudentCheckOut(string p_Student_ID, string p_Tag_ID, string p_Emp_ID, string p_Date)
		{
			ArrayList arrNames = new ArrayList();
			ArrayList arrValues = new ArrayList();

			//Student ID
			arrNames.Add("Student_ID");
			arrValues.Add(p_Student_ID);

			//Tag_ID
			arrNames.Add("Tag_ID");
			arrValues.Add(p_Tag_ID);

			//Emp ID
			arrNames.Add("Emp_ID");
			arrValues.Add(p_Emp_ID);

			//Date
			arrNames.Add("Date");
			arrValues.Add(p_Date);

			ExecuteStoredProcNoResults(Constants.DBNAME_ASSET_TRACKING, Constants.STORED_PROC_SP_STUDENT_CHECK_OUT, arrNames, arrValues);
		}

		//Student Check In
		public static void StudentCheckIn(
			string p_Asset_Student_Transaction_ID,
            string p_Check_In_Type_Code,
			string p_Disposition_ID,
            string p_Is_Police_Report_Provided,
			string p_Check_In_Condition_ID,
			string p_Bin_ID,
			string p_Comments,
			string p_Attachments,
            string p_Stu_Responsible_For_Damage,
			string p_Emp_ID,
			string p_Date
		)
		{
			ArrayList arrNames = new ArrayList();
			ArrayList arrValues = new ArrayList();

			//Asset Student Transaction ID
			arrNames.Add("Asset_Student_Transaction_ID");
			arrValues.Add(p_Asset_Student_Transaction_ID);

            //Check In Type Code
            arrNames.Add("Check_In_Type_Code");
            arrValues.Add(p_Check_In_Type_Code);

			//Disposition ID
			arrNames.Add("Disposition_ID");
			arrValues.Add(p_Disposition_ID);

            //Is_Police_Report_Provided
            arrNames.Add("Is_Police_Report_Provided");
            arrValues.Add(p_Is_Police_Report_Provided);

			//Check In Condition ID
			arrNames.Add("Check_In_Condition_ID");
			arrValues.Add(p_Check_In_Condition_ID);

			//Bin ID
			arrNames.Add("Bin_ID");
			arrValues.Add(p_Bin_ID);

			//Comments
			arrNames.Add("Comments");
			arrValues.Add(p_Comments);

			//Attachment
			arrNames.Add("Attachments");
			arrValues.Add(p_Attachments);

            //Stu_Responsible_For_Damage
            arrNames.Add("Stu_Responsible_For_Damage");
            arrValues.Add(p_Stu_Responsible_For_Damage);

			//Emp ID
			arrNames.Add("Emp_ID");
			arrValues.Add(p_Emp_ID);

			//Date
			arrNames.Add("Date");
			arrValues.Add(p_Date);

            ExecuteStoredProcNoResults(Constants.STORED_PROC_SP_STU_CHECK_IN, arrNames, arrValues);
		}

        //Student Follow Up
        public static void StudentFollowUp(
            string p_Asset_Student_Transaction_ID,
            string p_Is_Asset_Belong_To_Student,
            string p_New_Tag_ID,
            string p_Disposition_ID,
            string p_Condition_ID,
            string p_Bin_ID,
            string p_Comments,
            string p_Attachments,
            string p_Stu_Responsible_For_Damage,
            string p_Emp_ID,
            string p_Date
        )
        {
            ArrayList arrNames = new ArrayList();
            ArrayList arrValues = new ArrayList();

            //Asset Student Transaction ID
            arrNames.Add("Asset_Student_Transaction_ID");
            arrValues.Add(p_Asset_Student_Transaction_ID);

            //Check In Type Code
            arrNames.Add("Is_Asset_Belong_To_Student");
            arrValues.Add(p_Is_Asset_Belong_To_Student);
            
            //Is_Police_Report_Provided
            arrNames.Add("New_Tag_ID");
            arrValues.Add(p_New_Tag_ID);
            
            //Disposition ID
            arrNames.Add("Disposition_ID");
            arrValues.Add(p_Disposition_ID);

            //Check In Condition ID
            arrNames.Add("Condition_ID");
            arrValues.Add(p_Condition_ID);

            //Bin ID
            arrNames.Add("Bin_ID");
            arrValues.Add(p_Bin_ID);

            //Comments
            arrNames.Add("Comments");
            arrValues.Add(p_Comments);

            //Comments
            arrNames.Add("Attachments");
            arrValues.Add(p_Attachments);

            //Stu_Responsible_For_Damage
            arrNames.Add("Stu_Responsible_For_Damage");
            arrValues.Add(p_Stu_Responsible_For_Damage);

            //Emp ID
            arrNames.Add("Emp_ID");
            arrValues.Add(p_Emp_ID);

            //Date
            arrNames.Add("Date");
            arrValues.Add(p_Date);

            ExecuteStoredProcNoResults(Constants.STORED_PROC_SP_STU_FOLLOW_UP, arrNames, arrValues);
        }
	
		//Return Data Set Queries
		#region Get Data Queries

        public static string GetPreviousDispositionFromAuditByAssetID(string p_Asset_ID)
        {
            Utilities.Assert(!Utilities.isNull(p_Asset_ID), "Asset ID not provided");
            Utilities.Assert(Utilities.IsNumeric(p_Asset_ID), "Asset ID must be numeric");

            string sSQL = @"DECLARE @Asset_ID AS INT
                            SET @Asset_ID = " + p_Asset_ID + @"

                            select 
	                            top 1 l.*
                            from Asset a
                            inner join Audit_Log l
	                            on l.Primary_Key_ID = a.ID
                            where 1=1
	                            and l.Table_Name = 'Asset'
	                            and l.Column_Name = 'Asset_Disposition_ID'
	                            and a.ID = @Asset_ID
                            order by
	                            l.ID desc";

            DataSet ds = ExecuteSQLStatement(sSQL);

            if (ds.Tables[0].Rows.Count > 0)
            {
                return ds.Tables[0].Rows[0][Constants.COLUMN_AUDIT_LOG_Old_Value].ToString();
            }

            return "";
        }

		public static string GetAssetIDByTagID(string tagid)
		{
			DataSet ds = DsGetByTableColumnValue(Constants.DBNAME_ASSET_TRACKING, Constants.TBL_ASSET, "Tag_ID", tagid, "");
			if (ds.Tables[0].Rows.Count > 0)
			{
				return ds.Tables[0].Rows[0][Constants.COLUMN_ASSET_ID].ToString();
			}
			return "";
		}

		/// <summary>
		/// Get Code Tables By Name
		/// </summary>
		/// <param name="isDisplayActiveOnly">True will display only active sites</param>
		/// <returns></returns>
		public static DataSet DsGet_CTByTableName(string cT_TableName, bool isDisplayActiveOnly)
		{
			string sFilterActive = "";
			if (isDisplayActiveOnly)
			{
				sFilterActive = "AND Is_Active = 1 ";
			}
			string sOrderBy = "ORDER BY NAME";


			string sSQL = @"Select 
								*
							from " + cT_TableName + @" 
							Where 1=1 " 
							+ sFilterActive 
							+ sOrderBy;

			return ExecuteSQLStatement(Constants.DBNAME_ASSET_TRACKING, sSQL);
		}

		/// <summary>
		/// Get bin by site
		/// </summary>
		/// <param name="isDisplayActiveOnly">True will only display active bins</param>
		/// <param name="siteID"site will return bin associated to site. Site can take a comma separated list of all sites with no spaces. </param>
		/// <returns></returns>
		public static DataSet DsGetBinBySiteForDDL(bool isDisplayActiveOnly, bool isDisplayAvailableOnly, string siteID)
		{
			//remove any spances
			siteID = siteID.Replace(" ", "");
			
			string sActiveFilter = "";
			string sSiteFilter = "";
			string sAvailableFilter = "";

			string sOrderBy = " ORDER BY b.Number";
		  
			//Active Filter
			if (isDisplayActiveOnly)
			{
				sActiveFilter = " AND b.Is_Active = 1 ";
			}
			//Available Filter
			if (isDisplayAvailableOnly)
			{
				sAvailableFilter = " AND b.Available_Capacity <> 0 ";
			}

			//Site Filter
			if (!siteID.Equals(Constants._OPTION_ALL_VALUE))
			{
				sSiteFilter = " AND b.Site_ID = '" + siteID + "' ";
			}
			
			if (siteID.Contains(','))
			{
				sSiteFilter = " AND b.Site_ID in (select * from CSVToTable('" + siteID + "', ',')) ";
			}


			string sSQL = @"SELECT 
								*
							FROM dbo.v_Bin b
							WHERE 1=1  "
						   + sActiveFilter
						   + sAvailableFilter
						   + sSiteFilter
						   + sOrderBy;

			return ExecuteSQLStatement(Constants.DBNAME_ASSET_TRACKING, sSQL);
		}

		public static DataSet DsGetCTSiteInfo(bool isDisplayActiveOnly, bool isApplySiteSecurity)
		{
			string sActiveFilter = "";
			string sSecurityFilter = "";
			string sOrderBy = " ORDER BY s.NAME ";

			//Active Filter
			if (isDisplayActiveOnly)
			{
				sActiveFilter = " AND s.Is_Active = 1 ";
			}

			//Site Security Filter
			if (isApplySiteSecurity)
			{
				sSecurityFilter = " AND s.code in (select Site_Code from GetUserSiteSecurity('" + Utilities.GetLoggedOnUser() + "')) ";
			}

			string sSQL = @"SELECT * 
							From CT_Site s 
							WHERE 1=1 "
						  + sActiveFilter
						  + sSecurityFilter
						  + sOrderBy;

			return ExecuteSQLStatement(sSQL);
		}

		/// <summary>
		/// Get Asset Type by Base Type ID
		/// </summary>
		/// <param name="isDisplayActiveOnly">True will only display active types</param>
		/// <param name="Asset_Base_Type_ID">Asset_Base_Type_ID</param>
		/// <returns></returns>
		public static DataSet DsGetAssetTypeByBaseTypeDDL(bool isDisplayActiveOnly, string Asset_Base_Type_ID)
		{
			//remove any spances
			Asset_Base_Type_ID = Asset_Base_Type_ID.Replace(" ", "");

			string sActiveFilter = "";
			string sSiteFilter = "";
			string sOrderBy = " ORDER BY a.Name";

			//Active Filter
			if (isDisplayActiveOnly)
			{
				sActiveFilter = " AND a.Is_Active = 1 ";
			}

			//Site Filter
			if (!Asset_Base_Type_ID.Equals(Constants._OPTION_ALL_VALUE))
			{
				sSiteFilter = " AND a.Asset_Base_Type_ID = '" + Asset_Base_Type_ID + "' ";
			}

			if (Asset_Base_Type_ID.Contains(','))
			{

				sSiteFilter = " AND a.Asset_Base_Type_ID in (select * from CSVToTable('" + Asset_Base_Type_ID + "', ',')) ";
			}


			string sSQL = @"select *
							from CT_Asset_Type a
							WHERE 1=1  "
						   + sActiveFilter
						   + sSiteFilter
						   + sOrderBy;

			return ExecuteSQLStatement(Constants.DBNAME_ASSET_TRACKING, sSQL);
		}

		public static DataSet DsGetEmployeeInfoByIdOrLoggedOnUsert(string sIdOrLoggedOnUser)
		{
			string sSQL = @"DECLARE @IDOrLoggedOnUser AS VARCHAR(max)
							SET @IDOrLoggedOnUser = '" + sIdOrLoggedOnUser + @"'

							SELECT
								CASE 
									when ISNULL(ltrim(rtrim(e.PreferredName)), '') <> '' then 
										dbo.PROPERCASE(e.PreferredName + ' ' + e.LastName)
									else
										dbo.PROPERCASE(e.FirstName + ' ' + e.LastName)
								END as displayname,
								rtrim(replace(e.EMailAddress, '@monet.k12.ca.us', '')) as emp_login,
								e.* 
							FROM dbo.Employees e 
							WHERE e.empdistid = @IDOrLoggedOnUser 
								OR e.EMailAddress = @IDOrLoggedOnUser + '@monet.k12.ca.us'";

			DataSet ds = ExecuteSQLStatement(Constants.DBNAME_DATAWAREHOUSE, sSQL);
			int iRowCount = ds.Tables[0].Rows.Count;
			bool test = iRowCount < 1;

			Utilities.Assert(iRowCount < 2, "Get employee information should not return more than 1 record.");

			return ds;
			
		}

		public static DataSet DsGetAssetTempHeaderDetailByHeaderID(string sHeaderID)
		{
            /* IMPORTANT Any validation added to this stored proc will need to be added to stored proc: 
             * 1. sp_Validate_On_Add_Asset_To_Temp
            */
            ArrayList arrNames = new ArrayList();
            ArrayList arrValues = new ArrayList();

            //Attachment Type
            arrNames.Add("HeaderID");
            arrValues.Add(sHeaderID);

            return ExecuteStoredProc(Constants.STORED_PROC_SP_ASSET_TEMP_WITH_VALIDATION_MESSAGE, arrNames, arrValues);
		}

		public static DataSet DsGetPreviousAssetTempLoad(string sSiteListId, string batchStatus, string entered_by_emp, string order_by)
		{

			string setBatchStatus = "";
			string sWhereClauseBatchStatus = "";
			string sWhereSiteList = "";
            string sWhereClauseEnteredByEmp = "";
            string sOrderBy = " ORDER BY v.Update_Date DESC";

			switch (batchStatus)
			{
				case "1": //Pending
					setBatchStatus = "SET @BatchStatus = '0'";
					break;
				case "2": //Submitted
					setBatchStatus = "SET @BatchStatus = '1'";
					break;
				case "3": //All
				default:
					//Do Nothing
					break;
			}

			if (!Utilities.isNull(setBatchStatus))
			{
				sWhereClauseBatchStatus = " AND v.Has_Submit = @BatchStatus ";
			}

			if (!Utilities.isNull(sSiteListId))
			{
				sWhereSiteList = " AND v.Asset_Site_ID in (select * from dbo.CSVToTable(@SiteList,','))";
			}

            if (!entered_by_emp.Contains("-") && !Utilities.isNull(entered_by_emp))
            {
                sWhereClauseEnteredByEmp = " AND v.Added_By_Emp_ID = @EnteredByEmp ";
            }

            if (!Utilities.isNull(order_by))
            {
                sOrderBy = " ORDER BY " + order_by;
            }

			string sSQL = @"DECLARE @SiteList as Varchar(1000)
							DECLARE @BatchStatus as Varchar(10)
                            DECLARE @EnteredByEmp as Varchar(11)
                            
                            SET @EnteredByEmp = '" + entered_by_emp + @"'  
							SET @SiteList = '" + sSiteListId + @"' "
							+
							setBatchStatus     
							+ @"

							select *
							from v_Add_Asset_Previous_Batch v
							where 1=1 "
							+ sWhereSiteList
							+ sWhereClauseBatchStatus 
                            + sWhereClauseEnteredByEmp
                            + sOrderBy;

			return ExecuteSQLStatement(Constants.DBNAME_ASSET_TRACKING, sSQL);
		}

		public static DataSet DsGetAssetHeaderMostRecentDetail(string headerid)
		{
			return ExecuteStoredProc(Constants.STORED_PROC_SP_GET_ADD_ASSET_TEMP_HEADER_DETAIL_INFO, "ID", headerid);
		}

		public static DataSet DsGetByTableColumnValue(string tableName, string ColumnName, string ColumnValue, string sOrder)
		{
			return DsGetByTableColumnValue(Constants.DBNAME_ASSET_TRACKING, tableName, ColumnName, ColumnValue, sOrder);
		}

		/// <summary>
		/// Generic method to get dataset for a given table by id or full dataset. This will only return tables with ID as primary key.
		/// </summary>
		/// <param name="tableName">Name of the table</param>
		/// <param name="ColumnName">Name of column to filter by</param>
		/// <param name="ColumnValue">Value column</param>
		/// <param name="sOrder">Order By Clause</param>
		/// <returns>Dataset for the table where @ColumnName = @ColumnValue, If @ColumnValue = -1, it will return full dataset</returns>
		public static DataSet DsGetByTableColumnValue(string database, string tableName, string ColumnName, string ColumnValue, string sOrder)
		{
			Utilities.Assert(!Utilities.isNull(database) || !Utilities.isNull(tableName) || !Utilities.isNull(ColumnName), "All paramter must be provided: database, table name");

			//initialize variables
			string sDeclare = "";
			string sWhereClause = "";
			string sOrderBy = "";

			//Filter Clause
			//if (!ColumnValue.Trim().Equals("-1"))
			//{
				sDeclare = @"DECLARE @ColumnValue as varchar(20) 
							 SET @ColumnValue = '" + ColumnValue + "'";
				sWhereClause = " WHERE " + ColumnName + " = @ColumnValue";
			//}

			//Order By
			if (!Utilities.isNull(sOrder))
			{
				sOrderBy = " ORDER BY " + sOrder;
			}

			string sSQL = sDeclare + " select * from " + tableName + sWhereClause + sOrderBy;
			return ExecuteSQLStatement(database, sSQL);
		}

		/// <summary>
		/// COLUMNS:   
		/// Asset_ID, 
		/// Asset_Site_ID, 
		/// Asset_Site_Desc, 
		/// Asset_Assignment_Type_ID, 
		/// Asset_Assignment_Type_Desc, 
		/// Asset_Disposition_ID, 
		/// Asset_Disposition_Desc, 
		/// Asset_Condition_ID, 
		/// Asset_Condition_Desc, 
		/// Asset_Type_ID, 
		/// Asset_Type_Desc, 
		/// Date_Purchased, 
		/// Added_By_Emp_ID, 
		/// Added_By_Emp_Desc, 
		/// Modified_By_Emp_ID, 
		/// Modified_By_Emp_Desc 
		/// </summary>
		/// <param name="sWhereClause">Where Clause</param>
		/// <param name="sOrder">Order By</param>
		/// <returns></returns>
		public static DataSet DsGetAssetMasterList(string sWhereClause, string sAsset_Search_ID)
		{
            string sSQL = @"DECLARE @Asset_Search_ID int
                            SET @Asset_Search_ID = " + sAsset_Search_ID + @"

                            select 
								v.*,
								isnull(d.Is_Checked, 0) as Is_Checked
							from v_Asset_Master_List v 
							left join Asset_Search_Detail d
								on d.Asset_ID = v.Asset_ID
								and d.Asset_Search_ID = @Asset_Search_ID
							" + sWhereClause + " ORDER BY d.Sort_Order ";// + sOrder;

			return ExecuteSQLStatement(sSQL);
		}

		public static DataSet DsGetStudentSearch(string student_ids, string sOrderBy)
		{
			string sSetStudentID = "";
			string sWhereClause = "";
			string sWhereUserAccessibleSite = "";

			//Student ID(s)
			if (!Utilities.isNull(student_ids))
			{
				sSetStudentID = " SET @StudentIDS = '" + student_ids + "' ";
				sWhereClause = " AND v.Student_ID IN (SELECT * FROM dbo.CSVToTable(@StudentIDS,','))";
			}

			//Read Only User
			bool isReadOnlyUser = AppSecurity.Current_User_Access_Level().Equals(AppSecurity.ROLE_READ_ONLY);
			if (isReadOnlyUser)
			{
				sWhereUserAccessibleSite = " AND v.Student_Current_School in (select Site_Code from dbo.GetUserSiteSecurity('" + Utilities.GetLoggedOnUser() + "')) ";
			}

			//Sort
			if (!Utilities.isNull(sOrderBy))
			{
				sOrderBy = " ORDER BY " + sOrderBy;
			}

			string sSQL = @"DECLARE @StudentIDs as VARCHAR(MAX) " +
							sSetStudentID + 
						   @" SELECT * 
							  FROM v_Student_Asset_Search v
							  WHERE 1=1 "
						   + sWhereClause
						   + sWhereUserAccessibleSite
						   + sOrderBy;

			return ExecuteSQLStatement(sSQL);
		}

		public static DataSet DsGetUserAccessibleStudentSearch(string student_ids)
		{
			string sSetStudentID = "";
			string sWhereClauseStudent = "";

			//Student ID(s)
			if (!Utilities.isNull(student_ids))
			{
				sSetStudentID = " SET @StudentIDS = '" + student_ids + "' ";
				sWhereClauseStudent = " AND s.StudentId IN (SELECT * FROM dbo.CSVToTable(@StudentIDs,','))";
			}

			string sSQL = @"DECLARE @StudentIDs as VARCHAR(MAX) " +
							sSetStudentID +
						   @" select 
								Count(*) as Total
							from Datawarehouse.dbo.Student s
							where 1=1
								and s.SasiSchoolNum not in (
									select Site_Code from dbo.GetUserSiteSecurity('" + Utilities.GetLoggedOnUser() + @"')
								) "
								+ sWhereClauseStudent;

			return ExecuteSQLStatement(sSQL);
		}

		public static DataSet DsGetTabByView(string dbViewName, string AssetID, string id, string orderby)
		{
			Utilities.Assert(!Utilities.isNull(dbViewName), "View not provided");

			StringBuilder sbDeclare = new StringBuilder();
			StringBuilder sbWhere = new StringBuilder();


			if (!Utilities.isNull(AssetID))
			{
				sbDeclare.Append(" DECLARE @Asset_ID as int SET @Asset_ID = " + AssetID);
				sbWhere.Append(" AND v.Asset_ID = @Asset_ID ");
			}
			if (!Utilities.isNull(id))
			{
				sbDeclare.Append(" DECLARE @ID as int SET @ID = " + id);
				sbWhere.Append(" AND v.ID = @ID ");
			}
			if (!Utilities.isNull(orderby))
			{
				orderby = " ORDER BY " + orderby;
			}


			string sSQL = sbDeclare.ToString() + " Select * from " + dbViewName + " v WHERE 1=1 " + sbWhere.ToString() + orderby;
			return ExecuteSQLStatement(Constants.DBNAME_ASSET_TRACKING, sSQL);

		}

		public static DataSet DsGetAssetInfoByID(string AssetID)
		{
			Utilities.Assert(!Utilities.isNull(AssetID), "Asset ID not provided");
			string sSQL = @"DECLARE @Asset_ID as int
							SET @Asset_ID = " + AssetID + @"
							
							select *
							from v_Asset_Master_List v 
							where v.Asset_ID = @Asset_ID";
			return ExecuteSQLStatement(Constants.DBNAME_ASSET_TRACKING, sSQL);
		}

        public static DataSet DsGetAssetInfoByTagID(string tag_id)
        {
            Utilities.Assert(!Utilities.isNull(tag_id), "Tag ID not provided");
            string sSQL = @"DECLARE @Tag_ID AS VARCHAR(100)
							SET @Tag_ID = '" + tag_id + @"'
							
							select *
							from v_Asset_Master_List v 
							where v.Tag_ID = @Tag_ID";
            return ExecuteSQLStatement(Constants.DBNAME_ASSET_TRACKING, sSQL);
        }

		public static DataSet DsGetAssetAttachmentInfoByID(string id)
		{
			Utilities.Assert(!Utilities.isNull(id), "ID not provided");
			string sSQL = @"DECLARE @ID int
							SET @ID = " + id + @"

							select 
								attachment.Name + '.' + ft.Name as FileNameType,
								attachment.*
							from Asset_Attachment attachment
							inner join CT_File_Type ft
								on ft.ID = attachment.File_Type_ID
							where attachment.ID = @ID";
			return ExecuteSQLStatement(Constants.DBNAME_ASSET_TRACKING, sSQL);
		}

		public static DataSet DsGetAssetSearchForNavigation(string asset_search_id, string asset_id)
		{
			Utilities.Assert(!Utilities.isNull(asset_search_id) || !Utilities.isNull(asset_id), "Asset Search ID and Asset ID must both be set. Asset Search value = " + asset_search_id + " and Asset ID = " + asset_id);
			string sSQL = @"DECLARE @Asset_Search_ID AS INT 
							DECLARE @Asset_ID AS INT 

							SET @Asset_Search_ID = " + asset_search_id + @"
							SET @Asset_ID = " + asset_id + @"

							select 
								det.Asset_ID as Selected_Asset_ID,
								det.Sort_Order as Selected_Sort_Order,
								(select count(*) from Asset_Search_Detail where Asset_Search_ID = det.Asset_Search_ID) as Total,
								prev.Asset_ID as Previous_Asset_ID,
								nex.Asset_ID as Next_Asset_ID,
								las.Asset_ID as Last_Asset_ID,
								firs.Asset_ID as First_Asset_ID

							from Asset_Search_Detail det
							left join Asset_Search_Detail prev
								on prev.Asset_Search_ID = det.Asset_Search_ID
								and prev.Sort_Order = det.Sort_Order - 1
							left join Asset_Search_Detail nex
								on nex.Asset_Search_ID = det.Asset_Search_ID
								and nex.Sort_Order = det.Sort_Order + 1
							left join Asset_Search_Detail firs
								on firs.Asset_Search_ID = det.Asset_Search_ID
								and firs.Sort_Order = 1
							left join Asset_Search_Detail las
								on las.Asset_Search_ID = det.Asset_Search_ID
								and las.Sort_Order = (select count(*) from Asset_Search_Detail where Asset_Search_ID = det.Asset_Search_ID)

							where det.Asset_Search_ID = @Asset_Search_ID
								and det.Asset_ID = @Asset_ID";
			return ExecuteSQLStatement(Constants.DBNAME_ASSET_TRACKING, sSQL);
		}

		public static DataSet DsGetStudentByAssetID(string assetid)
		{
			Utilities.Assert(!Utilities.isNull(assetid), "Asset ID not provided");
			string sSQL = @"DECLARE @Asset_ID as int
							SET @Asset_ID = " + assetid + @"

							select 
								ast.ID,
								s.LastName + ', ' + s.FirstName + ' (School Year: ' + CAST(ast.School_Year as varchar(10)) + ')'  as Student_Name
							from Asset_Student_Transaction ast
							inner join Datawarehouse.dbo.Student s
								on ast.Student_ID = s.StudentID
							where ast.Asset_ID = @Asset_ID

							order by Student_Name, ast.School_Year desc ";
			return ExecuteSQLStatement(Constants.DBNAME_ASSET_TRACKING, sSQL);
		}

		public static DataSet DsGetBinInfo(string siteids, string startnumber, string endnumber, string capacity, string description, string orderby)
		{
			Utilities.Assert(!Utilities.isNull(siteids), "Site not provided");

			string sSetStart = "";
			string sSetEnd = "";

			string sWhereStartNumber = "";
			string sWhereEndNumber = "";

			//Start Number
			if (!Utilities.isNull(startnumber))
			{
				sSetStart = " SET @StartNumber = " + startnumber + " ";
				sWhereStartNumber = " AND b.Number >= @StartNumber ";
			}

			//End Number
			if (!Utilities.isNull(endnumber))
			{
				sSetEnd = " SET @EndNumber = " + endnumber + " ";
				sWhereEndNumber = " AND b.Number <= @EndNumber ";
			}


			//Capacity
			string sWhereCapacity = "";
			switch (capacity)
			{
				case "4"://Full
					sWhereCapacity = " and b.Available_Capacity <= 0 ";
					break;
				case "3"://Used
					sWhereCapacity = " and b.Asset_Count > 0 ";
					break;
				case "2"://Available
					sWhereCapacity = " and b.Available_Capacity > 0 ";
					break;
				case "1": //All
				default:
						//Do Nothing
					break;
			}

			if (!Utilities.isNull(orderby))
			{
				orderby = "ORDER BY " + orderby;
			}

			string sSQL = @"DECLARE @SiteList as varchar(max)
							DECLARE @StartNumber as int
							DECLARE @EndNumber as int
							DECLARE @Description as varchar(1000)

							SET @SiteList = '" + siteids + "'"
						  + sSetStart
						  + sSetEnd
					   + @" SET @Description = '%" + description.Trim() + @"%'
							

							select *
							from v_Bin b
							where 1=1
								and b.Site_ID in (
									select * from dbo.CSVToTable(@SiteList,',')
								) "
							+ sWhereCapacity
							+ sWhereStartNumber
							+ sWhereEndNumber
							+ " AND isnull(b.Bin_Description,'') like @Description "
							+ orderby;
			return ExecuteSQLStatement(Constants.DBNAME_ASSET_TRACKING, sSQL);
		}

		public static DataSet DsGetStudentInfo(string searchtext, string isActive, string studentid, bool IsApplySiteLevelSecurity)
		{
			string setFirstName = "";
			string setLastName = "";
			string setStudentID = "";

			string whereClauseFirstName = "";
			string whereClauseLastName = "";
			string whereGenericSearch = "";
			string whereActive = "";
			string whereStudentID = "";
			string innerJoinAccessibleSite = "";

			if (!Utilities.isNull(studentid))
			{
				setStudentID = " SET @StudentID = '" + studentid + "'";
				whereStudentID = " AND s.StudentId = @StudentID";
			}

			if (searchtext.Contains(","))
			{
				string[] arrText = searchtext.Split(',');

				setFirstName = "SET @FirstName = '" + arrText[1].Trim() + "'";
				setLastName = "SET @LastName = '" + arrText[0] + "'";

				whereClauseFirstName = "AND s.firstname like + @FirstName + '%' ";
				whereClauseLastName = "AND s.lastname like + @LastName + '%' ";
			}
			else
			{
				whereGenericSearch = @"and (
									s.StudentId like '%' + @SearchText + '%'
									or
									s.FirstName like '%' + @SearchText + '%'
									or
									s.LastName like '%' + @SearchText + '%'
								) ";
			}

			switch (isActive)
			{
				case "3": //Inactive Student
					whereActive = " AND s.StudentStatus is not null ";
					break;
				case "2": //Active Student
					whereActive = " AND s.StudentStatus is null ";
					break;
				case "1": //All Student
				default:
					//do nothing
					break;
			}
			
		
			//Apply SiteLevelSecurity to student
			if (IsApplySiteLevelSecurity)
			{
				//Is Current user District tech role
				bool isCurrentUserDistrictTech = AppSecurity.Current_User_Access_Level().Equals(AppSecurity.ROLE_DISTRICT_TECH);

				//Apply security if not district tech
				if (!isCurrentUserDistrictTech)
				{
                    innerJoinAccessibleSite = @" inner join Asset_Tracking.dbo.GetUserSiteSecurity('" + Utilities.GetLoggedOnUser() + @"') accessibleSite
													on accessibleSite.Site_Code = case 
                                                                                    when cur_sch.SasiSchoolNum is not null then cur_sch.SasiSchoolNum
                                                                                    when s.SasiSchoolNum = '999' then Graduated_SchoolId 
                                                                                    else s.SasiSchoolNum 
                                                                                  end ";
				}
			}


            string sSQL = @"DECLARE @SearchText as varchar(100)
							DECLARE @FirstName as varchar(100)
							DECLARE @LastName as varchar(100)
							DECLARE @IsActive as varchar(10)
							DECLARE @StudentID as varchar(20)

							Set @SearchText = '" + searchtext + @"' "
                          + setFirstName
                          + setLastName
                          + setStudentID +

                            @" select top 50
								s.StudentId,
								s.FirstName,
								s.LastName,
								s.LastName + ', ' + s.FirstName + case when s.MiddleName IS NOT NULL THEN ' ' + s.MiddleName else '' end as StudentFullName,
                                case when isnumeric(s.Grade) = 1 then cast(abs(s.Grade) as varchar) else s.Grade end as Grade,
								s.Gender,
								case when s.SasiSchoolNum = '999' then Graduated_SchoolId else s.SasiSchoolNum end as SasiSchoolNum,
								sch.ShortName,
								sch.Name + case when s.SasiSchoolNum = '999' then ' (' + gradSchool.Name + ')' else '' end as StudentSchoolName,
                                cur_sch.SasiSchoolNum as Current_Enroll_School_Num,
	                            cur_sch.Name as Current_Enroll_School_Name,
                                'Secondary Enrollment:&nbsp;' + cur_sch.Name + '<br/>' as Current_Enroll_School_Name_Display,
								s.StudentStatus,
								case when s.DisabilityCode is null then 'No' else 'Yes' end as SpecialEd,
								case when s.StudentStatus is null then 'Active' else 'Inactive' end as StudentStatusDesc,
								case when coverage.ID is not null then 'Yes' else 'No' end as HasServiceInsuranceFee,
								Asset_Tracking.dbo.FormatDateTime(s.BirthDate,'MM/DD/YYYY') as BirthDateFormatted,
								mcs.dbo.FormatPhone(s.HomePhoneNumber) as home_phone_formatted,
                                
                                /*START StudentDesc*/
                                '&nbsp;' + s.StudentId + ' &nbsp;&nbsp;&nbsp; ' + s.LastName + ', ' + s.FirstName 
		                        + case 
			                        when s.MiddleName is not null then ' ' + s.MiddleName 
			                        else '' 
		                          end 
		                        + '&nbsp;&nbsp;&nbsp;&nbsp;|&nbsp;&nbsp;&nbsp;' 
		                        + case 
			                        when isnumeric(s.Grade) = 1 then cast(abs(s.Grade) as varchar) + 'th' 
			                        else s.Grade 
		                          end 
		                        + '&nbsp;&nbsp;&nbsp; ' 
		                        + case 
			                        when s.SasiSchoolNum = '999' then gradSchool.ShortName 
			                        else sch.ShortName 
		                          end
		                        + case 
			                        when cur_sch.SasiSchoolNum is not null then '&nbsp;&nbsp;&nbsp; | &nbsp;&nbsp;&nbsp; Secondary Enrollment: ' + cur_sch.ShortName 
			                        else '' 
		                          end
		                        + '&nbsp;&nbsp;' as StudentDesc
                                /*END Student DESC*/ 				

							from Datawarehouse.dbo.Student s
							inner join datawarehouse.dbo.School sch
								on s.SasiSchoolNum = sch.SchoolNum
							left join Asset_Tracking.dbo.Student_Device_Coverage coverage
								on coverage.Student_ID = s.StudentId
								and coverage.Is_Active = 1
								and coverage.School_Year = Datawarehouse.dbo.getCurrentYearYYYY()
							left join Datawarehouse.dbo.School gradSchool
								on gradSchool.SchoolNum = s.Graduated_SchoolId 
                            left join (
	                            select 
		                            e.StudentId,
		                            e.SchoolAttn
	                            from student_enrollment e
	                            where 1=1 
	                            and e.HS = 1
	                            and GETDATE() between e.EffDate and e.EndDate
                            ) current_enroll_school
	                            on current_enroll_school.StudentId = s.StudentId
                            left join Datawarehouse.dbo.School cur_sch
	                            on cur_sch.SasiSchoolNum = current_enroll_school.SchoolAttn
	                            and cur_sch.SasiSchoolNum <> sch.SasiSchoolNum
                            "
                          + innerJoinAccessibleSite + @"

							where 1=1
								and s.FirstName is not null 
								and s.LastName is not null 
								and s.SasiSchoolNum <> '100'
								and (
										sch.SchoolType in ('9-12', '7-8')
										or 
										(s.grade in ('07','08','09', '10', '11', '12') and s.SasiSchoolNum = '999') 
								)  
								"
                                + whereActive
                                + whereClauseFirstName
                                + whereClauseLastName
                                + whereGenericSearch
                                + whereStudentID

                           + @" order by 
									s.LastName, 
									s.FirstName,
									StudentStatusDesc,
									s.Grade ";

			return ExecuteSQLStatement(Constants.DBNAME_DATAWAREHOUSE, sSQL);

		}

		public static DataSet DsGetEmployeeInfoForLookup(string searchtext, string isActive, string employeeid)
		{
			string setFirstName = "";
			string setLastName = "";
			string setEmployeeID = "";

			string whereClauseFirstName = "";
			string whereClauseLastName = "";
			string whereGenericSearch = "";
			string whereActive = "";
			string whereEmployeeID = "";

			if (Utilities.isNull(employeeid))
			{
				if (searchtext.Contains(","))
				{
					string[] arrText = searchtext.Split(',');

					setFirstName = "SET @FirstName = '" + arrText[1].Trim() + "'";
					setLastName = "SET @LastName = '" + arrText[0] + "'";

					whereClauseFirstName = "AND e.firstname like + @FirstName + '%' ";
					whereClauseLastName = "AND e.lastname like + @LastName + '%' ";
				}
				else
				{
					whereGenericSearch = @"and (
										e.EmpDistID like '%' + @SearchText + '%'
										or
										e.FirstName like '%' + @SearchText + '%'
										or
										e.LastName like '%' + @SearchText + '%'
										or
										e.EMailAddress like + @SearchText + '%'
									) ";
				}

				switch (isActive)
				{
					case "3": //Inactive
						whereActive = " and e.TermDate < @Today ";
						break;
					case "2": //Active 
						whereActive = " and (e.TermDate is null or e.TermDate > @Today) ";
						break;
					case "1": //All
					default:
						//do nothing
						break;
				}
			}
			else
			{
				setEmployeeID = " SET @EmployeeID = '" + employeeid + "'";
				whereEmployeeID = " AND e.EmpDistID = @EmployeeID";
			}

			string sSQL = @"DECLARE @SearchText as varchar(100)
							DECLARE @FirstName as varchar(100)
							DECLARE @LastName as varchar(100)
							DECLARE @IsActive as varchar(10)
							DECLARE @EmployeeID as varchar(20)
							DECLARE @Today as Date
							DECLARE @FiscalYear as Int                            

							Set @SearchText = '" + searchtext + @"' "
						  + setFirstName
						  + setLastName
						  + setEmployeeID + @"
							
							SET @Today = GETDATE()
							SET @FiscalYear = MCS.dbo.GetFiscalYear(@Today); 
						
							with emp_position as (
								select *
								from Employee_Positions p
								where 1=1 
									and p.PrimaryPosition = 1
									and FiscalYear = @FiscalYear
									and @Today between p.effectivedate and isnull(p.enddate, @Today)
							)
				
							select distinct top 50
									e.EmpDistID,
									e.FirstName,
									e.LastName,
									e.MiddleName,
									e.PreferredName,
									e.TermDate,
									e.empdistid + ' - ' + dbo.PROPERCASE(
									e.LastName + ', ' + e.FirstName + 
									case 
										when e.MiddleName IS NOT NULL then 
											' ' + e.MiddleName 
										else 
											'' 
									end) +
									case 
										when e.TermDate < @Today then 
											' (Term: ' + format(e.TermDate, 'yyyy-MM-dd') + ')'
										else
											case when p.Position is not null then ' - ' + isnull(p.Position, '') else '' end
									end as EmployeeDisplayName,
									case when e.TermDate < @Today then 'True' else 'False' end as Is_Term,
									case when e.TermDate < @Today then 'Yes' else 'No' end as Is_Term_Desc

								from Employees e
								left join emp_position p
									on p.EmployeeID = e.EmployeeID

								where 1=1 "
									+ whereActive
									+ whereClauseFirstName
									+ whereClauseLastName
									+ whereGenericSearch
									+ whereEmployeeID

						   + @" order by 
									e.LastName, 
									e.FirstName ";

			return ExecuteSQLStatement(Constants.DBNAME_DATAWAREHOUSE, sSQL);

		}

		public static DataSet DsGetAvaiableCapacity(string header_id, string bin_id)
		{
			Utilities.Assert(!Utilities.isNull(header_id) && !Utilities.isNull(bin_id), "Header ID and Bin ID not provided");
			string sSQL = @"DECLARE @Bin_ID as INT
							DECLARE @Header_ID as int

							SET @Bin_ID = " + bin_id + @" 
							SET @Header_ID = " + header_id + @"

							select 
								b.ID,
								isnull(binAssignment.total_assigned_to_bin, 0) as TotalAssigned,
								isnull(b.Capacity, 0) as Capacity,
								isnull(current_batch.total,0) as Current_Batch_Total,
								isnull(b.Capacity,0) - isnull(binAssignment.total_assigned_to_bin, 0) - isnull(current_batch.total,0) as Available
							from Bin b
							left join (
								select
									Bin_ID,
									count(*) as total_assigned_to_bin
								from Asset_Bin_Mapping 
								group by Bin_ID
							) binAssignment
								on binAssignment.Bin_ID = b.ID
							left join (
								select 
									d.Bin_ID,
									count(*) as total
								from Asset_Temp_Detail d
								where d.Asset_Temp_Header_ID = @Header_ID
								group by
									d.Bin_ID
							) current_batch
								on current_batch.Bin_ID = b.ID
							where b.ID = @Bin_ID ";
			return ExecuteSQLStatement(Constants.DBNAME_ASSET_TRACKING, sSQL);
		}

		public static DataSet DsGetCondition(bool isDisplayActiveOnly, string businessRulelist, string orderBy)
		{
			string sWhereClauseIsActive = "";
			string sWhereClauseBusinessRule = "";


			if (isDisplayActiveOnly)
			{
				sWhereClauseIsActive = " AND c.Is_Active = 1 ";
			}

			if (!Utilities.isNull(businessRulelist))
			{
				sWhereClauseBusinessRule = @" AND c.Code in (
												select 
													d.Code
												from Business_Rule b
												inner join Business_Rule_Detail d
													on d.Business_Rule_ID = b.ID
												where 1=1
													and b.Code in (
														select * from dbo.CSVToTable(@Business_Rule_List,',')
													)
													and b.Table_Name = 'CT_Asset_Condition'
											)";
			}

			if (!Utilities.isNull(orderBy))
			{
				orderBy = " ORDER BY " + orderBy;
			}

			string sSQL = @"DECLARE @Business_Rule_List AS VARCHAR(MAX)
				
							SET @Business_Rule_List = '" + businessRulelist + @"'
							
							select 
								*
							from CT_Asset_Condition c
							where 1=1 "
						   + sWhereClauseIsActive
						   + sWhereClauseBusinessRule
						   + orderBy
						   ;

			return ExecuteSQLStatement(Constants.DBNAME_ASSET_TRACKING, sSQL);
		}

		public static DataSet DsGetDisposition(bool isDisplayActiveOnly, string businessRulelist, string orderBy)
		{
			string sWhereClauseIsActive = "";
			string sWhereClauseBusinessRule = "";


			if (isDisplayActiveOnly)
			{
				sWhereClauseIsActive = " AND c.Is_Active = 1 ";
			}

			if (!Utilities.isNull(businessRulelist))
			{
				sWhereClauseBusinessRule = @" AND c.Code in (
												select 
													d.Code
												from Business_Rule b
												inner join Business_Rule_Detail d
													on d.Business_Rule_ID = b.ID
												where 1=1
													and b.Code in (
														select * from dbo.CSVToTable(@Business_Rule_List,',')
													)
													and b.Table_Name = 'CT_Asset_Disposition'
											)";
			}

			if (!Utilities.isNull(orderBy))
			{
				orderBy = " ORDER BY " + orderBy;
			}

			string sSQL = @"DECLARE @Business_Rule_List AS VARCHAR(MAX)
				
							SET @Business_Rule_List = '" + businessRulelist + @"'
							
							select 
								*
							from CT_Asset_Disposition c
							where 1=1 "
						   + sWhereClauseIsActive
						   + sWhereClauseBusinessRule
						   + orderBy
						   ;

			return ExecuteSQLStatement(Constants.DBNAME_ASSET_TRACKING, sSQL);
		}

        public static DataSet DsGetRepair(bool isDisplayActiveOnly, string businessRulelist, string orderBy)
        {
            string sWhereClauseIsActive = "";
            string sWhereClauseBusinessRule = "";


            if (isDisplayActiveOnly)
            {
                sWhereClauseIsActive = " AND c.Is_Active = 1 ";
            }

            if (!Utilities.isNull(businessRulelist))
            {
                sWhereClauseBusinessRule = @" AND c.Code in (
												select 
													d.Code
												from Business_Rule b
												inner join Business_Rule_Detail d
													on d.Business_Rule_ID = b.ID
												where 1=1
													and b.Code in (
														select * from dbo.CSVToTable(@Business_Rule_List,',')
													)
													and b.Table_Name = 'CT_Repair_Type'
											)";
            }

            if (!Utilities.isNull(orderBy))
            {
                orderBy = " ORDER BY " + orderBy;
            }

            string sSQL = @"DECLARE @Business_Rule_List AS VARCHAR(MAX)
				
							SET @Business_Rule_List = '" + businessRulelist + @"'
							
							select 
								*
							from CT_Repair_Type c
							where 1=1 "
                           + sWhereClauseIsActive
                           + sWhereClauseBusinessRule
                           + orderBy
                           ;

            return ExecuteSQLStatement(Constants.DBNAME_ASSET_TRACKING, sSQL);
        }

		public static DataSet DsGetInteractionType(bool isDisplayActiveOnly, string businessRulelist, string orderBy)
		{
			string sWhereClauseIsActive = "";
			string sWhereClauseBusinessRule = "";


			if (isDisplayActiveOnly)
			{
				sWhereClauseIsActive = " AND c.Is_Active = 1 ";
			}

			if (!Utilities.isNull(businessRulelist))
			{
				sWhereClauseBusinessRule = @" AND c.Code in (
												select 
													d.Code
												from Business_Rule b
												inner join Business_Rule_Detail d
													on d.Business_Rule_ID = b.ID
												where 1=1
													and b.Code in (
														select * from dbo.CSVToTable(@Business_Rule_List,',')
													)
													and b.Table_Name = 'CT_Interaction_Type'
											)";
			}

			if (!Utilities.isNull(orderBy))
			{
				orderBy = " ORDER BY " + orderBy;
			}

			string sSQL = @"DECLARE @Business_Rule_List AS VARCHAR(MAX)
				
							SET @Business_Rule_List = '" + businessRulelist + @"'
							
							select 
								*
							from CT_Interaction_Type c
							where 1=1 "
						   + sWhereClauseIsActive
						   + sWhereClauseBusinessRule
						   + orderBy
						   ;

			return ExecuteSQLStatement(Constants.DBNAME_ASSET_TRACKING, sSQL);
		}

		public static DataSet DsGetCheckOutAssignment(string student_id, string serialNumber, string tag_id)
		{
			Utilities.Assert(!Utilities.isNull(student_id) || !Utilities.isNull(serialNumber) || !Utilities.isNull(tag_id), "Student ID or Serial Number or tagid required.");
			string sSQL = @"DECLARE @Student_ID as VARCHAR(20)
							DECLARE @SerialNumber as VARCHAR(100)                            
							DECLARE @Tag_ID as VARCHAR(100)                       

							SET @Student_ID = '" + student_id + @"' 
							SET @SerialNumber = '" + serialNumber + @"'
							SET @Tag_ID = '" + tag_id + @"' 

							select 
								*
							from v_Student_Current_Assignment a
							where 1=1
								and (a.Student_ID = @Student_ID OR a.Serial_Number = @SerialNumber OR a.Tag_ID = @Tag_ID)
						
							ORDER BY 
								Date_Check_Out desc";

			return ExecuteSQLStatement(sSQL);
		}

		public static DataSet DsGetUserPreference(string emp_id, string preference_type)
		{
			ArrayList arrNames = new ArrayList();
			ArrayList arrValues = new ArrayList();

			//Asset Student Transaction ID
			arrNames.Add("Emp_ID");
			arrValues.Add(emp_id);

			//Disposition ID
			arrNames.Add("App_Preference_Type_Code");
			arrValues.Add(preference_type);

			return ExecuteStoredProc(Constants.STORED_PROC_SP_GET_USER_PREFERENCE_BY_TYPE, arrNames, arrValues);

		}

		public static DataSet DsGetCheckedAssetSiteIDFromAssetSearch(string asset_search_id)
		{
			string sSQL = @"DECLARE @Asset_Search_ID int
							SET @Asset_Search_ID = " + asset_search_id + @"

							select 
								am.Site_ID,
								s.Name as Site_Desc
							from Asset_Search h
							inner join Asset_Search_Detail d
								on d.Asset_Search_ID = h.ID
							inner join Asset a
								on a.ID = d.Asset_ID
							inner join Asset_Site_Mapping am
								on am.Asset_ID = d.Asset_ID
							inner join CT_Site s
								on am.Site_ID = s.ID
							where 1=1
								and h.ID = @Asset_Search_ID
								and d.Is_Checked = 1
							group by
								am.Site_ID,
								s.Name
							";
			return ExecuteSQLStatement(sSQL);
		}

		public static DataSet DsGetCAIRSAppInfo()
		{
			string appname = Utilities.GetApplicationName();
			string sSQL = @"DECLARE @AppName as VARCHAR(100)
							SET @AppName = '" + appname + @"'
							
							select * from Apps a where a.AppName = @AppName";

			return ExecuteSQLStatement(Constants.DBNAME_SECURITY, sSQL);
		}

		public static DataSet DsGetMostRecentAssetStudentTransaction(string asset_id)
		{
			Utilities.Assert(!Utilities.isNull(asset_id), "Asset ID not provided");
			string sSQL = @"DECLARE @Asset_ID as INT
							SET @Asset_ID = " + asset_id + @"
							
							select 
								Datawarehouse.dbo.getStudentNameById(t.Student_ID) + ' (#' + t.Student_ID + ')' as Student_Name,
								t.*
							from Asset_Student_Transaction t 
							where 1=1
								and t.ID in (--Get most recent
									select 
										max(ID)
									from Asset_Student_Transaction astu
									where astu.Asset_ID = @Asset_ID
								)
								and t.School_Year = Datawarehouse.dbo.getCurrentYearYYYY() --Has to be in the same school Year
							";
			return ExecuteSQLStatement(sSQL);
		}

        public static DataSet DsGetPendingAssignmentForCheckOut(string list_tag_ids)
        {
            Utilities.Assert(!Utilities.isNull(list_tag_ids) , "Tag ID Required");

            string sSQL = @"DECLARE @Tag_IDs as VARCHAR(MAX) 
                            SET @Tag_IDs = '" + list_tag_ids + @"'                        

                            SELECT 
                                v.*,  
                                (SELECT mcs.dbo.GetSchoolCCYY(Getdate())) as School_Year
							FROM v_Asset_Master_List v
							WHERE 1=1 
                                AND v.Tag_ID IN (SELECT * FROM dbo.CSVToTable(@Tag_IDs,','))";

            return ExecuteSQLStatement(sSQL);
        }

        public static DataSet DsGetAvailableCheckOutForBaseType(string studentid)
        {
            Utilities.Assert(!Utilities.isNull(studentid) , "Student ID Required");
            string sSQL = @"DECLARE @Student_ID AS VARCHAR(20)
                            SET @Student_ID = '" + studentid + @"'

                            select 
	                            @Student_ID as Student_ID,
	                            bt.ID as Asset_Base_Type_ID,
	                            bt.Name,
	                            bt.Max_Check_Out,
	                            isnull(hdr.Max_Check_Out_Override, 0) as Max_Check_Out_Override,
	                            case 
		                            when isnull(hdr.Max_Check_Out_Override, 0) > bt.Max_Check_Out then
			                            isnull(hdr.Max_Check_Out_Override, 0)
		                            else
			                            bt.Max_Check_Out
	                            end Use_Max_Checkout,
	                            isnull(cur_assign.assign_count, 0) as Currently_Assign,
	                            case 
		                            when isnull(hdr.Max_Check_Out_Override, 0) > bt.Max_Check_Out then
			                            isnull(hdr.Max_Check_Out_Override, 0)
		                            else
			                            bt.Max_Check_Out
	                            end - isnull(cur_assign.assign_count, 0) as Available_Check_Out

                            from CT_Asset_Base_Type bt
                            left join (
	                            select 
		                            hdr.Max_Check_Out_Override,
		                            hdr.Asset_Base_Type_ID,
		                            hdr.Is_Active
	                            from Asset_CheckOut_Exception_Student_Header hdr
	                            inner join Asset_CheckOut_Exception_Student_Detail detail
		                            on detail.Asset_CheckOut_Exception_Student_Header_ID = hdr.ID
	                            where detail.Student_ID = @Student_ID
		                            and hdr.Is_Active = 1
                            ) hdr
	                            on hdr.Asset_Base_Type_ID = bt.ID
                            left join (
	                            select
		                            v.Asset_Base_Type_ID,
		                            count(*) as assign_count
	                            from v_Student_Current_Assignment v
	                            where Student_ID = @Student_ID
	                            group by
		                            v.Asset_Base_Type_ID
                            ) cur_assign
	                            on cur_assign.Asset_Base_Type_ID = bt.ID

                            where bt.Is_Active = 1 ";

            return ExecuteSQLStatement(sSQL);
        }

        public static DataSet DsGetAssetFollowUp(string site_ids, string dispositions, string tag_id, string serial_number, string orderby)
        {
            Utilities.Assert(!Utilities.isNull(site_ids) || !Utilities.isNull(dispositions) || !Utilities.isNull(orderby), "Site, Disposition and Order By all Required.");

            string sWhereTagID = "";
            string sWhereSerialNumber = "";
            //Tag ID Filter
            if (!Utilities.isNull(tag_id))
            {
                sWhereTagID = " and v.Tag_ID = @Tag_ID ";
            }
            //Serial Number Filter
            if (!Utilities.isNull(serial_number))
            {
                sWhereSerialNumber = " and v.Serial_Number =  @Serial_Number ";
            }

            string sSQL = @"DECLARE @SiteList VARCHAR(MAX)
                            DECLARE @DispositionList VARCHAR(MAX)
                            DECLARE @Tag_ID VARCHAR(100)
                            DECLARE @Serial_Number VARCHAR(100)

                            SET @SiteList = '" + site_ids + @"'
                            SET @DispositionList = '" + dispositions + @"'
                            SET @Tag_ID = '" + tag_id + @"'
                            SET @Serial_Number = '" + serial_number + @"'

                            select *
                            from v_Asset_Master_List v
                            where 1=1
	                            and v.Asset_Site_ID in (
		                            select * from dbo.CSVToTable(@SiteList,',')
	                            )
	                            and v.Asset_Disposition_ID in (
		                            select * from dbo.CSVToTable(@DispositionList,',')
	                            ) "
                                + sWhereTagID
                                + sWhereSerialNumber
                            + " ORDER BY " + orderby
                            ;

            return ExecuteSQLStatement(sSQL);
        }

        public static DataSet DsGetAssetSearchByID(string p_Asset_Search_ID, string p_Sort_Order, bool IsCheck)
        {
            Utilities.Assert(!Utilities.isNull(p_Asset_Search_ID), "Asset Search ID Required.");

            string filter_check = "";

            if (!Utilities.isNull(p_Sort_Order))
            {
                p_Sort_Order = " ORDER BY " + p_Sort_Order;
            }

            if (IsCheck)
            {
                filter_check = " and d.Is_Checked = 1 ";
            }

            string sSQL = @"DECLARE @Asset_Search_ID int
                            SET @Asset_Search_ID = " + p_Asset_Search_ID + @"

                            select 
								v.*,
								isnull(d.Is_Checked, 0) as Is_Checked

							from v_Asset_Master_List v 
							left join Asset_Search_Detail d
								on d.Asset_ID = v.Asset_ID

							Where 1=1
                                and d.Asset_Search_ID = @Asset_Search_ID " 
                                + filter_check
                                                 
                            + p_Sort_Order;

            return ExecuteSQLStatement(sSQL);
        }

        public static DataSet DsGetCheckItemCountFromAssetSearch(string asset_search_id)
        {
            Utilities.Assert(!Utilities.isNull(asset_search_id), "Asset Search ID Required.");

            string sSQL = @" DECLARE @Asset_Search_ID AS INT 
        
                             SET @Asset_Search_ID = " + asset_search_id + @"                    
                            
                             select count(*) as Total_Checked from Asset_Search_Detail d where d.Asset_Search_ID = @Asset_Search_ID and d.Is_Checked = 1
                        ";

            return ExecuteSQLStatement(sSQL);
        }

        public static DataSet DsGetCheckItemFromAssetSearch(string asset_search_id, string Transfer_Site_ID, string sort_by)
        {
            Utilities.Assert(!Utilities.isNull(asset_search_id), "Asset Search ID Required.");
            
            string order_by = "";
            string join_error_tbl = "";
            string column_error_msg = ", null as Message_Error";


            if (Utilities.isNull(Transfer_Site_ID) || Transfer_Site_ID.Contains("-"))
            {
                Transfer_Site_ID = "-1";
            }
            else
            {
                join_error_tbl = @" left join dbo.ValidateAssetSearchTransfer(@Asset_Search_ID, @Transfer_Site_ID, null) vmsg
                                on  vmsg.Asset_ID = v.Asset_ID  ";

                column_error_msg = ", vmsg.Message_Error";
            }
            

            if (!Utilities.isNull(sort_by))
            {
                order_by = " ORDER BY " + sort_by;
            }

            string sSQL = @" DECLARE @Asset_Search_ID AS INT
                             DECLARE @Transfer_Site_ID AS INT

                             SET @Asset_Search_ID = " + asset_search_id + @"
                             SET @Transfer_Site_ID = " + Transfer_Site_ID + @"
                             ;        
                             
                             select 
                                v.*
                                " + column_error_msg + @"

                             from Asset_Search_Detail d
	                         inner join v_Asset_Master_List v
	                            on v.Asset_ID = d.Asset_ID "
                            + join_error_tbl +
                            
	                        @" where 1=1
		                        and d.Asset_Search_ID = @Asset_Search_ID
		                        and d.Is_Checked = 1 " + 

                            order_by;

            return ExecuteSQLStatement(sSQL);
        }

        public static DataSet DsGetEnteredByEmpForAddAsset(string site_ids, string batch_status)
        {
            Utilities.Assert(!Utilities.isNull(site_ids));
            string setBatchStatus = "";
            string sWhereClauseBatchStatus = "";

            switch (batch_status)
            {
                case "1": //Pending
                    setBatchStatus = "SET @BatchStatus = '0'";
                    break;
                case "2": //Submitted
                    setBatchStatus = "SET @BatchStatus = '1'";
                    break;
                case "3": //All
                default:
                    //Do Nothing
                    break;
            }

            if (!Utilities.isNull(setBatchStatus))
            {
                sWhereClauseBatchStatus = " AND h.Has_Submit = @BatchStatus ";
            }

            string sSQL = @"DECLARE @SiteList AS VARCHAR(MAX)
                            DECLARE @BatchStatus as Varchar(10)

                            SET @SiteList = '" + site_ids + @"' "
                            +
							setBatchStatus     
							+ @"

                            select 
	                            distinct h.Added_By_Emp_ID,
	                            dbo.PROPERCASE(Datawarehouse.dbo.getEmployeeNameById(h.Added_By_Emp_ID)) as Added_By_Emp_Name
                            from Asset_Temp_Header h 
                            where h.Asset_Site_ID in (
		                            select * from dbo.CSVToTable(@SiteList,',')
	                            ) "
                                + sWhereClauseBatchStatus + @"

                            ORDER BY Added_By_Emp_Name "
                            ;
            return ExecuteSQLStatement(sSQL);
        }

		#endregion
		
		//Update and Insert Method
		#region Upsert Method

		/// <summary>
		/// Update and Insert Method
		/// </summary>
		/// <param name="p_ID">-1 will insert a new record, passing in the ID will update the record</param>
		/// <param name="p_Tag_ID">Tag_ID</param>
		/// <param name="p_Asset_Disposition_ID">Asset_Disposition_ID</param>
		/// <param name="p_Asset_Condition_ID">Asset_Condition_ID</param>
		/// <param name="p_Asset_Type_ID">Asset_Type_ID</param>
		/// <param name="p_Asset_Assignment_Type_ID">Asset_Assignment_Type_ID</param>
		/// <param name="p_Serial_Number">Serial_Number</param>
		/// <param name="p_Date_Purchased">Date_Purchased</param>
		/// <param name="p_Is_Leased">Is_Leased</param>
		/// <param name="p_Is_Active">Is_Active</param>
		/// <param name="p_Added_By_Emp_ID">Added_By_Emp_ID</param>
		/// <param name="p_Date_Added">Date_Added</param>
		/// <returns>String value of the ID that was updated or inserted</returns>
		public static string Upsert_Asset(
			string p_ID, 
			string p_Tag_ID, 
			string p_Asset_Disposition_ID, 
			string p_Asset_Condition_ID, 
			string p_Asset_Type_ID, 
			string p_Asset_Assignment_Type_ID, 
			string p_Serial_Number, 
			string p_Date_Purchased,
            string p_Leased_Term_Days,
            string p_Warranty_Term_Days,
			string p_Is_Leased, 
			string p_Is_Active, 
			string p_Added_By_Emp_ID, 
			string p_Date_Added,
			string p_Modified_By_Emp_ID,
			string p_Date_Modified
		)
		{
			ArrayList arrParamName = new ArrayList();
			ArrayList arrParmnValue = new ArrayList();

			//ID
			arrParamName.Add("ID");
			arrParmnValue.Add(p_ID);

			//Tag_ID
			arrParamName.Add("Tag_ID");
			arrParmnValue.Add(p_Tag_ID);

			//Asset_Disposition_ID
			arrParamName.Add("Asset_Disposition_ID");
			arrParmnValue.Add(p_Asset_Disposition_ID);

			//Asset_Condition_ID
			arrParamName.Add("Asset_Condition_ID");
			arrParmnValue.Add(p_Asset_Condition_ID);

			//Asset_Type_ID
			arrParamName.Add("Asset_Type_ID");
			arrParmnValue.Add(p_Asset_Type_ID);

			//Asset_Assignment_Type_ID
			arrParamName.Add("Asset_Assignment_Type_ID");
			arrParmnValue.Add(p_Asset_Assignment_Type_ID);

			//Serial_Number
			arrParamName.Add("Serial_Number");
			arrParmnValue.Add(p_Serial_Number);

			//Date_Purchased
			arrParamName.Add("Date_Purchased");
			arrParmnValue.Add(p_Date_Purchased);

            //Leased_Term_Days
            arrParamName.Add("Leased_Term_Days");
            arrParmnValue.Add(p_Leased_Term_Days);

            //Warranty_Term_Days
            arrParamName.Add("Warranty_Term_Days");
            arrParmnValue.Add(p_Warranty_Term_Days);

			//Is_Leased
			arrParamName.Add("Is_Leased");
			arrParmnValue.Add(p_Is_Leased);

			//Is_Active
			arrParamName.Add("Is_Active");
			arrParmnValue.Add(p_Is_Active);

			//Added_By_Emp_ID
			arrParamName.Add("Added_By_Emp_ID");
			arrParmnValue.Add(p_Added_By_Emp_ID);

			//Date_Added
			arrParamName.Add("Date_Added");
			arrParmnValue.Add(p_Date_Added);

			//Modified_By_Emp_ID
			arrParamName.Add("Modified_By_Emp_ID");
			arrParmnValue.Add(p_Modified_By_Emp_ID);

			//Date_Modified
			arrParamName.Add("Date_Modified");
			arrParmnValue.Add(p_Date_Modified);

			return ExecuteStoredProcUpsert(Constants.DBNAME_ASSET_TRACKING, Constants.STORED_PROC_SP_UPSERT_ASSET, arrParamName, arrParmnValue);
		}

		/// <summary>
		/// Update and Insert Method
		/// </summary>
		/// <param name="p_ID">-1 will insert a new record, passing in the ID will update the record</param>
		/// <param name="p_Asset_ID">Asset_ID</param>
		/// <param name="p_Site_ID">Site_ID</param>
		/// <param name="p_Added_By_Emp_ID">Added_By_Emp_ID</param>
		/// <param name="p_Date_Added">Date_Added</param>
		/// <returns>String value of the ID that was updated or inserted</returns>
		public static string Upsert_Asset_Site_Mapping(string p_ID, string p_Asset_ID, string p_Site_ID, string p_Added_By_Emp_ID, string p_Date_Added)
		{
			ArrayList arrParamName = new ArrayList();
			ArrayList arrParmnValue = new ArrayList();

			//ID
			arrParamName.Add("ID");
			arrParmnValue.Add(p_ID);

			//Asset_ID
			arrParamName.Add("Asset_ID");
			arrParmnValue.Add(p_Asset_ID);

			//Site_ID
			arrParamName.Add("Site_ID");
			arrParmnValue.Add(p_Site_ID);

			//Added_By_Emp_ID
			arrParamName.Add("Added_By_Emp_ID");
			arrParmnValue.Add(p_Added_By_Emp_ID);

			//Date_Added
			arrParamName.Add("Date_Added");
			arrParmnValue.Add(p_Date_Added);

			return ExecuteStoredProcUpsert(Constants.DBNAME_ASSET_TRACKING, Constants.STORED_PROC_SP_UPSERT_ASSET_SITE_MAPPING, arrParamName, arrParmnValue);
		}

		/// <summary>
		/// Update and Insert Method
		/// </summary>
		/// <param name="p_ID">-1 will insert a new record, passing in the ID will update the record</param>
		/// <param name="p_Asset_Site_Mapping_ID">Asset_Site_Mapping_ID</param>
		/// <param name="p_Column_Name">Column_Name</param>
		/// <param name="p_Old_Value">Old_Value</param>
		/// <param name="p_New_Value">New_Value</param>
		/// <param name="p_Emp_ID">Emp_ID</param>
		/// <param name="p_Date_Modified">Date_Modified</param>
		/// <returns>String value of the ID that was updated or inserted</returns>
		public static string Upsert_Asset_Site_Mapping_Audit_Log(string p_ID, string p_Asset_Site_Mapping_ID, string p_Column_Name, string p_Old_Value, string p_New_Value, string p_Emp_ID, string p_Date_Modified)
		{
			ArrayList arrParamName = new ArrayList();
			ArrayList arrParmnValue = new ArrayList();

			//ID
			arrParamName.Add("ID");
			arrParmnValue.Add(p_ID);

			//Asset_Site_Mapping_ID
			arrParamName.Add("Asset_Site_Mapping_ID");
			arrParmnValue.Add(p_Asset_Site_Mapping_ID);

			//Column_Name
			arrParamName.Add("Column_Name");
			arrParmnValue.Add(p_Column_Name);

			//Old_Value
			arrParamName.Add("Old_Value");
			arrParmnValue.Add(p_Old_Value);

			//New_Value
			arrParamName.Add("New_Value");
			arrParmnValue.Add(p_New_Value);

			//Emp_ID
			arrParamName.Add("Emp_ID");
			arrParmnValue.Add(p_Emp_ID);

			//Date_Modified
			arrParamName.Add("Date_Modified");
			arrParmnValue.Add(p_Date_Modified);

			return ExecuteStoredProcUpsert(Constants.DBNAME_ASSET_TRACKING, Constants.STORED_PROC_SP_UPSERT_ASSET_SITE_MAPPING_AUDIT_LOG, arrParamName, arrParmnValue);
		}

		/// <summary>
		/// Update and Insert Method
		/// </summary>
		/// <param name="p_ID">-1 will insert a new record, passing in the ID will update the record</param>
		/// <param name="p_Asset_ID">Asset_ID</param>
		/// <param name="p_Column_Name">Column_Name</param>
		/// <param name="p_Old_Value">Old_Value</param>
		/// <param name="p_New_Value">New_Value</param>
		/// <param name="p_Emp_ID">Emp_ID</param>
		/// <param name="p_Date_Modified">Date_Modified</param>
		/// <returns>String value of the ID that was updated or inserted</returns>
		public static string Upsert_Asset_Audit_Log(string p_ID, string p_Asset_ID, string p_Column_Name, string p_Old_Value, string p_New_Value, string p_Emp_ID, string p_Date_Modified)
		{
			ArrayList arrParamName = new ArrayList();
			ArrayList arrParmnValue = new ArrayList();

			//ID
			arrParamName.Add("ID");
			arrParmnValue.Add(p_ID);

			//Asset_ID
			arrParamName.Add("Asset_ID");
			arrParmnValue.Add(p_Asset_ID);

			//Column_Name
			arrParamName.Add("Column_Name");
			arrParmnValue.Add(p_Column_Name);

			//Old_Value
			arrParamName.Add("Old_Value");
			arrParmnValue.Add(p_Old_Value);

			//New_Value
			arrParamName.Add("New_Value");
			arrParmnValue.Add(p_New_Value);

			//Emp_ID
			arrParamName.Add("Emp_ID");
			arrParmnValue.Add(p_Emp_ID);

			//Date_Modified
			arrParamName.Add("Date_Modified");
			arrParmnValue.Add(p_Date_Modified);

			return ExecuteStoredProcUpsert(Constants.DBNAME_ASSET_TRACKING, Constants.STORED_PROC_SP_UPSERT_ASSET_AUDIT_LOG, arrParamName, arrParmnValue);
		}

		/// <summary>
		/// Update and Insert Method
		/// </summary>
		/// <param name="p_ID">-1 will insert a new record, passing in the ID will update the record</param>
		/// <param name="p_Code">Code</param>
		/// <param name="p_Name">Name</param>
		/// <param name="p_Description">Description</param>
		/// <param name="p_Fixed_Asset_Loc_Number">Fixed_Asset_Loc_Number</param>
		/// <param name="p_Fixed_Asset_Loc_Description">Fixed_Asset_Loc_Description</param>
		/// <param name="p_Is_Active">Is_Active</param>
		/// <returns>String value of the ID that was updated or inserted</returns>
		public static string Upsert_CT_Site(string p_ID, string p_Code, string p_Name, string p_Description, string p_Fixed_Asset_Loc_Number, string p_Fixed_Asset_Loc_Description, string p_Is_Active)
		{
			ArrayList arrParamName = new ArrayList();
			ArrayList arrParmnValue = new ArrayList();

			//ID
			arrParamName.Add("ID");
			arrParmnValue.Add(p_ID);

			//Code
			arrParamName.Add("Code");
			arrParmnValue.Add(p_Code);

			//Name
			arrParamName.Add("Name");
			arrParmnValue.Add(p_Name);

			//Description
			arrParamName.Add("Description");
			arrParmnValue.Add(p_Description);

			//Fixed_Asset_Loc_Number
			arrParamName.Add("Fixed_Asset_Loc_Number");
			arrParmnValue.Add(p_Fixed_Asset_Loc_Number);

			//Fixed_Asset_Loc_Description
			arrParamName.Add("Fixed_Asset_Loc_Description");
			arrParmnValue.Add(p_Fixed_Asset_Loc_Description);

			//Is_Active
			arrParamName.Add("Is_Active");
			arrParmnValue.Add(p_Is_Active);

			return ExecuteStoredProcUpsert(Constants.DBNAME_ASSET_TRACKING, Constants.STORED_PROC_SP_UPSERT_CT_SITE, arrParamName, arrParmnValue);
		}

		/// <summary>
		/// Update and Insert Method
		/// </summary>
		/// <param name="p_ID">-1 will insert a new record, passing in the ID will update the record</param>
		/// <param name="p_Code">Code</param>
		/// <param name="p_Name">Name</param>
		/// <param name="p_Description">Description</param>
		/// <param name="p_Vendor_ID">Vendor_ID</param>
		/// <param name="p_Is_Vendor_Req">Is_Vendor_Req</param>
		/// <param name="p_Is_Serial_Req">Is_Serial_Req</param>
		/// <param name="p_Max_Checkout">Max_Checkout</param>
		/// <param name="p_Is_Active">Is_Active</param>
		/// <returns>String value of the ID that was updated or inserted</returns>
		public static string Upsert_CT_Asset_Type(string p_ID, string p_Code, string p_Name, string p_Description, string p_Vendor_ID, string p_Is_Vendor_Req, string p_Is_Serial_Req, string p_Max_Checkout, string p_Is_Active)
		{
			ArrayList arrParamName = new ArrayList();
			ArrayList arrParmnValue = new ArrayList();

			//ID
			arrParamName.Add("ID");
			arrParmnValue.Add(p_ID);

			//Code
			arrParamName.Add("Code");
			arrParmnValue.Add(p_Code);

			//Name
			arrParamName.Add("Name");
			arrParmnValue.Add(p_Name);

			//Description
			arrParamName.Add("Description");
			arrParmnValue.Add(p_Description);

			//Vendor_ID
			arrParamName.Add("Vendor_ID");
			arrParmnValue.Add(p_Vendor_ID);

			//Is_Vendor_Req
			arrParamName.Add("Is_Vendor_Req");
			arrParmnValue.Add(p_Is_Vendor_Req);

			//Is_Serial_Req
			arrParamName.Add("Is_Serial_Req");
			arrParmnValue.Add(p_Is_Serial_Req);

			//Max_Checkout
			arrParamName.Add("Max_Checkout");
			arrParmnValue.Add(p_Max_Checkout);

			//Is_Active
			arrParamName.Add("Is_Active");
			arrParmnValue.Add(p_Is_Active);

			return ExecuteStoredProcUpsert(Constants.DBNAME_ASSET_TRACKING, Constants.STORED_PROC_SP_UPSERT_CT_ASSET_TYPE, arrParamName, arrParmnValue);
		}

		/// <summary>
		/// Update and Insert Method
		/// </summary>
		/// <param name="p_ID">-1 will insert a new record, passing in the ID will update the record</param>
		/// <param name="p_Code">Code</param>
		/// <param name="p_Asset_Type_ID">Asset_Type_ID</param>
		/// <param name="p_Name">Name</param>
		/// <param name="p_Description">Description</param>
		/// <param name="p_Is_Active">Is_Active</param>
		/// <returns>String value of the ID that was updated or inserted</returns>
		public static string Upsert_CT_Fee_Type(string p_ID, string p_Code, string p_Asset_Type_ID, string p_Name, string p_Description, string p_Is_Active)
		{
			ArrayList arrParamName = new ArrayList();
			ArrayList arrParmnValue = new ArrayList();

			//ID
			arrParamName.Add("ID");
			arrParmnValue.Add(p_ID);

			//Code
			arrParamName.Add("Code");
			arrParmnValue.Add(p_Code);

			//Asset_Type_ID
			arrParamName.Add("Asset_Type_ID");
			arrParmnValue.Add(p_Asset_Type_ID);

			//Name
			arrParamName.Add("Name");
			arrParmnValue.Add(p_Name);

			//Description
			arrParamName.Add("Description");
			arrParmnValue.Add(p_Description);

			//Is_Active
			arrParamName.Add("Is_Active");
			arrParmnValue.Add(p_Is_Active);

			return ExecuteStoredProcUpsert(Constants.DBNAME_ASSET_TRACKING, Constants.STORED_PROC_SP_UPSERT_CT_FEE_TYPE, arrParamName, arrParmnValue);
		}

		/// <summary>
		/// Update and Insert Method
		/// </summary>
		/// <param name="p_ID">-1 will insert a new record, passing in the ID will update the record</param>
		/// <param name="p_Code">Code</param>
		/// <param name="p_Name">Name</param>
		/// <param name="p_Description">Description</param>
		/// <param name="p_Is_Active">Is_Active</param>
		/// <returns>String value of the ID that was updated or inserted</returns>
		public static string Upsert_CT_Vendor(string p_ID, string p_Code, string p_Name, string p_Description, string p_Is_Active)
		{
			ArrayList arrParamName = new ArrayList();
			ArrayList arrParmnValue = new ArrayList();

			//ID
			arrParamName.Add("ID");
			arrParmnValue.Add(p_ID);

			//Code
			arrParamName.Add("Code");
			arrParmnValue.Add(p_Code);

			//Name
			arrParamName.Add("Name");
			arrParmnValue.Add(p_Name);

			//Description
			arrParamName.Add("Description");
			arrParmnValue.Add(p_Description);

			//Is_Active
			arrParamName.Add("Is_Active");
			arrParmnValue.Add(p_Is_Active);

			return ExecuteStoredProcUpsert(Constants.DBNAME_ASSET_TRACKING, Constants.STORED_PROC_SP_UPSERT_CT_VENDOR, arrParamName, arrParmnValue);
		}

		/// <summary>
		/// Update and Insert Method
		/// </summary>
		/// <param name="p_ID">-1 will insert a new record, passing in the ID will update the record</param>
		/// <param name="p_Code">Code</param>
		/// <param name="p_Asset_Type_ID">Asset_Type_ID</param>
		/// <param name="p_Name">Name</param>
		/// <param name="p_Description">Description</param>
		/// <param name="p_Is_Active">Is_Active</param>
		/// <returns>String value of the ID that was updated or inserted</returns>
		public static string Upsert_CT_Repair_Type(string p_ID, string p_Code, string p_Asset_Type_ID, string p_Name, string p_Description, string p_Is_Active)
		{
			ArrayList arrParamName = new ArrayList();
			ArrayList arrParmnValue = new ArrayList();

			//ID
			arrParamName.Add("ID");
			arrParmnValue.Add(p_ID);

			//Code
			arrParamName.Add("Code");
			arrParmnValue.Add(p_Code);

			//Asset_Type_ID
			arrParamName.Add("Asset_Type_ID");
			arrParmnValue.Add(p_Asset_Type_ID);

			//Name
			arrParamName.Add("Name");
			arrParmnValue.Add(p_Name);

			//Description
			arrParamName.Add("Description");
			arrParmnValue.Add(p_Description);

			//Is_Active
			arrParamName.Add("Is_Active");
			arrParmnValue.Add(p_Is_Active);

			return ExecuteStoredProcUpsert(Constants.DBNAME_ASSET_TRACKING, Constants.STORED_PROC_SP_UPSERT_CT_REPAIR_TYPE, arrParamName, arrParmnValue);
		}

		/// <summary>
		/// Update and Insert Method
		/// </summary>
		/// <param name="p_ID">-1 will insert a new record, passing in the ID will update the record</param>
		/// <param name="p_Code">Code</param>
		/// <param name="p_Name">Name</param>
		/// <param name="p_Description">Description</param>
		/// <param name="p_Is_Active">Is_Active</param>
		/// <returns>String value of the ID that was updated or inserted</returns>
		public static string Upsert_CT_Device_Fee_Type(string p_ID, string p_Code, string p_Name, string p_Description, string p_Is_Active)
		{
			ArrayList arrParamName = new ArrayList();
			ArrayList arrParmnValue = new ArrayList();

			//ID
			arrParamName.Add("ID");
			arrParmnValue.Add(p_ID);

			//Code
			arrParamName.Add("Code");
			arrParmnValue.Add(p_Code);

			//Name
			arrParamName.Add("Name");
			arrParmnValue.Add(p_Name);

			//Description
			arrParamName.Add("Description");
			arrParmnValue.Add(p_Description);

			//Is_Active
			arrParamName.Add("Is_Active");
			arrParmnValue.Add(p_Is_Active);

			return ExecuteStoredProcUpsert(Constants.DBNAME_ASSET_TRACKING, Constants.STORED_PROC_SP_UPSERT_CT_DEVICE_FEE_TYPE, arrParamName, arrParmnValue);
		}

		/// <summary>
		/// Update and Insert Method
		/// </summary>
		/// <param name="p_ID">-1 will insert a new record, passing in the ID will update the record</param>
		/// <param name="p_Code">Code</param>
		/// <param name="p_Fee_Type_ID">Fee_Type_ID</param>
		/// <param name="p_Fee_Amount">Fee_Amount</param>
		/// <param name="p_Date_Start">Date_Start</param>
		/// <param name="p_Date_End">Date_End</param>
		/// <returns>String value of the ID that was updated or inserted</returns>
		public static string Upsert_CT_Asset_Type_Fee_Schedule(string p_ID, string p_Code, string p_Fee_Type_ID, string p_Fee_Amount, string p_Date_Start, string p_Date_End)
		{
			ArrayList arrParamName = new ArrayList();
			ArrayList arrParmnValue = new ArrayList();

			//ID
			arrParamName.Add("ID");
			arrParmnValue.Add(p_ID);

			//Code
			arrParamName.Add("Code");
			arrParmnValue.Add(p_Code);

			//Fee_Type_ID
			arrParamName.Add("Fee_Type_ID");
			arrParmnValue.Add(p_Fee_Type_ID);

			//Fee_Amount
			arrParamName.Add("Fee_Amount");
			arrParmnValue.Add(p_Fee_Amount);

			//Date_Start
			arrParamName.Add("Date_Start");
			arrParmnValue.Add(p_Date_Start);

			//Date_End
			arrParamName.Add("Date_End");
			arrParmnValue.Add(p_Date_End);

			return ExecuteStoredProcUpsert(Constants.DBNAME_ASSET_TRACKING, Constants.STORED_PROC_SP_UPSERT_CT_ASSET_TYPE_FEE_SCHEDULE, arrParamName, arrParmnValue);
		}

		/// <summary>
		/// Update and Insert Method
		/// </summary>
		/// <param name="p_ID">-1 will insert a new record, passing in the ID will update the record</param>
		/// <param name="p_Code">Code</param>
		/// <param name="p_Name">Name</param>
		/// <param name="p_Description">Description</param>
		/// <param name="p_Is_Active">Is_Active</param>
		/// <returns>String value of the ID that was updated or inserted</returns>
		public static string Upsert_CT_Asset_Condition(string p_ID, string p_Code, string p_Name, string p_Description, string p_Is_Active)
		{
			ArrayList arrParamName = new ArrayList();
			ArrayList arrParmnValue = new ArrayList();

			//ID
			arrParamName.Add("ID");
			arrParmnValue.Add(p_ID);

			//Code
			arrParamName.Add("Code");
			arrParmnValue.Add(p_Code);

			//Name
			arrParamName.Add("Name");
			arrParmnValue.Add(p_Name);

			//Description
			arrParamName.Add("Description");
			arrParmnValue.Add(p_Description);

			//Is_Active
			arrParamName.Add("Is_Active");
			arrParmnValue.Add(p_Is_Active);

			return ExecuteStoredProcUpsert(Constants.DBNAME_ASSET_TRACKING, Constants.STORED_PROC_SP_UPSERT_CT_ASSET_CONDITION, arrParamName, arrParmnValue);
		}

		/// <summary>
		/// Update and Insert Method
		/// </summary>
		/// <param name="p_ID">-1 will insert a new record, passing in the ID will update the record</param>
		/// <param name="p_Code">Code</param>
		/// <param name="p_Name">Name</param>
		/// <param name="p_Description">Description</param>
		/// <param name="p_Is_Active">Is_Active</param>
		/// <returns>String value of the ID that was updated or inserted</returns>
		public static string Upsert_CT_Asset_Disposition(string p_ID, string p_Code, string p_Name, string p_Description, string p_Is_Active)
		{
			ArrayList arrParamName = new ArrayList();
			ArrayList arrParmnValue = new ArrayList();

			//ID
			arrParamName.Add("ID");
			arrParmnValue.Add(p_ID);

			//Code
			arrParamName.Add("Code");
			arrParmnValue.Add(p_Code);

			//Name
			arrParamName.Add("Name");
			arrParmnValue.Add(p_Name);

			//Description
			arrParamName.Add("Description");
			arrParmnValue.Add(p_Description);

			//Is_Active
			arrParamName.Add("Is_Active");
			arrParmnValue.Add(p_Is_Active);

			return ExecuteStoredProcUpsert(Constants.DBNAME_ASSET_TRACKING, Constants.STORED_PROC_SP_UPSERT_CT_ASSET_DISPOSITION, arrParamName, arrParmnValue);
		}

		/// <summary>
		/// Update and Insert Method
		/// </summary>
		/// <param name="p_ID">-1 will insert a new record, passing in the ID will update the record</param>
		/// <param name="p_Code">Code</param>
		/// <param name="p_Name">Name</param>
		/// <param name="p_Description">Description</param>
		/// <param name="p_Is_Active">Is_Active</param>
		/// <returns>String value of the ID that was updated or inserted</returns>
		public static string Upsert_CT_Asset_Assignment_Type(string p_ID, string p_Code, string p_Name, string p_Description, string p_Is_Active)
		{
			ArrayList arrParamName = new ArrayList();
			ArrayList arrParmnValue = new ArrayList();

			//ID
			arrParamName.Add("ID");
			arrParmnValue.Add(p_ID);

			//Code
			arrParamName.Add("Code");
			arrParmnValue.Add(p_Code);

			//Name
			arrParamName.Add("Name");
			arrParmnValue.Add(p_Name);

			//Description
			arrParamName.Add("Description");
			arrParmnValue.Add(p_Description);

			//Is_Active
			arrParamName.Add("Is_Active");
			arrParmnValue.Add(p_Is_Active);

			return ExecuteStoredProcUpsert(Constants.DBNAME_ASSET_TRACKING, Constants.STORED_PROC_SP_UPSERT_CT_ASSET_ASSIGNMENT_TYPE, arrParamName, arrParmnValue);
		}

		/// <summary>
		/// Update and Insert Method
		/// </summary>
		/// <param name="p_ID">-1 will insert a new record, passing in the ID will update the record</param>
		/// <param name="p_Code">Code</param>
		/// <param name="p_Name">Name</param>
		/// <param name="p_Description">Description</param>
		/// <param name="p_Is_Active">Is_Active</param>
		/// <returns>String value of the ID that was updated or inserted</returns>
		public static string Upsert_CT_Interaction_Type(string p_ID, string p_Code, string p_Name, string p_Description, string p_Is_Active)
		{
			ArrayList arrParamName = new ArrayList();
			ArrayList arrParmnValue = new ArrayList();

			//ID
			arrParamName.Add("ID");
			arrParmnValue.Add(p_ID);

			//Code
			arrParamName.Add("Code");
			arrParmnValue.Add(p_Code);

			//Name
			arrParamName.Add("Name");
			arrParmnValue.Add(p_Name);

			//Description
			arrParamName.Add("Description");
			arrParmnValue.Add(p_Description);

			//Is_Active
			arrParamName.Add("Is_Active");
			arrParmnValue.Add(p_Is_Active);

			return ExecuteStoredProcUpsert(Constants.DBNAME_ASSET_TRACKING, Constants.STORED_PROC_SP_UPSERT_CT_INTERACTION_TYPE, arrParamName, arrParmnValue);
		}

		/// <summary>
		/// Update and Insert Method
		/// </summary>
		/// <param name="p_ID">-1 will insert a new record, passing in the ID will update the record</param>
		/// <param name="p_Code">Code</param>
		/// <param name="p_Name">Name</param>
		/// <param name="p_Description">Description</param>
		/// <param name="p_Is_Active">Is_Active</param>
		/// <returns>String value of the ID that was updated or inserted</returns>
		public static string Upsert_CT_Notification_Type(string p_ID, string p_Code, string p_Name, string p_Description, string p_Is_Active)
		{
			ArrayList arrParamName = new ArrayList();
			ArrayList arrParmnValue = new ArrayList();

			//ID
			arrParamName.Add("ID");
			arrParmnValue.Add(p_ID);

			//Code
			arrParamName.Add("Code");
			arrParmnValue.Add(p_Code);

			//Name
			arrParamName.Add("Name");
			arrParmnValue.Add(p_Name);

			//Description
			arrParamName.Add("Description");
			arrParmnValue.Add(p_Description);

			//Is_Active
			arrParamName.Add("Is_Active");
			arrParmnValue.Add(p_Is_Active);

			return ExecuteStoredProcUpsert(Constants.DBNAME_ASSET_TRACKING, Constants.STORED_PROC_SP_UPSERT_CT_NOTIFICATION_TYPE, arrParamName, arrParmnValue);
		}

		/// <summary>
		/// Update and Insert Method
		/// </summary>
		/// <param name="p_ID">-1 will insert a new record, passing in the ID will update the record</param>
		/// <param name="p_Code">Code</param>
		/// <param name="p_Name">Name</param>
		/// <param name="p_Description">Description</param>
		/// <param name="p_Is_Active">Is_Active</param>
		/// <returns>String value of the ID that was updated or inserted</returns>
		public static string Upsert_CT_File_Type(string p_ID, string p_Code, string p_Name, string p_Description, string p_Is_Active)
		{
			ArrayList arrParamName = new ArrayList();
			ArrayList arrParmnValue = new ArrayList();

			//ID
			arrParamName.Add("ID");
			arrParmnValue.Add(p_ID);

			//Code
			arrParamName.Add("Code");
			arrParmnValue.Add(p_Code);

			//Name
			arrParamName.Add("Name");
			arrParmnValue.Add(p_Name);

			//Description
			arrParamName.Add("Description");
			arrParmnValue.Add(p_Description);

			//Is_Active
			arrParamName.Add("Is_Active");
			arrParmnValue.Add(p_Is_Active);

			return ExecuteStoredProcUpsert(Constants.DBNAME_ASSET_TRACKING, Constants.STORED_PROC_SP_UPSERT_CT_FILE_TYPE, arrParamName, arrParmnValue);
		}

		/// <summary>
		/// Update and Insert Method
		/// </summary>
		/// <param name="p_ID">-1 will insert a new record, passing in the ID will update the record</param>
		/// <param name="p_Site_ID">Site_ID</param>
		/// <param name="p_Name">Name</param>
		/// <param name="p_Description">Description</param>
		/// <param name="p_Capacity">Capacity</param>
		/// <param name="p_Is_Active">Is_Active</param>
		/// <param name="p_Added_By_Emp_ID">Added_By_Emp_ID</param>
		/// <param name="p_Date_Added">Date_Added</param>
		/// <param name="p_Modified_By_Emp_ID">Modified_By_Emp_ID</param>
		/// <param name="p_Date_Modified">Date_Modified</param>
		/// <returns>String value of the ID that was updated or inserted</returns>
		public static string Upsert_Bin(string p_ID, string p_Site_ID, string p_Description, string p_Capacity, string p_Is_Active, string p_Added_By_Emp_ID, string p_Date_Added, string p_Modified_By_Emp_ID, string p_Date_Modified)
		{
			ArrayList arrParamName = new ArrayList();
			ArrayList arrParmnValue = new ArrayList();

			//ID
			arrParamName.Add("ID");
			arrParmnValue.Add(p_ID);

			//Site_ID
			arrParamName.Add("Site_ID");
			arrParmnValue.Add(p_Site_ID);

			//Description
			arrParamName.Add("Description");
			arrParmnValue.Add(p_Description);

			//Capacity
			arrParamName.Add("Capacity");
			arrParmnValue.Add(p_Capacity);

			//Is_Active
			arrParamName.Add("Is_Active");
			arrParmnValue.Add(p_Is_Active);

			//Added_By_Emp_ID
			arrParamName.Add("Added_By_Emp_ID");
			arrParmnValue.Add(p_Added_By_Emp_ID);

			//Date_Added
			arrParamName.Add("Date_Added");
			arrParmnValue.Add(p_Date_Added);

			//Modified_By_Emp_ID
			arrParamName.Add("Modified_By_Emp_ID");
			arrParmnValue.Add(p_Modified_By_Emp_ID);

			//Date_Modified
			arrParamName.Add("Date_Modified");
			arrParmnValue.Add(p_Date_Modified);

			return ExecuteStoredProcUpsert(Constants.DBNAME_ASSET_TRACKING, Constants.STORED_PROC_SP_UPSERT_BIN, arrParamName, arrParmnValue);
		}

		/// <summary>
		/// Update and Insert Method
		/// </summary>
		/// <param name="p_ID">-1 will insert a new record, passing in the ID will update the record</param>
		/// <param name="p_Bin_ID">Bin_ID</param>
		/// <param name="p_Asset_ID">Asset_ID</param>
		/// <param name="p_Date_Added">Date_Added</param>
		/// <param name="p_Added_By_Emp_ID">Added_By_Emp_ID</param>
		/// <returns>String value of the ID that was updated or inserted</returns>
		public static string Upsert_Asset_Bin_Mapping(string p_ID, string p_Bin_ID, string p_Asset_ID, string p_Date_Added, string p_Added_By_Emp_ID)
		{
			ArrayList arrParamName = new ArrayList();
			ArrayList arrParmnValue = new ArrayList();

			//ID
			arrParamName.Add("ID");
			arrParmnValue.Add(p_ID);

			//Bin_ID
			arrParamName.Add("Bin_ID");
			arrParmnValue.Add(p_Bin_ID);

			//Asset_ID
			arrParamName.Add("Asset_ID");
			arrParmnValue.Add(p_Asset_ID);

			//Date_Added
			arrParamName.Add("Date_Added");
			arrParmnValue.Add(p_Date_Added);

			//Added_By_Emp_ID
			arrParamName.Add("Added_By_Emp_ID");
			arrParmnValue.Add(p_Added_By_Emp_ID);

			return ExecuteStoredProcUpsert(Constants.DBNAME_ASSET_TRACKING, Constants.STORED_PROC_SP_UPSERT_ASSET_BIN_MAPPING, arrParamName, arrParmnValue);
		}

		/// <summary>
		/// Update and Insert Method
		/// </summary>
		/// <param name="p_ID">-1 will insert a new record, passing in the ID will update the record</param>
		/// <param name="p_Asset_Bin_Mapping_ID">Asset_Bin_Mapping_ID</param>
		/// <param name="p_Column_Name">Column_Name</param>
		/// <param name="p_Old_Value">Old_Value</param>
		/// <param name="p_New_Value">New_Value</param>
		/// <param name="p_Emp_ID">Emp_ID</param>
		/// <param name="p_Date_Modified">Date_Modified</param>
		/// <returns>String value of the ID that was updated or inserted</returns>
		public static string Upsert_Asset_Bin_Mapping_Audit_Log(string p_ID, string p_Asset_Bin_Mapping_ID, string p_Column_Name, string p_Old_Value, string p_New_Value, string p_Emp_ID, string p_Date_Modified)
		{
			ArrayList arrParamName = new ArrayList();
			ArrayList arrParmnValue = new ArrayList();

			//ID
			arrParamName.Add("ID");
			arrParmnValue.Add(p_ID);

			//Asset_Bin_Mapping_ID
			arrParamName.Add("Asset_Bin_Mapping_ID");
			arrParmnValue.Add(p_Asset_Bin_Mapping_ID);

			//Column_Name
			arrParamName.Add("Column_Name");
			arrParmnValue.Add(p_Column_Name);

			//Old_Value
			arrParamName.Add("Old_Value");
			arrParmnValue.Add(p_Old_Value);

			//New_Value
			arrParamName.Add("New_Value");
			arrParmnValue.Add(p_New_Value);

			//Emp_ID
			arrParamName.Add("Emp_ID");
			arrParmnValue.Add(p_Emp_ID);

			//Date_Modified
			arrParamName.Add("Date_Modified");
			arrParmnValue.Add(p_Date_Modified);

			return ExecuteStoredProcUpsert(Constants.DBNAME_ASSET_TRACKING, Constants.STORED_PROC_SP_UPSERT_ASSET_BIN_MAPPING_AUDIT_LOG, arrParamName, arrParmnValue);
		}

        /// <summary>
        /// Update and Insert Method
        /// </summary>
        /// <param name="p_ID">-1 will insert a new record, passing in the ID will update the record</param>
        /// <param name="p_Asset_ID">Asset ID</param>
        /// <param name="p_Student_ID">Student ID</param>
        /// <param name="p_Comment">Comment</param>
        /// <param name="p_Added_By_Emp_ID">Added By Emp ID</param>
        /// <param name="p_Date_Added">Date Added</param>
        /// <param name="p_Modified_By_Emp_ID">Modified By Emp ID</param>
        /// <param name="p_Date_Modified">Date Modified</param>
        /// <param name="p_Attachments">xml string for attachments</param>
        /// <returns></returns>
        public static string Upsert_Asset_Tamper(
            string p_ID, string p_Asset_ID, string p_Student_ID, string p_Comment, string p_Added_By_Emp_ID, 
            string p_Date_Added, string p_Modified_By_Emp_ID, string p_Date_Modified, string p_Attachments
        )
        {
            ArrayList arrParamName = new ArrayList();
            ArrayList arrParmnValue = new ArrayList();

            //ID
            arrParamName.Add("ID");
            arrParmnValue.Add(p_ID);

            //Asset_Site_ID
            arrParamName.Add("Asset_ID");
            arrParmnValue.Add(p_Asset_ID);

            //Name
            arrParamName.Add("Student_ID");
            arrParmnValue.Add(p_Student_ID);

            //Description
            arrParamName.Add("Comment");
            arrParmnValue.Add(p_Comment);

            //Added_By_Emp_ID
            arrParamName.Add("Added_By_Emp_ID");
            arrParmnValue.Add(p_Added_By_Emp_ID);

            //Date_Added
            arrParamName.Add("Date_Added");
            arrParmnValue.Add(p_Date_Added);

            //Modified_By_Emp_ID
            arrParamName.Add("Modified_By_Emp_ID");
            arrParmnValue.Add(p_Modified_By_Emp_ID);

            //Date_Modified
            arrParamName.Add("Date_Modified");
            arrParmnValue.Add(p_Date_Modified);

            //Date_Modified
            arrParamName.Add("Attachments");
            arrParmnValue.Add(p_Attachments);

            return ExecuteStoredProcUpsert(Constants.DBNAME_ASSET_TRACKING, Constants.STORED_PROC_SP_UPSERT_ASSET_TAMPER, arrParamName, arrParmnValue);
        }


		/// <summary>
		/// Update and Insert Method
		/// </summary>
		/// <param name="p_ID">-1 will insert a new record, passing in the ID will update the record</param>
		/// <param name="p_Asset_Site_ID">Asset_Site_ID</param>
		/// <param name="p_Name">Name</param>
		/// <param name="p_Description">Description</param>
		/// <param name="p_Added_By_Emp_ID">Added_By_Emp_ID</param>
		/// <param name="p_Date_Added">Date_Added</param>
		/// <param name="p_Modified_By_Emp_ID">Modified_By_Emp_ID</param>
		/// <param name="p_Date_Modified">Date_Modified</param>
		/// <param name="p_Has_Submit">Has_Submit</param>
		/// <param name="p_Date_Submit">Date_Submit</param>
		/// <param name="p_Submitted_By_Emp_ID">Submitted_By_Emp_ID</param>
		/// <returns>String value of the ID that was updated or inserted</returns>
		public static string Upsert_Asset_Temp_Header(string p_ID, string p_Asset_Site_ID, string p_Name, string p_Description, string p_Added_By_Emp_ID, string p_Date_Added, string p_Modified_By_Emp_ID, string p_Date_Modified, string p_Has_Submit, string p_Date_Submit, string p_Submitted_By_Emp_ID)
		{
			ArrayList arrParamName = new ArrayList();
			ArrayList arrParmnValue = new ArrayList();

			//ID
			arrParamName.Add("ID");
			arrParmnValue.Add(p_ID);

			//Asset_Site_ID
			arrParamName.Add("Asset_Site_ID");
			arrParmnValue.Add(p_Asset_Site_ID);

			//Name
			arrParamName.Add("Name");
			arrParmnValue.Add(p_Name);

			//Description
			arrParamName.Add("Description");
			arrParmnValue.Add(p_Description);

			//Added_By_Emp_ID
			arrParamName.Add("Added_By_Emp_ID");
			arrParmnValue.Add(p_Added_By_Emp_ID);

			//Date_Added
			arrParamName.Add("Date_Added");
			arrParmnValue.Add(p_Date_Added);

			//Modified_By_Emp_ID
			arrParamName.Add("Modified_By_Emp_ID");
			arrParmnValue.Add(p_Modified_By_Emp_ID);

			//Date_Modified
			arrParamName.Add("Date_Modified");
			arrParmnValue.Add(p_Date_Modified);

			//Has_Submit
			arrParamName.Add("Has_Submit");
			arrParmnValue.Add(p_Has_Submit);

			//Date_Submit
			arrParamName.Add("Date_Submit");
			arrParmnValue.Add(p_Date_Submit);

			//Submitted_By_Emp_ID
			arrParamName.Add("Submitted_By_Emp_ID");
			arrParmnValue.Add(p_Submitted_By_Emp_ID);

			return ExecuteStoredProcUpsert(Constants.DBNAME_ASSET_TRACKING, Constants.STORED_PROC_SP_UPSERT_ASSET_TEMP_HEADER, arrParamName, arrParmnValue);
		}

		/// <summary>
		/// Update and Insert Method
		/// </summary>
		/// <param name="p_ID">-1 will insert a new record, passing in the ID will update the record</param>
		/// <param name="p_Asset_Temp_Header_ID">Asset_Temp_Header_ID</param>
		/// <param name="p_Tag_ID">Tag_ID</param>
		/// <param name="p_Asset_Disposition_ID">Asset_Disposition_ID</param>
		/// <param name="p_Asset_Condition_ID">Asset_Condition_ID</param>
		/// <param name="p_Asset_Type_ID">Asset_Type_ID</param>
		/// <param name="p_Asset_Assignment_Type_ID">Asset_Assignment_Type_ID</param>
		/// <param name="p_Bin_ID">Bin_ID</param>
		/// <param name="p_Serial_Number">Serial_Number</param>
		/// <param name="p_Date_Purchased">Date_Purchased</param>
		/// <param name="p_Is_Leased">Is_Leased</param>
		/// <param name="p_Date_Added">Date_Added</param>
		/// <param name="p_Added_By_Emp_ID">Added_By_Emp_ID</param>
		/// <returns>String value of the ID that was updated or inserted</returns>
		public static string Upsert_Asset_Temp_Detail(string p_ID, string p_Asset_Temp_Header_ID, string p_Tag_ID, string p_Asset_Disposition_ID, string p_Asset_Condition_ID, string p_Asset_Type_ID, string p_Asset_Assignment_Type_ID, string p_Bin_ID, string p_Serial_Number, string p_Date_Purchased, string p_Is_Leased, string p_Leased_Term_Days, string p_Warranty_Term_Days, string p_Date_Added, string p_Added_By_Emp_ID)
		{
			ArrayList arrParamName = new ArrayList();
			ArrayList arrParmnValue = new ArrayList();

			//ID
			arrParamName.Add("ID");
			arrParmnValue.Add(p_ID);

			//Asset_Temp_Header_ID
			arrParamName.Add("Asset_Temp_Header_ID");
			arrParmnValue.Add(p_Asset_Temp_Header_ID);

			//Tag_ID
			arrParamName.Add("Tag_ID");
			arrParmnValue.Add(p_Tag_ID);

			//Asset_Disposition_ID
			arrParamName.Add("Asset_Disposition_ID");
			arrParmnValue.Add(p_Asset_Disposition_ID);

			//Asset_Condition_ID
			arrParamName.Add("Asset_Condition_ID");
			arrParmnValue.Add(p_Asset_Condition_ID);

			//Asset_Type_ID
			arrParamName.Add("Asset_Type_ID");
			arrParmnValue.Add(p_Asset_Type_ID);

			//Asset_Assignment_Type_ID
			arrParamName.Add("Asset_Assignment_Type_ID");
			arrParmnValue.Add(p_Asset_Assignment_Type_ID);

			//Bin_ID
			arrParamName.Add("Bin_ID");
			arrParmnValue.Add(p_Bin_ID);

			//Serial_Number
			arrParamName.Add("Serial_Number");
			arrParmnValue.Add(p_Serial_Number);

			//Date_Purchased
			arrParamName.Add("Date_Purchased");
			arrParmnValue.Add(p_Date_Purchased);

			//Is_Leased
			arrParamName.Add("Is_Leased");
			arrParmnValue.Add(p_Is_Leased);

            //Leased Term Days
            arrParamName.Add("Leased_Term_Days");
            arrParmnValue.Add(p_Leased_Term_Days);

            //Leased Term Days
            arrParamName.Add("Warranty_Term_Days");
            arrParmnValue.Add(p_Warranty_Term_Days);
            
			//Date_Added
			arrParamName.Add("Date_Added");
			arrParmnValue.Add(p_Date_Added);

			//Added_By_Emp_ID
			arrParamName.Add("Added_By_Emp_ID");
			arrParmnValue.Add(p_Added_By_Emp_ID);

			return ExecuteStoredProcUpsert(Constants.DBNAME_ASSET_TRACKING, Constants.STORED_PROC_SP_UPSERT_ASSET_TEMP_DETAIL, arrParamName, arrParmnValue);
		}

		/// <summary>
		/// Update and Insert Method
		/// </summary>
		/// <param name="p_ID">-1 will insert a new record, passing in the ID will update the record</param>
		/// <param name="p_Filter_Value">Filter_Value</param>
		/// <param name="p_Filter_Text">Filter_Text</param>
		/// <param name="p_Added_By_Emp_ID">Added_By_Emp_ID</param>
		/// <param name="p_Date_Added">Date_Added</param>
		/// <param name="p_Modified_By_Emp_ID">Modified_By_Emp_ID</param>
		/// <param name="p_Date_Modified">Date_Modified</param>
		/// <returns>String value of the ID that was updated or inserted</returns>
		public static string Upsert_Asset_Search(string p_ID, string p_Filter_Value, string p_Filter_Text, string p_Added_By_Emp_ID, string p_Date_Added, string p_Modified_By_Emp_ID, string p_Date_Modified)
		{
			ArrayList arrParamName = new ArrayList();
			ArrayList arrParmnValue = new ArrayList();

			//ID
			arrParamName.Add("ID");
			arrParmnValue.Add(p_ID);

			//Filter_Value
			arrParamName.Add("Filter_Value");
			arrParmnValue.Add(p_Filter_Value);

			//Filter_Text
			arrParamName.Add("Filter_Text");
			arrParmnValue.Add(p_Filter_Text);

			//Added_By_Emp_ID
			arrParamName.Add("Added_By_Emp_ID");
			arrParmnValue.Add(p_Added_By_Emp_ID);

			//Date_Added
			arrParamName.Add("Date_Added");
			arrParmnValue.Add(p_Date_Added);

			//Modified_By_Emp_ID
			arrParamName.Add("Modified_By_Emp_ID");
			arrParmnValue.Add(p_Modified_By_Emp_ID);

			//Date_Modified
			arrParamName.Add("Date_Modified");
			arrParmnValue.Add(p_Date_Modified);

			return ExecuteStoredProcUpsert(Constants.DBNAME_ASSET_TRACKING, Constants.STORED_PROC_SP_UPSERT_ASSET_SEARCH, arrParamName, arrParmnValue);
		}

		/// <summary>
		/// Update and Insert Method
		/// </summary>
		/// <param name="p_ID">-1 will insert a new record, passing in the ID will update the record</param>
		/// <param name="p_Asset_ID">Asset_ID</param>
		/// <param name="p_Comment">Comment</param>
		/// <param name="p_Added_By_Emp_ID">Added_By_Emp_ID</param>
		/// <param name="p_Date_Added">Date_Added</param>
		/// <param name="p_Modified_By_Emp_ID">Modified_By_Emp_ID</param>
		/// <param name="p_Date_Modified">Date_Modified</param>
		/// <returns>String value of the ID that was updated or inserted</returns>
		public static string Upsert_Asset_Comment(string p_ID, string p_Asset_ID, string p_Comment, string p_Added_By_Emp_ID, string p_Date_Added, string p_Modified_By_Emp_ID, string p_Date_Modified)
		{
			ArrayList arrParamName = new ArrayList();
			ArrayList arrParmnValue = new ArrayList();

			//ID
			arrParamName.Add("ID");
			arrParmnValue.Add(p_ID);

			//Asset_ID
			arrParamName.Add("Asset_ID");
			arrParmnValue.Add(p_Asset_ID);

			//Comment
			arrParamName.Add("Comment");
			arrParmnValue.Add(p_Comment);

			//Added_By_Emp_ID
			arrParamName.Add("Added_By_Emp_ID");
			arrParmnValue.Add(p_Added_By_Emp_ID);

			//Date_Added
			arrParamName.Add("Date_Added");
			arrParmnValue.Add(p_Date_Added);

			//Modified_By_Emp_ID
			arrParamName.Add("Modified_By_Emp_ID");
			arrParmnValue.Add(p_Modified_By_Emp_ID);

			//Date_Modified
			arrParamName.Add("Date_Modified");
			arrParmnValue.Add(p_Date_Modified);

			return ExecuteStoredProcUpsert(Constants.DBNAME_ASSET_TRACKING, Constants.STORED_PROC_SP_UPSERT_ASSET_COMMENT, arrParamName, arrParmnValue);
		}

        
        /// <summary>
        /// Update and Insert Method
        /// </summary>
        /// <param name="p_ID"></param>
        /// <param name="p_Asset_ID"></param>
        /// <param name="p_Law_Enforcement_Agency_ID"></param>
        /// <param name="p_Officer_First_Name"></param>
        /// <param name="p_Officer_Last_Name"></param>
        /// <param name="p_Case_Number"></param>
        /// <param name="p_Comment"></param>
        /// <param name="p_Date_Picked_Up"></param>
        /// <param name="p_Date_Returned"></param>
        /// <param name="p_Received_By_Emp_ID"></param>
        /// <param name="p_Added_By_Emp_ID"></param>
        /// <param name="p_Date_Added"></param>
        /// <param name="p_Modified_By_Emp_ID"></param>
        /// <param name="p_Date_Modified"></param>
        /// <returns></returns>
        public static string Upsert_Asset_Law_Enforcement(
            string p_ID, 
            string p_Asset_ID, 
            string p_Law_Enforcement_Agency_ID,
            string p_Officer_First_Name,
            string p_Officer_Last_Name,
            string p_Case_Number,
            string p_Comment, 
            string p_Date_Picked_Up,
            string p_Date_Returned,
            string p_Received_By_Emp_ID,
            string p_Added_By_Emp_ID, 
            string p_Date_Added, 
            string p_Modified_By_Emp_ID, 
            string p_Date_Modified
        )
        {
            ArrayList arrParamName = new ArrayList();
            ArrayList arrParmnValue = new ArrayList();

            //ID
            arrParamName.Add("ID");
            arrParmnValue.Add(p_ID);

            //Asset_ID
            arrParamName.Add("Asset_ID");
            arrParmnValue.Add(p_Asset_ID);

            //Law_Enforcement_Agency_ID
            arrParamName.Add("Law_Enforcement_Agency_ID");
            arrParmnValue.Add(p_Law_Enforcement_Agency_ID);

            //Officer_First_Name
            arrParamName.Add("Officer_First_Name");
            arrParmnValue.Add(p_Officer_First_Name);

            //Officer_Last_Name
            arrParamName.Add("Officer_Last_Name");
            arrParmnValue.Add(p_Officer_Last_Name);

            //Case Number
            arrParamName.Add("Case_Number");
            arrParmnValue.Add(p_Case_Number);

            //Comment
            arrParamName.Add("Comment");
            arrParmnValue.Add(p_Comment);

            //Date_Picked_Up
            arrParamName.Add("Date_Picked_Up");
            arrParmnValue.Add(p_Date_Picked_Up);

            //Date_Returned
            arrParamName.Add("Date_Returned");
            arrParmnValue.Add(p_Date_Returned);

            //Received_By_Emp_ID
            arrParamName.Add("Received_By_Emp_ID");
            arrParmnValue.Add(p_Received_By_Emp_ID);

            //Added_By_Emp_ID
            arrParamName.Add("Added_By_Emp_ID");
            arrParmnValue.Add(p_Added_By_Emp_ID);

            //Date_Added
            arrParamName.Add("Date_Added");
            arrParmnValue.Add(p_Date_Added);

            //Modified_By_Emp_ID
            arrParamName.Add("Modified_By_Emp_ID");
            arrParmnValue.Add(p_Modified_By_Emp_ID);

            //Date_Modified
            arrParamName.Add("Date_Modified");
            arrParmnValue.Add(p_Date_Modified);

            return ExecuteStoredProcUpsert(Constants.DBNAME_ASSET_TRACKING, Constants.STORED_PROC_SP_UPSERT_ASSET_LAW_ENFORCEMENT, arrParamName, arrParmnValue);
        }

        
        /// <summary>
		/// Update and Insert Method
		/// </summary>
		/// <param name="p_ID">-1 will insert a new record, passing in the ID will update the record</param>
		/// <param name="p_Asset_ID">Asset_ID</param>
		/// <param name="p_Student_ID">Student_ID</param>
		/// <param name="p_File_Type_ID">File_Type_ID</param>
		/// <param name="p_Name">Name</param>
		/// <param name="p_Description">Description</param>
		/// <param name="p_Added_By_Emp_ID">Added_By_Emp_ID</param>
		/// <param name="p_Date_Added">Date_Added</param>
		/// <returns>String value of the ID that was updated or inserted</returns>
		public static string Upsert_Asset_Attachment(string p_ID, string p_Asset_ID, string p_Student_ID, string p_Asset_Tamper_ID, string p_File_Type_ID, string p_Name, string p_Description, string p_Added_By_Emp_ID, string p_Date_Added, string p_Modified_By_Emp_ID, string p_Date_Modified)
		{
			ArrayList arrParamName = new ArrayList();
			ArrayList arrParmnValue = new ArrayList();

			//ID
			arrParamName.Add("ID");
			arrParmnValue.Add(p_ID);

			//Asset_ID
			arrParamName.Add("Asset_ID");
			arrParmnValue.Add(p_Asset_ID);

			//Student_ID
			arrParamName.Add("Student_ID");
			arrParmnValue.Add(p_Student_ID);

            //Asset_Tamper_ID
            arrParamName.Add("Asset_Tamper_ID");
            arrParmnValue.Add(p_Asset_Tamper_ID);

			//File_Type_ID
			arrParamName.Add("File_Type_ID");
			arrParmnValue.Add(p_File_Type_ID);

			//Name
			arrParamName.Add("Name");
			arrParmnValue.Add(p_Name);

			//Description
			arrParamName.Add("Description");
			arrParmnValue.Add(p_Description);

			//Added_By_Emp_ID
			arrParamName.Add("Added_By_Emp_ID");
			arrParmnValue.Add(p_Added_By_Emp_ID);

			//Date_Added
			arrParamName.Add("Date_Added");
			arrParmnValue.Add(p_Date_Added);

			//Modified_By_Emp_ID
			arrParamName.Add("Modified_By_Emp_ID");
			arrParmnValue.Add(p_Modified_By_Emp_ID);

			//Date_Modified
			arrParamName.Add("Date_Modified");
			arrParmnValue.Add(p_Date_Modified);

			return ExecuteStoredProcUpsert(Constants.DBNAME_ASSET_TRACKING, Constants.STORED_PROC_SP_UPSERT_ASSET_ATTACHMENT, arrParamName, arrParmnValue);
		}

		/// <summary>
		/// Update and Insert Method
		/// </summary>
		/// <param name="p_ID">-1 will insert a new record, passing in the ID will update the record</param>
		/// <param name="p_Asset_ID">Asset_ID</param>
		/// <param name="p_Asset_Student_Transaction_ID">Asset_Student_Transaction_ID</param>
		/// <param name="p_Repair_Type_ID">Repair_Type_ID</param>
		/// <param name="p_Comment">Comment</param>
		/// <param name="p_Date_Sent">Date_Sent</param>
		/// <param name="p_Date_Received">Date_Received</param>
		/// <param name="p_Added_By_Emp_ID">Added_By_Emp_ID</param>
		/// <param name="p_Date_Added">Date_Added</param>
		/// <param name="p_Modified_By_Emp_ID">Modified_By_Emp_ID</param>
		/// <param name="p_Date_Modified">Date_Modified</param>
		/// <returns>String value of the ID that was updated or inserted</returns>
		public static string Upsert_Asset_Repair(string p_ID, string p_Asset_ID, string p_Repair_Type_ID, string p_Comment, string p_Date_Sent, string p_Date_Received, string p_Received_By_Emp_ID, string p_Received_Disposition_ID, string p_Added_By_Emp_ID, string p_Date_Added, string p_Modified_By_Emp_ID, string p_Date_Modified)
		{
			ArrayList arrParamName = new ArrayList();
			ArrayList arrParmnValue = new ArrayList();

			//ID
			arrParamName.Add("ID");
			arrParmnValue.Add(p_ID);

			//Asset_ID
			arrParamName.Add("Asset_ID");
			arrParmnValue.Add(p_Asset_ID);

			//Repair_Type_ID
			arrParamName.Add("Repair_Type_ID");
			arrParmnValue.Add(p_Repair_Type_ID);

			//Comment
			arrParamName.Add("Comment");
			arrParmnValue.Add(p_Comment);

			//Date_Sent
			arrParamName.Add("Date_Sent");
			arrParmnValue.Add(p_Date_Sent);

			//Date_Received
			arrParamName.Add("Date_Received");
			arrParmnValue.Add(p_Date_Received);

			//Received_By_Emp_ID
			arrParamName.Add("Received_By_Emp_ID");
			arrParmnValue.Add(p_Received_By_Emp_ID);

            //Received_Disposition_ID
            arrParamName.Add("Received_Disposition_ID");
            arrParmnValue.Add(p_Received_Disposition_ID);

			//Added_By_Emp_ID
			arrParamName.Add("Added_By_Emp_ID");
			arrParmnValue.Add(p_Added_By_Emp_ID);

			//Date_Added
			arrParamName.Add("Date_Added");
			arrParmnValue.Add(p_Date_Added);

			//Modified_By_Emp_ID
			arrParamName.Add("Modified_By_Emp_ID");
			arrParmnValue.Add(p_Modified_By_Emp_ID);

			//Date_Modified
			arrParamName.Add("Date_Modified");
			arrParmnValue.Add(p_Date_Modified);

			return ExecuteStoredProcUpsert(Constants.DBNAME_ASSET_TRACKING, Constants.STORED_PROC_SP_UPSERT_ASSET_REPAIR, arrParamName, arrParmnValue);
		}

		/// <summary>
		/// Update User Preferences
		/// </summary>
		/// <param name="p_Emp_ID">Employee ID</param>
		/// <param name="p_App_Preference_Type_Code">Preference Code</param>
		/// <param name="p_Preference_Value">Value</param>
		/// <returns>ID of the record inserted or updated</returns>
		public static string Upsert_App_User_Preference(string p_Emp_ID, string p_App_Preference_Type_Code, string p_Preference_Value)
		{
			ArrayList arrParamName = new ArrayList();
			ArrayList arrParmnValue = new ArrayList();

			//Emp_ID
			arrParamName.Add("Emp_ID");
			arrParmnValue.Add(p_Emp_ID);

			//App_Preference_Type_Code
			arrParamName.Add("App_Preference_Type_Code");
			arrParmnValue.Add(p_App_Preference_Type_Code);

			//Preference_Value
			arrParamName.Add("Preference_Value");
			arrParmnValue.Add(p_Preference_Value);

			return ExecuteStoredProcUpsert(Constants.STORED_PROC_SP_UPSERT_APP_USER_PREFERENCE, arrParamName, arrParmnValue);
		}

		
		#endregion

		//Delete Method
		#region Delete Method

		public static void DeleteAsset_Temp_Detail(string id)
		{
			Utilities.Assert(!Utilities.isNull(id), "Asset Temp Detail ID Expected.");
			ExecuteStoredProcNoResults(Constants.DBNAME_ASSET_TRACKING, Constants.STORED_PROC_DELETE_ASSET_TEMP_DETAIL, "ID", id);
		}

		public static void DeleteAsset_Temp_Header(string id)
		{
			Utilities.Assert(!Utilities.isNull(id), "Asset Temp Header ID Expected.");
			ExecuteStoredProcNoResults(Constants.DBNAME_ASSET_TRACKING, Constants.STORED_PROC_DELETE_ASSET_TEMP_HEADER, "ID", id);
		}

		public static void DeleteAsset_Attachment(string id)
		{
			Utilities.Assert(!Utilities.isNull(id), "Attachment ID Expected.");
			ExecuteStoredProcNoResults(Constants.DBNAME_ASSET_TRACKING, Constants.STORED_PROC_DELETE_ASSET_ATTACHMENT, "ID", id);
		}

		public static void DeleteAsset_Comment(string id)
		{
			Utilities.Assert(!Utilities.isNull(id), "Comment ID Expected.");
			ExecuteStoredProcNoResults(Constants.DBNAME_ASSET_TRACKING, Constants.STORED_PROC_DELETE_ASSET_COMMENT, "ID", id);
		}

		public static void DeleteAsset_Repair(string id)
		{
			Utilities.Assert(!Utilities.isNull(id), "Repair ID Expected.");
			ExecuteStoredProcNoResults(Constants.DBNAME_ASSET_TRACKING, Constants.STORED_PROC_DELETE_ASSET_REPAIR, "ID", id);
		}

        public static void DeleteAsset_Tamper(string id)
        {
            Utilities.Assert(!Utilities.isNull(id), "Tamper ID Expected.");
            ExecuteStoredProcNoResults(Constants.DBNAME_ASSET_TRACKING, Constants.STORED_PROC_DELETE_ASSET_TAMPER, "ID", id);
        }

        public static void DeleteAsset_Law_Enforcement(string id)
        {
            Utilities.Assert(!Utilities.isNull(id), "Asset Law Enforcement ID Expected.");
            ExecuteStoredProcNoResults(Constants.DBNAME_ASSET_TRACKING, Constants.STORED_PROC_DELETE_ASSET_LAW_ENFORCEMENT, "ID", id);
        }


		#endregion

		//Validation
		#region Validation

		public static DataSet DsValidateOnAddAssetToTemp(string headerid, string tagid, string serial_number, string bin_id, string is_leased, string asset_type)
		{
            /*IMPORTANT - Any validation added to this must also be added to 
             * 1.sp_Asset_Temp_With_Validation_Message
             * 
             * */
            Utilities.Assert(!Utilities.isNull(headerid) && !Utilities.isNull(tagid) && !Utilities.isNull(serial_number), "Header ID, Tag ID and Serial Number all expected.");

			if (Utilities.isNull(bin_id))
			{
				bin_id = "-1";
			}

			ArrayList arrNames = new ArrayList();
			ArrayList arrValues = new ArrayList();

			//Header ID
			arrNames.Add("Header_ID");
			arrValues.Add(headerid);

			//Tag ID
			arrNames.Add("Tag_ID");
			arrValues.Add(tagid);

            //Serial Number
            arrNames.Add("Serial_Number");
            arrValues.Add(serial_number);

			//Bin ID
			arrNames.Add("Bin_ID");
			arrValues.Add(bin_id);

            //Is Leased
            arrNames.Add("Is_Leased");
            arrValues.Add(is_leased);

            //Asset Type
            arrNames.Add("Asset_Type_ID");
            arrValues.Add(asset_type);

			return ExecuteStoredProc(Constants.STORED_PROC_SP_VALIDATE_ON_ADD_ASSET_TO_TEMP, arrNames, arrValues);

		}

		public static DataSet DsValidateEditAssetTemp(string header_id, string bin_id)
		{
			Utilities.Assert(!Utilities.isNull(header_id) && !Utilities.isNull(bin_id), "Header ID and Bin ID expected.");
		   
			ArrayList arrNames = new ArrayList();
			ArrayList arrValues = new ArrayList();

			//Header ID
			arrNames.Add("Header_ID");
			arrValues.Add(header_id);

			//Bin ID
			arrNames.Add("Bin_ID");
			arrValues.Add(bin_id);

			return ExecuteStoredProc(Constants.STORED_PROC_SP_VALIDATE_EDIT_ASSET_TEMP, arrNames, arrValues);
		}

        public static DataSet DsValidateEditAsset(string asset_id, string tag_id, string serial_number)
        {
            Utilities.Assert(!Utilities.isNull(asset_id) && !Utilities.isNull(tag_id) && !Utilities.isNull(serial_number), "Asset ID,Tag ID and Serial # expected.");

            ArrayList arrNames = new ArrayList();
            ArrayList arrValues = new ArrayList();

            //Asset ID
            arrNames.Add("Asset_ID");
            arrValues.Add(asset_id);

            //Tag ID
            arrNames.Add("Tag_ID");
            arrValues.Add(tag_id);

            //Serial_Number
            arrNames.Add("Serial_Number");
            arrValues.Add(serial_number);

            return ExecuteStoredProc(Constants.STORED_PROC_SP_VALIDATE_EDIT_ASSET, arrNames, arrValues);
        }

		public static DataSet DsValidateDuplicateAttachmentName(string asset_id, string attachment_id, string attachment_name, string attachment_type)
		{
			Utilities.Assert(!Utilities.isNull(asset_id) 
							&& !Utilities.isNull(attachment_name) 
							&& !Utilities.isNull(attachment_type), "Asset ID, Name, and Attachment Type all expected.");

			ArrayList arrNames = new ArrayList();
			ArrayList arrValues = new ArrayList();

			//Asset ID
			arrNames.Add("Asset_ID");
			arrValues.Add(asset_id);

			//Attachment ID
			arrNames.Add("Attachement_ID");
			arrValues.Add(attachment_id);

			//Attachment Name
			arrNames.Add("Attachment_Name");
			arrValues.Add(attachment_name);

			//Attachment Type
			arrNames.Add("Attachment_Type");
			arrValues.Add(attachment_type);
			
			return ExecuteStoredProc(Constants.STORED_PROC_SP_VALIDATE_DUPLICATE_ATTACHMENT_NAME, arrNames, arrValues);
		}

		public static DataSet DsValidateAssignAssetToBin(string tag_id, string bin_id)
		{
			Utilities.Assert(!Utilities.isNull(tag_id) && !Utilities.isNull(bin_id), "Tag ID and Bin ID Expected.");

			ArrayList arrNames = new ArrayList();
			ArrayList arrValues = new ArrayList();

			//Tag ID
			arrNames.Add("Tag_ID");
			arrValues.Add(tag_id);

			//Bin ID
			arrNames.Add("Bin_ID");
			arrValues.Add(bin_id);

			return ExecuteStoredProc(Constants.STORED_PROC_SP_VALIDATE_ASSIGN_ASSET_TO_BIN, arrNames, arrValues);
		}

		public static DataSet DsValidateCheckOutAsset(string tag_id, string serial_number, string student_id)
		{
			Utilities.Assert(!Utilities.isNull(tag_id) && !Utilities.isNull(student_id), "Tag ID and Student ID Expected.");
		   
			ArrayList arrNames = new ArrayList();
			ArrayList arrValues = new ArrayList();

			//Student ID
			arrNames.Add("Student_ID");
			arrValues.Add(student_id);

			//Tag ID
			arrNames.Add("Tag_ID");
			arrValues.Add(tag_id);
            
            //Serial Number
            arrNames.Add("Serial_Number");
            arrValues.Add(serial_number);

			return ExecuteStoredProc(Constants.STORED_PROC_SP_VALIDATE_STUDENT_CHECKOUT, arrNames, arrValues);
		}

		public static DataSet DsValidateMassetAssignAssetToBin(string asset_search_id, string bin_id)
		{
			Utilities.Assert(!Utilities.isNull(asset_search_id), "Asset Search ID Expected.");

			ArrayList arrNames = new ArrayList();
			ArrayList arrValues = new ArrayList();

			//Asset Search ID
			arrNames.Add("Asset_Search_ID");
			arrValues.Add(asset_search_id);

			//Bin ID
			arrNames.Add("Bin_ID");
			arrValues.Add(bin_id);

			return ExecuteStoredProc(Constants.STORED_PROC_SP_VALIDATE_MASS_ASSIGN_ASSET_TO_BIN, arrNames, arrValues);
		}

		#endregion

		//Security Method
		#region GetAppSecurity
		public static DataSet DsGetUserSecurityInfo(string loggedonuser)
		{
			string sLoginUser = loggedonuser;
			string sSQL = @"DECLARE @userlogin as varchar(100)
							SET @userlogin = '" + sLoginUser + @"'

							select 
								*
							from v_User_Security_Info u
							where u.NetworkLogin = @userlogin";
			return ExecuteSQLStatement(sSQL);
		}
		#endregion

		//App Logging
		#region App Logging

		//LogEvent
		public static void Insert_Log_Event(
			 string p_appid,
			 string p_recordtype,
			 string p_module,
			 string p_description,
			 string p_userid,
			 string p_usermachinename,
			 string p_useripaddress
		 )
		{
			ArrayList arrParamName = new ArrayList();
			ArrayList arrParmnValue = new ArrayList();

			//appid
			arrParamName.Add("appid");
			arrParmnValue.Add(p_appid);

			//recordtype
			arrParamName.Add("recordtype");
			arrParmnValue.Add(p_recordtype);

			//module
			arrParamName.Add("module");
			arrParmnValue.Add(p_module);

			//description
			arrParamName.Add("description");
			arrParmnValue.Add(p_description);

			//userid
			arrParamName.Add("userid");
			arrParmnValue.Add(p_userid);

			//usermachinename
			arrParamName.Add("usermachinename");
			arrParmnValue.Add(p_usermachinename);

			//useripaddress
			arrParamName.Add("useripaddress");
			arrParmnValue.Add(p_useripaddress);

			ExecuteStoredProc(Constants.DBNAME_SECURITY, Constants.SECURITY_STORED_PROC_INSERT_APPLICATION_LOG_EVENT, arrParamName, arrParmnValue);
		}


		//App Activity Logging 
		public static string Insert_App_Activity(
			 string p_url,
			 string p_page_name,
			 string p_page_parameter,
			 string p_emp_id,
			 string p_date_added
		 )
		{
			ArrayList arrParamName = new ArrayList();
			ArrayList arrParmnValue = new ArrayList();

			//URL
			arrParamName.Add("URL");
			arrParmnValue.Add(p_url);

			//Page_Name
			arrParamName.Add("Page_Name");
			arrParmnValue.Add(p_page_name);

			//Page_Parameter
			arrParamName.Add("Page_Parameter");
			arrParmnValue.Add(p_page_parameter);

			//Emp_ID
			arrParamName.Add("Emp_ID");
			arrParmnValue.Add(p_emp_id);

			//Date_Added
			arrParamName.Add("Date_Added");
			arrParmnValue.Add(p_date_added);

			
			return ExecuteStoredProcUpsert(Constants.STORED_PROC_SP_INSERT_APP_ACTIVITY, arrParamName, arrParmnValue);
		}

		//Error Logging
		public static string Insert_Security_SP_Insert_Application_Exceptions(
			 string p_applicationname,
			 string p_pagename,
			 string p_exceptiontype,
			 string p_stacktrace,
			 string p_exceptionmessage,
			 string p_exceptiondate,
			 string p_networklogin,
			 string p_machinename,
			 string p_ipaddress
		 )
		{
			ArrayList arrParamName = new ArrayList();
			ArrayList arrParmnValue = new ArrayList();

			//applicationname
			arrParamName.Add("applicationname");
			arrParmnValue.Add(p_applicationname);

			//pagename
			arrParamName.Add("pagename");
			arrParmnValue.Add(p_pagename);

			//exceptiontype
			arrParamName.Add("exceptiontype");
			arrParmnValue.Add(p_exceptiontype);

			//stacktrace
			arrParamName.Add("stacktrace");
			arrParmnValue.Add(p_stacktrace);

			//exceptionmessage
			arrParamName.Add("exceptionmessage");
			arrParmnValue.Add(p_exceptionmessage);

			//exceptiondate
			arrParamName.Add("exceptiondate");
			arrParmnValue.Add(p_exceptiondate);

			//networklogin
			arrParamName.Add("networklogin");
			arrParmnValue.Add(p_networklogin);

			//machinename
			arrParamName.Add("machinename");
			arrParmnValue.Add(p_machinename);

			//ipaddress
			arrParamName.Add("ipaddress");
			arrParmnValue.Add(p_ipaddress);

			return ExecuteStoredProcUpsert(Constants.DBNAME_SECURITY, Constants.SECURITY_STORED_PROC_SP_INSERT_APPLICATION_EXCEPTIONS, arrParamName, arrParmnValue);
		}

		#endregion

	}
}