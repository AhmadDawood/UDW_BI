USE [Finance]
GO
/****** Object:  StoredProcedure [dbo].[spLoadOtherExpenses_Facts]    Script Date: 9/20/2015 11:05:26 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

-- =============================================
-- Author:		<Ahmed Dawood>
-- Create date: <26-Jul-2015>
-- Description:	<Routine to Copy Other Expenses (Facts) into DWH. >
--1- ExpenseFacts (Other)

-- =============================================



ALTER Procedure [dbo].[spLoadOtherExpenses_Facts]
AS
BEGIN

BEGIN TRAN F1

INSERT INTO [UDW].[dbo].[ExpenseFacts]
           ([ExpensesTypeKey]
           ,[EmployeeKey]      -- Expense Request Made By Employee.
           ,[PresentJobKey]
		   ,[ExpAuthorityKey]  -- Granted by
           ,[DateKey]
           ,[HourOfTheDayKey]
           ,[GeoKey]
		   ,[SalaryID]
		   ,[ExpenseID]
           ,[Basic Pay]
           ,[Medical Allowance]
           ,[Conveyance Allowance]
           ,[House Rent]
           ,[Provident Fund]
           ,[Tax Amount]
           ,[Net Salary]
           ,[Expense Amount])
     
    Select 
			ISNULL(DE.ExpenseKey, -1) 
	       ,ISNULL(DEmp.EmployeeKey, -1)  -- REQUEST MADE BY EMPLOYEE.
		   ,ISNULL(DP.[EmpInfoKey], -1)
		   ,ISNULL(A.ExpAuthorKey, -1) 
		   ,ISNULL(D.DateKey , -1)
		   ,ISNULL(H.HourKey ,-1)  --HourKey 
		   ,ISNULL(G.GeoKey, -1)    --GeoKey
		   ,-1		--NO SalaryID
		   ,ISNULL(CAST(O.ExpenseID as int ), -1)	--OtherExpenseID 
		   ,0    -- Basic Pay
		   ,0    -- Medical Allowance
		   ,0    -- Conveyance Allowance
		   ,0    -- HOUSE RENT
		   ,0    -- PROVIDENT FUND
		   ,0    -- TAX Amount
		   ,0    -- NET SALARY.
		   ,ISNULL(CAST(O.Amount as money), 0)   -- Other Expense Type Amount
		   
		    FROM [Finance].[dbo].[OtherExpenses]  O
		    LEFT JOIN [UDW].[dbo].[DimExpenseCategory] DE
			ON CAST(O.ExpDescID as int ) = CAST(DE.ExpensesAltKey  as int )   
		    LEFT JOIN [UDW].[dbo].[DimEmployee] DEmp						-- Requesting EmployeeID
		    ON   CAST(DEmp.EmployeeIDAltKey  as int) = CAST(O.EmpID as int)
			LEFT JOIN [UDW].[dbo].[DimPresentJob] DP 
		    ON   CAST(DP.EmployeeIDAltKey  as int ) = CAST(O.EmpID  as int)
			LEFT JOIN [UDW].[dbo].[DimExpenseAuthorisation] A
			ON CAST(A.GrantedByAltKey as int) = CAST(O.AuthorisedByID as int)
		    LEFT JOIN [UDW].[dbo].[DimDates] D     
		    ON CAST(O.[Expense Incurred On] as date) = CAST(D.[Full Date] as date )   
		    LEFT JOIN [UDW].[dbo].[DimHourOFTheDay] H
		    ON  DateName(Hour,O.[Expense Incurred On]) = CAST (H.HourKey as int)
			LEFT JOIN [UDW].[dbo].[DimGeography]  G
		    ON  CAST(G.GeoIDAlternateKey  as int)  = CAST(O.EmpID as int)
			LEFT JOIN [UDW].[dbo].ExpenseFacts  EF
		    ON  CAST (O.ExpenseID as int) = CAST(EF.ExpenseID   as int) 
			
			 WHERE EF.ExpenseID  IS NULL
			  

 IF (@@ERROR <> 0) GOTO ERROR_HANDLER_F1 --IN CASE OF UN-EXPECTED ERROR WE CANCELS THE WHOLE TRANSACTION.

COMMIT TRAN F1

Print 'Load Other Expenses Facts Executed Successfully!'

RETURN 0



ERROR_HANDLER_F1:

IF (@@ERROR <> 0) BEGIN
	PRINT 'UN-EXPECTED PROBLEMS OCCURED DURING POPULATING Other Expenses FACT TABLE. PROCESS ABORTED!'
	ROLLBACK TRAN F1
	RETURN 1
	END

--------------------- The End Employees Salary Facts Part   --------------------------------------------------
END
