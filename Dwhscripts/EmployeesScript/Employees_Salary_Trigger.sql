USE [Finance]
GO
/****** Object:  Trigger [dbo].[Employee_Salary_Trigger]    Script Date: 9/19/2015 6:12:11 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
ALTER TRIGGER [dbo].[Employee_Salary_Trigger]
   ON  [dbo].[SalaryExpenses]
   AFTER  INSERT
AS 
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;
		
		--DECLARE @Authorised_Person_ID as int
		--SELECT @Authorised_Person_ID =  inserted.[Granting EmpID] from inserted
		--Print @Authorised_Person_ID
		
		Exec dbo.spLoadEmployees_Dims   --STORE PROCEDURE CALL TO PROCESS Employee Dimensions.
		Exec dbo.spLoadEmployee_Facts  --Stored Procedure Call to PRocess Employee Facts.
		
	print 'Employee_Salary_Trigger Fired Successfully!'
	END
