USE LogistikDB;

SELECT TOP 10 * 
FROM dbo.ShippingLogistics;

SELECT COUNT(*) AS total_OrderID_Unique 
FROM dbo.ShippingLogistics;

SELECT COUNT(DISTINCT OrderID) AS total_rows
FROM dbo.ShippingLogistics;

-- duplicate table for cleaning and transformation
DROP TABLE IF EXISTS dbo.ShippingLogistics_Cleaning;

SELECT *
INTO dbo.ShippingLogistics_Cleaning
FROM dbo.ShippingLogistics;

SELECT TOP 10 * 
FROM dbo.ShippingLogistics_Cleaning;

SELECT COUNT(*) AS total_rows 
FROM dbo.ShippingLogistics_Cleaning;

--query to find sum of missing values in each column of the ShippingLogistics_Cleaning table (T-SQL Query)
DECLARE @sql NVARCHAR(MAX);

SELECT @sql = STRING_AGG(
    'SELECT ''' + COLUMN_NAME + ''' AS column_name,
            COUNT(*) AS missing_count
     FROM dbo.ShippingLogistics_Cleaning
     WHERE ' + QUOTENAME(COLUMN_NAME) + ' IS NULL',
    ' UNION ALL '
)
FROM INFORMATION_SCHEMA.COLUMNS
WHERE TABLE_SCHEMA = 'dbo'
  AND TABLE_NAME = 'ShippingLogistics_Cleaning';

EXEC sp_executesql @sql;

--check missing values in column DelayReason in the ShippingLogistics_Cleaning table. Why is it so extreme?
SELECT TOP 10 DelayReason
FROM dbo.ShippingLogistics_Cleaning
GROUP BY DelayReason;

--check missing values with another column which is related to DelayReason in the ShippingLogistics_Cleaning table
SELECT TOP 10 DeliveryStatus, DelayReason
FROM dbo.ShippingLogistics_Cleaning;

SELECT DeliveryStatus, COUNT(*) AS missing_count
FROM dbo.ShippingLogistics_Cleaning
WHERE DelayReason IS NULL
GROUP BY DeliveryStatus;

/*all missing values in DelayReason column are related to the DeliveryStatus column with status 'Delivered'. It is possible 
that the missing values in DelayReason are due to the fact that the delivery was successful and there was no delay, 
hence no reason for delay was recorded. So, missing values ​​can be handled using 'no delay' status imputation.*/
UPDATE dbo.ShippingLogistics_Cleaning
SET DelayReason = 'No Delay'
WHERE DelayReason IS NULL AND DeliveryStatus = 'Delivered';

SELECT COUNT(*) AS delayreason_count_missing
FROM dbo.ShippingLogistics_Cleaning
WHERE DelayReason IS NULL;

--check missing values in column DeliveryDate and ActualDeliveryDays in the ShippingLogistics_Cleaning table.
SELECT deliverydate, actualdeliverydays, deliverystatus
FROM dbo.ShippingLogistics_Cleaning
WHERE deliverydate IS NULL;

--since the item was lost, the DeliveryDate and ActualDeliveryDays fields remain NULL.
--next, we will check the missing values in the column FuelSurchargeIDR in the ShippingLogistics_Cleaning table.
SELECT TOP 10 *
FROM dbo.ShippingLogistics_Cleaning
WHERE FuelSurchargeIDR IS NULL;

--It can be seen that, based on the top 10 data entries, FuelSurchargeIDR, VehicleType, and PaymentMethod all have null values.
--check whether VehicleType, PaymentMethod, and FuelSurchargeIDR are NULL in the same row.
SELECT
    SUM(CASE WHEN VehicleType IS NULL THEN 1 ELSE 0 END) AS VehicleType_NULL,
    SUM(CASE WHEN PaymentMethod IS NULL THEN 1 ELSE 0 END) AS PaymentMethod_NULL,
    SUM(CASE WHEN FuelSurchargeIDR IS NULL THEN 1 ELSE 0 END) AS FuelSurcharge_NULL,
    SUM(CASE 
            WHEN VehicleType IS NULL
             AND PaymentMethod IS NULL
             AND FuelSurchargeIDR IS NULL
            THEN 1 ELSE 0
        END) AS Combined_NULL
FROM dbo.ShippingLogistics_Cleaning;

/*Confirmed that the missing values in VehicleType, PaymentMethod,
 and FuelSurchargeIDR occur in the same 120 rows.

 Handle missing values:
 VehicleType and PaymentMethod are categorical variables,
 so missing values are labeled as 'Unknown'.*/
UPDATE dbo.ShippingLogistics_Cleaning
SET VehicleType = 'Unknown',
    PaymentMethod = 'Unknown'
WHERE VehicleType IS NULL OR PaymentMethod IS NULL;

--for FuelSurchargeIDR, we will check the missing values based on the DeliveryStatus column, which is related to FuelSurchargeIDR.
SELECT DeliveryStatus, COUNT(*) AS missing_count
FROM dbo.ShippingLogistics_Cleaning
WHERE FuelSurchargeIDR IS NULL
GROUP BY DeliveryStatus;

--since all missing values in FuelSurchargeIDR are related to the DeliveryStatus column with status 'Delayed', 'Delivered', and 'Returned', we can handle the missing values using median imputation.
UPDATE dbo.ShippingLogistics_Cleaning
SET FuelSurchargeIDR = (
    SELECT  DISTINCT PERCENTILE_CONT(0.5) WITHIN GROUP (ORDER BY FuelSurchargeIDR) OVER()
    FROM dbo.ShippingLogistics_Cleaning
    WHERE FuelSurchargeIDR IS NOT NULL
)
WHERE FuelSurchargeIDR IS NULL;

--for CustomerRating, we will stay with NULL values since it is not a mandatory field  from customer feedback and can be left as NULL.
--next, we will check the duplicate rows in the ShippingLogistics_Cleaning table.
SELECT *
FROM dbo.ShippingLogistics_Cleaning
WHERE OrderID IN (
    SELECT OrderID
    FROM dbo.ShippingLogistics_Cleaning
    GROUP BY OrderID
    HAVING COUNT(*) > 1
)
ORDER BY OrderID;

/*Duplicate OrderID analysis confirmed that most duplicate records
contain identical values across all columns and can therefore be removed.
However, two duplicate orders have significantly different ShippingCostIDR values,
indicating potential data entry errors.
For these two cases, the record with the lower ShippingCostIDR is retained
as the more reasonable value.*/
WITH DuplicateCheck AS (
    SELECT *,
           ROW_NUMBER() OVER (
               PARTITION BY OrderID
               ORDER BY ShippingCostIDR ASC
           ) AS row_num
    FROM dbo.ShippingLogistics_Cleaning
)
DELETE FROM DuplicateCheck
WHERE row_num > 1;

SELECT OrderID, COUNT(*) AS duplicate_count
FROM dbo.ShippingLogistics_Cleaning
GROUP BY OrderID
HAVING COUNT(*) > 1;

--next, we will standardize OriginCity & DestinationCity: contains spaces and a mix of uppercase and lowercase letters, 
UPDATE dbo.ShippingLogistics_Cleaning
SET OriginCity = TRIM(UPPER(OriginCity)),
    DestinationCity = TRIM(UPPER(DestinationCity));

SELECT TOP 10 * FROM dbo.ShippingLogistics_Cleaning;

DROP TABLE IF EXISTS dbo.ShippingLogistics_Cleaned;
--create a new table with cleaned and transformed data
SELECT * INTO dbo.ShippingLogistics_Cleaned
FROM dbo.ShippingLogistics_Cleaning;