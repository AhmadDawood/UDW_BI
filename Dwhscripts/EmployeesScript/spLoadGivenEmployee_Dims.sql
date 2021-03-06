USE [Finance]
GO
/****** Object:  StoredProcedure [dbo].[spLoadGivenEmployee_Dims]    Script Date: 9/16/2015 8:38:47 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-----------------------------------------------------------------------------------------------

-- This Stored Procedure can only be Executed when We Want to Insert a Particular(Given) Employees data into DWH.
-----------------------------------------------------------------------------------------------
ALTER PROCEDURE [dbo].[spLoadGivenEmployee_Dims]
@OLTPEmpID as int
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
			 ISNULL(CAST (@OLTPEmpID  as int), -1)  -- THE GIVEN EMPLOYEE ID WHO AUTHORIZED THE PERMISSION OF AN EXPENSE.
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

  
	  FROM HR.dbo.Employee E
	  LEFT JOIN [UDW].[dbo].DimEmployee DE 
	  ON CAST(E.EmpID  as int ) = CAST(DE.EmployeeIDAltKey  as int )
	   where CAST(E.EmpID as int )= CAST(@OLTPEmpID as int )
	   AND DE.EmployeeIDAltKey IS NULL

	   IF (@@ERROR <> 0) BEGIN
		    PRINT 'SP2: Error Occured During Data Transfer to DimEmployees!'
		
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
			 ISNULL(@OLTPEmpID , -1) 
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

			from HR.dbo.Employee  E
			left join [UDW].[dbo].DimGeography  g on
			 CAST(E.EmpID  as int) = CAST(g.GeoIDAlternateKey as int)
			where CAST(E.EmpID as int )= CAST(@OLTPEmpID as int ) 
			AND g.GeoIDAlternateKey  IS NULL


			IF (@@ERROR <> 0) BEGIN
		    PRINT 'SP2: Error Occured During Data Transfer to DimGeoraphy!'
		
			--RETURN 1
			END

---------------------------------------------------------------------------------------------

INSERT INTO [UDW].[dbo].[DimPresentJob]
			
			([EmployeeIDAltKey]
			,[Employee Type]
			,[Designation]
			,[Department]
			,[Row Created]
			,[Row Validity])

	   SELECT	
			  ISNULL(CAST (@OLTPEmpID  as int), -1)  
			 ,UPPER(ISNULL(CAST (J.[Employee Type] as nvarchar (15)) , 'UnKnown'))
			 ,UPPER(ISNULL(CAST (J.[Designation] as nvarchar(35)), 'UnKnown') )
             ,UPPER(ISNULL(CAST (J.[Department Name]  as nvarchar(35)), 'UnKnown') )
			 ,CAST(GetDate() as smalldatetime ) -- Row Created In Which DateTime.
			 ,CAST('2020-01-01' as smalldatetime ) -- Row Expired ON.
	
			FROM HR.dbo.Employee E
			LEFT JOIN [HR].[dbo].UniversityJobInfo J 
			ON CAST(E.EmpID as int ) = CAST(J.[EmpID] as int )
			LEFT JOIN [UDW].[dbo].DimEmployee DE 
			ON CAST(E.EmpID  as int ) = CAST(DE.EmployeeIDAltKey  as int )
			where CAST(E.EmpID as int )= CAST(@OLTPEmpID as int )
			AND DE.EmployeeIDAltKey IS NULL 
		
		IF (@@ERROR <> 0) BEGIN
		    PRINT 'Error Occured During Data Transfer to DimEmployment_Info!'
		
			--RETURN 1
			END


---------------------------------------------------------------------------------------
INSERT INTO [UDW].[dbo].[DimPastExperience]
		(
	   
       ExpIDAltKey
      ,[Post Held]
      ,[Organisation]
      ,[Join_Date]
      ,[End_Date]
      ,[Row_Created]
      ,[Row_Validity]
)

SELECT 

			 ISNULL(CAST (@OLTPEmpID  as int), -1)  --ISNULL(CAST(P.[Emp_ID] as int), -1)
			,ISNULL(CAST(P.[Post Held] as nvarchar(50)), 'UnKnown')
			,ISNULL(CAST(P.Organisation as nvarchar(50)), 'UnKnown')    --,ISNULL(CAST(D.[Expense Name] as nvarchar(15)) , 'UnKnown')
			,ISNULL(CAST(P.Join_Date as date),'1900-01-01')
			,ISNULL(CAST(P.End_Date as date) ,'1900-01-01')
			,CAST(GetDate() as smalldatetime ) -- Row Created In Which DateTime.
		    ,CAST('2020-01-01' as smalldatetime ) -- Row Expired ON.
		   FROM [Finance].[dbo].[SalaryExpenses] X
		   LEFT JOIN [HR].[dbo].[PastExperience] P
		   ON CAST(P.[Emp_ID] as int) = CAST((X.EmpID) as int)
		   LEFT JOIN [UDW].[dbo].[DimPastExperience] E
		   ON CAST(ExpIDAltKey as int) = CAST((X.EmpID) as int)
		   WHERE ExpIDAltKey IS NULL

		   IF (@@ERROR <> 0) BEGIN
		    PRINT 'Error Occured During Data Transfer to DimPastExperience!'
		
			--RETURN 1
			END
--------------------------------------------------------------------------------------------------------------------------

INSERT INTO [UDW].[dbo].[DimExpenseAuthorisation]
		(
	   
       [GrantedByAltKey]
      ,[Name]
      ,[Designation]
      ,[Department]
      ,[SalaryID]
      ,[OtherExpenseID]
	  ,[Row_Created]
      ,[Row_Validity]
)

	SELECT	
			  ISNULL(CAST (@OLTPEmpID  as int), -1)  
			 ,UPPER(ISNULL(CAST (E.[First Name] + ' '+ E.[Last Name] as nvarchar (50)) , 'UnKnown'))
			 ,UPPER(ISNULL(CAST (J.[Designation] as nvarchar(50)), 'UnKnown') )
             ,UPPER(ISNULL(CAST (J.[Department Name]  as nvarchar(50)), 'UnKnown') )
			 ,ISNULL(CAST(s.SalaryId as int), -1)
			 ,-1      -- OtherExpenseID NA.
			 ,CAST(GetDate() as smalldatetime ) -- Row Created In Which DateTime.
			 ,CAST('2020-01-01' as smalldatetime ) -- Row Expired ON.
			
			FROM [Finance].[dbo].[SalaryExpenses] S
			LEFT JOIN HR.dbo.Employee E
			ON CAST(E.EmpID as int ) = CAST(s.[Granting EmpID] as int )
			LEFT JOIN [HR].[dbo].UniversityJobInfo J 
			ON CAST(J.[EmpID] as int ) = CAST(s.[Granting EmpID] as int )
			LEFT JOIN [UDW].[dbo].DimExpenseAuthorisation X 
			ON CAST(X.GrantedByAltKey as int ) = CAST(s.[Granting EmpID] as int )
			where CAST(s.[Granting EmpID] as int )= CAST(@OLTPEmpID as int ) 
		    AND X.SalaryID IS NULL
		  
		  
		   IF (@@ERROR <> 0) BEGIN
		    PRINT 'Error Occured During Data Transfer to DimExpenseAuthorisation!'
		
			--RETURN 1
			END

--------------------------------------------------------------------------------------------------------------------------
END