using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;

namespace CAIRS.Exceptions
{
    public class NoPageInHistoryException : Exception
    {
        public NoPageInHistoryException()
            : base()
        {
            //
            // TODO: Add constructor logic here
            //

        }

        public NoPageInHistoryException(string message)
            : base(message)
        {
        }
    }
}