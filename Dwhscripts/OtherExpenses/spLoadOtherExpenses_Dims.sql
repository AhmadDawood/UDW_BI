USE [Finance]
GO
/****** Object:  StoredProcedure [dbo].[spLoadOtherExpenses_Dims]    Script Date: 9/20/2015 12:51:55 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		<Ahmed Dawood>
-- Create date: <16-Jul-2015>
-- Description:	<Routine to Copy EmployeesOBject Data(Dimensions) into DWH.  >.
--1- DimEmployee
--2- DimGeography.
--3- DimPresentJob
--4- DimExpenseCategory.
--5- DimExpenseAuthorisation.

-- =============================================

--Script for inserting new record into OtherExpenses Dimension in DWH.

ALTER PROCEDURE [dbo].[spLoadOtherExpenses_Dims]
AS
BEGIN

INSERT INTO [UDW].[dbo].[DimEmployee]

           ([EmployeeIDAltKey]
           ,[Employee Name]
           ,[Date of Birth]
           ,[Marital Status]
           ,[Education]
           ,[Professional Qualifications]
           ,[Gender]
           ,[Age]
           ,[Organization]
           ,[Phone Number]
           ,[Email Address]
           ,[Row Created]
		   ,[Row Validity]
		   )
      -- SELECT DATA FROM FINANCE DB TBLS.
	  
	  SELECT 
			 ISNULL(CAST (O.[EmpID] as int), -1)
			,UPPER(ISNULL(CAST ((E.[First Name] + ' ' + E.[Last Name] ) as nvarchar(50)), 'UnKnown'))
			,ISNULL(CAST(E.[Date of Birth] as date), '1900-01-01')
			,CASE ISNULL(CAST(E.[Marital Status] as nvarchar(15)), 'UnKnown')
			When 'single' then 'SINGLE'
			When 'married' then 'MARRIED'
			When 'divorced' then 'DIVORCED'
			When 'seperated' then 'SEPERATED'
			ELSE
			 UPPER(E.[Marital Status]) 
			END
		    ,CASE CAST(ISNULL(E.[Highest Education], 'UnKnown') as nvarchar(30))  --eDUCATION
		    When 'F.S.C' then 'FSC'
			When 'fsc' then 'FSC'
			When 'Fsc' then 'FSC'
			When 'F.A' then 'FA'
			When 'fa' then 'FA'
			When 'icom' then 'ICOM'
			When 'I-com' then 'ICOM'
			when 'dcom' then 'DCOM'
			when 'D com' then 'DCOM'
			when 'B.A' then 'BA'
			When 'ba' then 'BA'
			when 'Ba' then 'BA'
			when 'Bsc' then 'BSC'
			when 'B.S.C' then 'BSC'
			when 'B.Com' then 'BCOM'
			when 'B.B.A' then 'BBA'
			when 'Bsc Hons' then 'BSC HONS'
			when 'BsIT' then 'BSIT'
			when 'M.A' then 'MA'
			when 'M.com' then 'MCOM'
			when 'M.s.c' then 'MSC'
			when 'M.c.s' then 'MCS'
			else
			 UPPER(E.[Highest Education] )
			End 
			,ISNULL(CAST(E.[Professional Qualifications] as nvarchar(50)), 'UnKnown')
			,CASE CAST(ISNULL(E.[Gender], 'UnKnown') as nvarchar(10))
			 When 'male' then 'MALE'
			 When 'female' then 'FEMALE'
			 else
			  UPPER(E.[Gender])
			 END
			,ISNULL(CAST(E.[Age] as int), 0)
			,ISNULL(CAST(E.[Organization] as nvarchar(50)), 'UnKnown')
			,ISNULL(CAST(E.[Phone Number] as nvarchar(30)), 'UnKnown')
			,ISNULL(CAST(E.[Email Address] as nvarchar (30)), 'UnKnown')
			,CAST(GetDate() as smalldatetime ) -- Row Created In Which DateTime.
			,CAST('2020-01-01' as smalldatetime ) -- Row Expired ON.

  
	  FROM Finance.dbo.OtherExpenses O
	  LEFT JOIN HR.dbo.Employee E
	  ON CAST(E.EmpID  as int ) = CAST(O.EmpID  as int )
	  LEFT JOIN [UDW].[dbo].DimEmployee DE 
	  ON  CAST(DE.EmployeeIDAltKey  as int ) = CAST(O.EmpID  as int ) 
	  	   where  DE.EmployeeIDAltKey IS NULL

	   IF (@@ERROR <> 0) BEGIN
		    PRINT 'Error Occured During Data Transfer to DimEmployee_OtherExpenses!'
		
			--RETURN 1
			END


------------------------------------------------------------------------------------

--script to insert New Rows in DimGeography DWH.

INSERT INTO [UDW].[dbo].[DimGeography]
           ([GeoIDAlternateKey]
		   ,[City]
           ,[State]
           ,[Country]
           ,[Address]
		   ,[Row Created]
		   ,[Row Validity]
		   )
		        
	 Select 
			 ISNULL(O.EmpID, -1) 
	        ,CASE ISNULL(E.[City], 'UnKnown')
			 when 'KHI' then 'KARACHI'
			 when 'Karachi' then 'KARACHI'
			 When 'LHR' then 'LAHORE'
			 when 'Lahore' then 'LAHORE'
			 When 'FSD' then 'FAISALABAD'
			 When 'Faisalabad' then 'FAISALABAD'
			 When 'ISB' then 'ISLAMABAD'
			 When 'Islamabad' then 'ISLAMABAD'
			 When 'PSW' then 'PESHAWAR'
			 When 'Peshawar' then 'PESHAWAR'
			 When 'Qty' then 'Quetta'
			 When 'Quetta' then 'QUETTA'
			 When 'MLT' then 'MULTAN'
			 When 'Multan' then 'MULTAN'
			 ELSE
			  UPPER(E.City )
			 END
	        ,CASE ISNULL(E.[State],'UnKnown')
			When 'Punjab' then 'PUNJAB'
			when 'Sindh' then 'SINDH'
			when 'Balochistan' then 'BALOCHISTAN'
			when 'Sarhad' then 'KHYBER PAKTHUNKWHA'
			when 'KPK' then 'KHYBER PAKTHUNKWHA'
			when 'Azad Kashmir' then 'AZAD KASHMIR'
			when 'Gilgit-Baltistan' then 'GILGIT-BALTISTAN'
			when 'FATA' then 'FEDERALLY ADMINISTERED TRIBAL AREAS'
			when 'Islamabad' then 'ISLAMABAD CAPITAL TERRITORY'
			else
			 UPPER(E.State)
			End
		    ,CASE ISNULL(E.[Country], 'UnKnown')
			when 'Pak' then 'PAKISTAN'
			when 'Pakistan' then 'PAKISTAN'
			else
			 UPPER (E.[Country])
			End
			,UPPER(ISNULL(E.[Address], 'UnKnown'))
			,CAST(GetDate() as smalldatetime ) -- Row Created In Which DateTime.
		    ,CAST('2020-01-01' as smalldatetime ) -- Row Expired ON.

			from Finance.dbo.OtherExpenses O
			LEFT JOIN HR.dbo.Employee  E
			ON CAST(E.EmpID  as int) = CAST(O.EmpID as int)
			left join [UDW].[dbo].DimGeography  g 
			ON CAST(g.GeoIDAlternateKey as int) = CAST(O.EmpID  as int)
			where g.GeoIDAlternateKey  IS NULL


			IF (@@ERROR <> 0) BEGIN
		    PRINT 'Error Occured During Data Transfer to DimGeoraphy_OtherExpenses!'
		
			--RETURN 1
			END

-------------------------------------------------------------------------------------

INSERT INTO [UDW].[dbo].[DimPresentJob]
			
			([EmployeeIDAltKey]
			,[Employee Type]
			,[Designation]
			,[Department]
			,[Row Created]
			,[Row Validity])

	   SELECT	
			  ISNULL(CAST (O.EmpID as int), -1)  
			 ,UPPER(ISNULL(CAST (J.[Employee Type] as nvarchar (15)) , 'UnKnown'))
			 ,UPPER(ISNULL(CAST (J.[Designation] as nvarchar(35)), 'UnKnown') )
             ,UPPER(ISNULL(CAST (J.[Department Name]  as nvarchar(35)), 'UnKnown') )
			 ,CAST(GetDate() as smalldatetime ) -- Row Created In Which DateTime.
			 ,CAST('2020-01-01' as smalldatetime ) -- Row Expired ON.
	
		FROM [Finance].[dbo].[OtherExpenses] O
		LEFT JOIN [HR].[dbo].UniversityJobInfo J 
		ON CAST(J.[EmpID] as int ) = CAST(O.EmpID as int ) 
		LEFT JOIN [UDW].[dbo].DimPresentJob P 
		ON CAST(P.EmployeeIDAltKey  as int ) = CAST(O.EmpID  as int ) 
	    where  P.EmployeeIDAltKey IS NULL
 
		IF (@@ERROR <> 0) BEGIN
		    PRINT 'Error Occured During Data Transfer to DimPresentJob in OtherExpensesDims!'
		
			--RETURN 1
			END


 ---------------------------------------------------------------------------------------------------------


INSERT INTO [UDW].[dbo].[DimExpenseCategory]
           ([ExpensesAltKey]
           ,[ExpenseName]
		   ,[ExpenseType]
           ,[Row Created]
           ,[Row Validity])
	 SELECT
	       ISNULL(CAST(O.ExpDescID   as int), -1)  --ONLY SALARY EXPENSES.
		   ,CASE ISNULL(UPPER(CAST(D.[Expense Name] as nvarchar(30))) , 'UnKnown')
		   When 'salary' then 'SALARY'
		   when 'Salary' then 'SALARY'
		   when 'Utility Bill' then 'UTILITY BILL'
		   when 'Electricity Bill' then 'ELECTRICITY BILL'
		   when 'Gas Bill' then 'GAS BILL'
		   when 'Repair and Maintenance' then 'REPAIR AND MAINTENANCE'
		   when 'Misc.' then 'MISCELLANEOUS'
		   ELSE
		   UPPER (D.[Expense Name])
		   END
		   ,CASE ISNULL(CAST(D.[ExpenseType] as nvarchar(20)) , 'UnKnown')
		   When 'salary' then 'SalaryExpense'
		   when 'Salary' then 'SalaryExpense'
		   when 'Utility Bill' then 'OTHER'
		   when 'Electricity Bill' then 'OTHER'
		   when 'Wapda Bill' then 'OTHER'
		   when 'Gas Bill' then 'OTHER'
		   when 'Sui Gas Bill' then 'OTHER'
		   when 'Repair and Maintenance' then 'OTHER'
		   when 'TelePhone Bill' then 'OTHER'
		   ELSE
		   UPPER (D.[ExpenseType])
		   END
		   
		   ,CAST(GetDate() as smalldatetime ) -- Row Created In Which DateTime.
		   ,CAST('2020-01-01' as smalldatetime ) -- Row Expired ON.

		   FROM [Finance].[dbo].[OtherExpenses]   O 
		   LEFT JOIN [Finance].[dbo].[ExpensesDescription] D
		   ON CAST(D.[ExpenseDescId] as int ) = CAST(O.[ExpDescID]  as int )
		   LEFT JOIN [UDW].[dbo].[DimExpenseCategory] DE
		   ON CAST(DE.[ExpensesAltKey] as int ) = CAST(O.ExpDescID  as int ) 
		   WHERE DE.ExpensesAltKey IS NULL
		    --Where O.ExpDescID IS NULL

			
		   
		   IF (@@ERROR <> 0) BEGIN
		    PRINT 'Error Occured During Data Transfer to DimExpenseCategory!'
		
			--RETURN 1
			END

---------------------------------------------------------------------------------------

INSERT INTO UDW.dbo.[DimExpenseAuthorisation]
      (
--	   [ExpAuthorKey]
       [GrantedByAltKey]
      ,[Name]
      ,[Designation]
      ,[Row_Created]
      ,[Row_Validity]
	  )

	SELECT 
	        ISNULL(CAST(O.AuthorisedByID as int), -1)
		   ,ISNULL(CAST(E.[First Name] + ' ' + E.[Last Name] as nvarchar(50)), 'UnKnown')
		   ,ISNULL(CAST(E.Designation as nvarchar(50)), 'UnKnown')
		   ,CAST(GetDate() as smalldatetime ) -- Row Created In Which DateTime.
		   ,CAST('2020-01-01' as smalldatetime ) -- Row Expired ON.

	  From [Finance].[dbo].[OtherExpenses] O
	  LEFT Join [HR].[dbo].Employee E
	  ON CAST(E.EmpID as int) = CAST(O.AuthorisedByID as int)
	  LEFT JOIN [UDW].[dbo].[DimExpenseAuthorisation] A
	  ON CAST(A.[GrantedByAltKey] as int) = CAST(O.AuthorisedByID as int)
	  Where A.GrantedByAltKey  IS NULL
	  
	  IF (@@ERROR <> 0) BEGIN
		    PRINT 'Error Occured During Data Transfer to DimExpenseAuthorisation!'
		
			--RETURN 1
	 END
	 


---------------------------------------------------------------------------------------
/*
INSERT INTO [UDW].[dbo].[DimPastExperience]
		(
	   
       [EmpIDAltKey]
      ,[Post Held]
      ,[Organisation]
      ,[Join_Date]
      ,[End_Date]
      ,[Row_Created]
      ,[Row_Validity]
)

SELECT 

			 ISNULL(CAST(O.EmpID as int), -1)
			,ISNULL(CAST(P.[Post Held] as nvarchar(50)), 'UnKnown')
			,ISNULL(CAST(P.Organisation as nvarchar(50)), 'UnKnown')    --,ISNULL(CAST(D.[Expense Name] as nvarchar(15)) , 'UnKnown')
			,ISNULL(CAST(P.Join_Date as date),'1900-01-01')
			,ISNULL(CAST(P.End_Date as date) ,'1900-01-01')
			,CAST(GetDate() as smalldatetime ) -- Row Created In Which DateTime.
		    ,CAST('2020-01-01' as smalldatetime ) -- Row Expired ON. {No need because data rewritten at each transaction}
		   
		   FROM [Finance].[dbo].[OtherExpenses] O
		   INNER JOIN [HR].[dbo].[PastExperience] P
		   ON CAST(P.Emp_ID as int)  = CAST(O.EmpID as int)
		   LEFT JOIN [UDW].[dbo].[DimPastExperience] E
		   ON  CAST(E.EmpIDAltKey as int) = CAST(O.EmpID as int)
		   WHERE E.EmpIDAltKey IS NULL

		   IF (@@ERROR <> 0) BEGIN
		    PRINT 'Error Occured During Data Transfer to DimPastExperience!'
		
			--RETURN 1
			END

*/
END
