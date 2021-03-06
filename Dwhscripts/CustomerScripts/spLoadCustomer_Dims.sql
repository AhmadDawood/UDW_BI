USE [Accounts]
GO
/****** Object:  StoredProcedure [dbo].[spLoadCustomer_Dims]    Script Date: 9/19/2015 6:54:53 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

-- =============================================
-- Author:		<Ahmed Dawood>
-- Create date: <16-Jul-2015>
-- Description:	<Routine to Copy Customer OBject Data(Dimensions) into DWH. 
--1- DimCustomers
--2- DimProducts
--3- DimGeography

-- =============================================

--Script for inserting new record into Customer Dimension in DWH.

ALTER Procedure [dbo].[spLoadCustomer_Dims]
AS
BEGIN
-- Code for copying New Rows into DWH.

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

		IF (@@ERROR <> 0) BEGIN
		    PRINT 'Error Occured During Data Transfer to DimCustomers!'
				RETURN 1
			END
		

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
       ,[License Type] =  ISNULL(CAST(I.[License Type] as nvarchar(25)),'Unknown')
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
		 CAST(I.ProductID as int) = CAST(P.ProductKeyAlternate as int)
		 Where P.ProductKey IS NULL

		IF (@@ERROR <> 0) BEGIN
		    PRINT 'Error Occured During Data Transfer to DimProducts!'
		
			RETURN 1
			END


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
			 UPPER (C.[State])
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
			 CAST(C.[CustomerID]  as int) = CAST(G.GeoIDAlternateKey as int) 
			where G.GeoIDAlternateKey  IS NULL

			IF (@@ERROR <> 0) BEGIN
		    PRINT 'Error Occured During Data Transfer to DimGeography!'
		
			RETURN 1
			END


print 'ALL DIMENSIONS POPULATED Successfully'

RETURN 0    -- PROCEDURE EXECUTED SUCCESSFULLY.

END
