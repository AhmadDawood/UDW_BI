-- =============================================
-- Author:		<Ahmed Dawood>
-- Create date: <20-Jul-2015>
-- Description:	<Routine to Copy CustomerOBject Data(Dimensions, Fact) into DWH <SCD Type 0>.
--  Read Only DWH Implementation.
--1- DimCustomers
--2- DimProducts
--3- DimGeography
--==============================================
--4- REVENUEFACTS INSERT ROUTINE. <It POPULATES THE FACT TABLE INCREMENTALLY.
-- =============================================

USE Accounts
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

Alter Procedure spCustomerDML
AS
BEGIN
-- Code for copying New Rows into DWH.

BEGIN TRAN D1  -- Begin Inserting New Rows into Dimension Tables in DWH.

INSERT INTO [UDW].[dbo].[DimCustomers]
           ([CustomerKeyAlternate]
           ,[First Name]
           ,[Last Name]
           ,[Date of Birth]
           ,[Marital Status]
           ,[Education]
           ,[Gender]
           ,[Age]
           ,[Occupation]
           ,[Designation]
           ,[Organization]
           ,[Email Address]
           ,[Phone Number]
		   ,[Row Created] 
		   ,[Row Validity] 
		   )
     -- SELECT DATA FROM Accounts DB TBLS.
select 
       ISNULL(C.CustomerID, -1)
	  ,UPPER(ISNULL(C.[First Name], 'UnKnown'))
	  ,UPPER(ISNULL(C.[Last Name], 'UnKnown'))
	  ,ISNULL (C.[Date of Birth], '1900-01-01')
	  ,ISNULL(C.[Marital Status], 'UnKnown')
	  ,CAST(ISNULL(C.[Education], 'UnKnown') as nvarchar(50)) 
	  ,CAST(ISNULL(C.[Gender], 'UnKnown')as nvarchar(7)) 
	  ,ISNULL(C.[Age], 0)
	  ,ISNULL (C.[Occupation], 'UnKnown')
	  ,ISNULL (C.[Designation], 'UnKnown')
	  ,UPPER(ISNULL (C.[Organization],'UnKnown'))
	  ,ISNULL(C.[Email Address],  'UnKnown')
	  ,ISNULL (C.[Phone Number], 'UnKnown')
	  ,CAST(GetDate() as smalldatetime ) -- Row Created In Which DateTime.
	  ,CAST('2020-01-01' as smalldatetime ) -- Row Expired ON.

		from [Accounts].[dbo].[Customers] C 
		Left Join [UDW].[dbo].[DimCustomers] DWC ON
		CAST(C.[CustomerID] as int) = CAST(DWC.[CustomerKeyAlternate] as int)
		Where DWC.[CustomerKey] Is Null

		IF (@@ERROR <> 0) GOTO ERROR_HANDLER_D1 --IN CASE OF UN-EXPECTED ERROR WE CANCELS THE WHOLE TRANSACTION.

-------------------------------------------------------------------------------
--Extraction of New Rows into DimProducts 
-------------------------------------------------------------------------------

 INSERT INTO [UDW].[dbo].[DimProducts]
           ([ProductKeyAlternate]
           ,[Software Product Item]
           ,[License Type]
           ,[Product Description]
           ,[Category]
           ,[Product Features]
           ,[PlatForm]
           ,[Media]
           ,[Version]
           ,[Weight]
		   ,[Row Created] 
		   ,[Row Validity] 
           )
SELECT 
		[ProductKeyAlternate] = ISNULL(I.[ProductID] , 0)
	   ,[Software Product Item] = ISNULL(CAST(I.[Software Product Item] as nvarchar(50)),'Unknown')
       ,[License Type] =  ISNULL(CAST(I.[License Type] as nvarchar(10)),'Unknown')
       ,[Product Description] = ISNULL(CAST(I.[Product Description] as nvarchar(255)),'Unknown')
       ,[Product Features] =  ISNULL(CAST(I.[Product Features] as nvarchar(255)),'Unknown')
       ,[Category] = ISNULL(CAST(I.[Category] as nvarchar(50)),'Unknown')
       ,[PlatForm] = ISNULL(CAST(I.[Platform] as nvarchar(50)), 'Unknown')
       ,[Media] = ISNULL(CAST(I.[Media] as nvarchar(50)), 'Unknown')
       ,[Version] = ISNULL(CAST(I.[Version] as nvarchar(10)), 'Unknown')
       ,[Weight] = ISNULL(CAST(I.[Weight] as nvarchar(10)), 'Unknown')
       ,CAST(GetDate() as smalldatetime ) -- Row Created In Which DateTime.
	   ,CAST('2020-01-01' as smalldatetime ) -- Row Expired ON.

		FROM [Accounts].[dbo].[SoftwareItems] I
		Left Join [UDW].[dbo].[DimProducts]  P ON
		CAST(P.ProductKeyAlternate as int)  = CAST(I.ProductID as int)
		Where P.ProductKey IS NULL

		IF (@@ERROR <> 0) GOTO ERROR_HANDLER_D1 --IN CASE OF UN-EXPECTED ERROR WE CANCELS THE WHOLE TRANSACTION.
------------------------------------------------------------------------------
-- Extraction of New Rows into DimGeography.

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
			 ISNULL(C.[CustomerID], 0) 
	        ,CASE ISNULL(C.[City], 'UnKnown')
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
			  UPPER(C.[City] )
			 END
	        ,CASE ISNULL(C.[State],'UnKnown')
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
			 'UnKnown'
			End
		    ,CASE ISNULL(C.[Country], 'UnKnown')
			when 'Pak' then 'PAKISTAN'
			when 'Pakistan' then 'PAKISTAN'
			else
			 UPPER (C.[Country])
			End
			,UPPER(ISNULL(C.[Address], 'UnKnown'))
			,CAST(GetDate() as smalldatetime ) -- Row Created In Which DateTime.
		    ,CAST('2020-01-01' as smalldatetime ) -- Row Expired ON.

			from [Accounts].[dbo].[Customers] C 
			left join [UDW].[dbo].DimGeography  G on
			CAST(G.GeoIDAlternateKey as int) = CAST(C.[CustomerID]  as int)
			where G.GeoIDAlternateKey  IS NULL

			IF (@@ERROR <> 0) GOTO ERROR_HANDLER_D1 --IN CASE OF UN-EXPECTED ERROR WE CANCELS THE WHOLE TRANSACTION.
-----------------------------------------------------------------------------
	
--Script for inserting NEW ROWS into DimProducts
print 'ALL DIMENSIONS POPULATED Successfully'

COMMIT TRAN D1  --ALL CUSTOMERS DIMENSIONS POPULATED SUCCESSFULLY.
-------------------------------------------------------------------------------


-----  Start of Fact Table Insert Procedure.


BEGIN TRAN F1  -- POPULATE FACT TABLE NOW.

Declare @Rows as int --It Checks that Whether Rows were inserted into facttable or not.

-----------------------------  Fetch Fact Load history to Exculde Previously Loaded Rows. -----------------------------
Declare @Start as int

SELECT 
    @Start = DATEDIFF(SECOND,(SELECT MAX(RowLastAccessed) FROM [Accounts].[dbo].[StudentFeesDetails]), 
		(SELECT MAX(FactLastLoaded) FROM [UDW].[dbo].[FactLoadHistory] Where Fh.[FactObjectName] = 'Customer' and Fh.[Status] = 'Success' ))
	from [udw].[dbo].[FactLoadHistory] Fh
	select @Start = Isnull(@Start, '0')
	
--------------------------------------------------------------------------------------------------------------------  

  INSERT INTO [UDW].[dbo].[RevenueFacts]  
  
           ([StudentKey]
           ,[ProgramKey]
           ,[DateKey]
           ,[HourOfTheDayKey]
           ,[GeoKey]
           ,[CustomersKey]
           ,[ProductsKey]
           ,[Unit Price]
           ,[Units Sold]
           ,[Discount Allowed]
           ,[Net Amount]
           ,[StudentFees]
           ,[LateFeesAmount]
		   )
   
    Select 
			49   --Load Default DWPrimarykey 'Unknown' value from DimStudents and DimProgram
	       ,73   -- Same Goes here as above.
		   ,ISNULL(D.DateKey ,-1)  
		   ,ISNULL(H.HourKey ,-1) 
		   ,ISNULL(G.GeoKey, -1)    
		   ,ISNULL(C.CustomerKey, -1)    
		   ,ISNULL(P.ProductKey , -1)    
		   ,ISNULL(O.Amount, 0)
		   ,ISNULL(O.Quantity, 0)
		   ,ISNULL(O.[Discount Allowed], 0)
		   ,ISNULL(((O.Amount * O.Quantity) - O.[Discount Allowed]), 0)        
		   ,0       -- [Accounts].[dbo].[StudentFeesDetails]
		   ,0       -- [Accounts].[dbo].[StudentFeesDetails]
		   
		   FROM [Accounts].[dbo].[CustomerOrders]  O  
		    Inner Join [UDW].[dbo].[DimCustomers] C
		   ON CAST(C.CustomerKeyAlternate as int)  = CAST(O.FkCustomerID as int) 
		   Inner Join [UDW].[dbo].[DimProducts]  P
		   ON CAST(P.ProductKeyAlternate as int)  = CAST(O.[FkSoftProductID]  as int)  
		   Inner join [UDW].[dbo].[DimDates] D     
		   ON CAST(D.[Full Date] as date )   = CAST(O.[Payment Date]  as date)         
		   inner join [UDW].[dbo].[DimHourOFTheDay] H
		   ON CAST(H.HourKey as int) = DateName(Hour,CAST(O.[Payment Date]as datetime) ) 
		   Inner join [UDW].[dbo].[DimGeography]  G
		   ON CAST(G.GeoIDAlternateKey as int)  = CAST(O.FkCustomerID  as int)  
		  
			  Where (O.[FkCustomerID]  )IS not Null
	           And  @Start < 1

			  --------------------------------  Update the FactHistory table  ----------------------------------
			--Declare @Rows as int
			
			Select @Rows = @@ROWCOUNT 
			Select @Rows as [Rows]

			IF @Rows > 0 
			BEGIN
			INSERT INTO [UDW].[dbo].[FactLoadHistory]
				([FactLastLoaded]
				,[FactObjectName]
				,[Status])
		    VALUES
				(Getdate()
				,'Customer'
				,'Success')
			
			END
			
			ELSE
			
			BEGIN
			  SET @Rows = 0
			  Print '@Rows = 0'
			END

----------------------------------------------- THE END: FACT POPULATED ---------------------------------------------

IF (@@ERROR <> 0) GOTO ERROR_HANDLER_F1 --IN CASE OF UN-EXPECTED ERROR WE CANCELS THE WHOLE TRANSACTION.
COMMIT TRAN F1

RETURN 0    -- PROCEDURE EXECUTED SUCCESSFULLY.



ERROR_HANDLER_D1:
	IF (@@ERROR <> 0) BEGIN
	PRINT 'UN-EXPECTED PROBLEMS OCCURED DURING POPULATING CUSTOMER DIMENSION TABLES. PROCESS ABORTED!'
	ROLLBACK TRAN D1
	RETURN 1
	END

ERROR_HANDLER_F1:
IF (@@ERROR <> 0) BEGIN
	PRINT 'UN-EXPECTED PROBLEMS OCCURED DURING POPULATING REVENUEFACT TABLES. PROCESS ABORTED!'
	ROLLBACK TRAN F1
	RETURN 1
	END


END
 
GO

-- Exec spCustomerDML 
-- SELECT * FROM [UDW].[DBO].[REVENUEFACTS]
-- SELECT * FROM [UDW].[DBO].[FACTLOADHISTORY]
-- delete FROM [UDW].[DBO].[REVENUEFACTS]
-- delete  FROM [UDW].[DBO].[FACTLOADHISTORY]