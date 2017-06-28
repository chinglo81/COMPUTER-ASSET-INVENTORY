using System;
using System.Data.Sql;


    /// <summary>
    /// Summary description for SQLQueryException.
    /// </summary>
    public class SQLQueryException : ApplicationException
    {
        public string SQLStatement;
        private Exception originalException;

        public SQLQueryException(string sSQL, Exception exc)
        {
            SQLStatement = sSQL;
            originalException = exc;
        }

        public override string Message
        {
            get
            {
                return "SQL Statement Failed: " + SQLStatement + "\n Original Exception: " + originalException;
            }
        }

    }
    

