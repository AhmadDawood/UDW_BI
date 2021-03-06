USE [Accounts]
GO
/****** Object:  StoredProcedure [dbo].[spLoadStudent_Facts]    Script Date: 8/13/2015 12:15:15 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

-- =============================================
-- Author:		<Ahmed Dawood>
-- Create date: <24-Jul-2015>
-- Description:	<Routine to Copy StudentOBject Data(Fact) into DWH. >
--1- RevenueFacts  

-- =============================================



ALTER Procedure [dbo].[spLoadStudent_Facts]
AS
BEGIN

BEGIN TRAN F1

INSERT INTO [UDW].[dbo].[RevenueFacts]
           ([StudentKey]
           ,[ProgramKey]
           ,[DateKey]
           ,[HourOfTheDayKey]
           ,[GeoKey]
           ,[CustomersKey]
           ,[ProductsKey]
           ,[OrderID]  
		   ,[FeesVoucherID] 
		   ,[Unit Price]
           ,[Units Sold]
           ,[Discount Allowed]
           ,[Net Amount]
           ,[StudentFees]
           ,[LateFeesAmount]
		   )
     
    Select 
			ISNULL(S.StudentKey , -1) 
	       ,ISNULL(PG.ProgramKey, -1)
		   ,ISNULL(D.DateKey ,-1)  --Datekey       
		   ,ISNULL(H.HourKey ,-1)  --HourKey 
		   ,ISNULL(G.GeoKey, -1)    --GeoKey
		   ,-1 --ISNULL(C.CustomerKey, -1)           
		   ,-1 --ISNULL(P.ProductKey , -1)           
		   ,-1 --ISNULL(ODERIDKEY, -1)
		   ,ISNULL(SD.VoucherID, -1) --DimFeeVoucherKey
		   ,0					--  No Corresponding field in from Accounts SoftwareRevenue Table
		   ,0					--  No Corresponding field in from Accounts SoftwareRevenue Table
		   ,0					--  No Corresponding field in from Accounts SoftwareRevenue Table
		   ,ISNULL(SD.Amount + SD.LateFees, 0)        -- --  Calculate the Field.
		   ,ISNULL(SD.Amount, 0)       -- [Accounts].[dbo].[StudentFeesDetails]
		   ,ISNULL(SD.LateFees, 0)    -- [Accounts].[dbo].[StudentFeesDetails]
		   
		   FROM [Accounts].[dbo].StudentFeesDetails SD   
		    LEFT JOIN [UDW].[dbo].[DimStudents] S 
		   ON  CAST(SD.RollNumber as int) = CAST(S.StudentIDAlternateKey as int) 
		    LEFT JOIN [UDW].[dbo].[DimPrograms] PG
		   ON  CAST(SD.RollNumber as int)  = CAST(PG.StudentKeyAlternate as int)
		   LEFT JOIN [UDW].[dbo].[DimDates] D     
		   ON CAST(SD.[Payment Date] as date) = CAST(D.[Full Date] as date )   
		    LEFT JOIN [UDW].[dbo].[DimHourOFTheDay] H
		   ON  DateName(Hour,SD.[Payment Date]) = CAST (H.HourKey as int)
			LEFT JOIN [UDW].[dbo].[DimGeography]  G
		   ON  CAST(SD.RollNumber as int) = CAST(G.GeoIDAlternateKey as int)  
		    LEFT JOIN [UDW].[DBO].RevenueFacts RF
		   ON  CAST (SD.VoucherID as int) = CAST(RF.FeesVoucherID  as int) 
			 WHERE RF.FeesVoucherID  IS NULL
			  

 IF (@@ERROR <> 0) GOTO ERROR_HANDLER_F1 --IN CASE OF UN-EXPECTED ERROR WE CANCELS THE WHOLE TRANSACTION.

COMMIT TRAN F1

Print 'LoadStudentFacts Executed Successfully'

RETURN 0



ERROR_HANDLER_F1:

IF (@@ERROR <> 0) BEGIN
	PRINT 'UN-EXPECTED PROBLEMS OCCURED DURING POPULATING Student Revenue FACT TABLE. PROCESS ABORTED!'
	ROLLBACK TRAN F1
	RETURN 1
	END

--------------------- The End Student Part   -----------------------------------------------------------------------
END
