<%@ Control Language="C#" AutoEventWireup="true" CodeBehind="StudentInfoControl.ascx.cs" Inherits="CAIRS.Controls.StudentInfoControl" %>

<div runat="server" id="divStudentInfoControl" class="panel panel-default panel-student-info">
	<div class="panel-body">
		<div class="row">

			<div class="col-xs-5">

				<asp:Image 
					ID="imgStudentPhoto" 
					CssClass="img-responsive"
					AlternateText="Unable to Display Student Photo"
                    Width="200px"
                    Height="300px"
					runat="server" />

			</div>
			

			<div class="col-xs-7">

				<strong><asp:Label runat="server" ID="lblStudentName" data_column="StudentFullName" /></strong><br />

				<asp:Label runat="server" ID="lblStudentID" data_column="StudentId" /><br />

				<asp:Label runat="server" ID="lblStudentSchool" data_column="StudentShortSchoolName" /><br />

                <asp:Label runat="server" ID="lblSecondaryEnrollment" data_column="Current_Enroll_School_Name_Display" />

				<asp:Label runat="server" ID="lblStudentStatus" data_column="StudentStatusDesc" /><br />
			
				<asp:Label runat="server" ID="lblGradeLevel" data_column="Grade" />th Grade<br />
				
				DOB: <asp:Label runat="server" ID="Label2" data_column="BirthDateFormatted" /><br />

				<asp:Label runat="server" ID="Label3" data_column="home_phone_formatted" /><br />

				Special Ed: <strong><asp:Label runat="server" ID="lblSpecialEd" data_column="SpecialEd"></asp:Label></strong><br />

				Limited Technology Coverage: <strong><asp:Label runat="server" ID="Label1" data_column="HasServiceInsuranceFee" /></strong><br />
                <asp:Label runat="server" ID="lblPaidDate" data_column="Date_LTC_Paid_Html"></asp:Label>
				<asp:Button ID="btnChangeStudent" Text="Change Student" CssClass="btn btn-primary btn-xs" OnClick="OnClickChangeStudent" runat="server" />

			</div>

		</div>
	</div>
</div>