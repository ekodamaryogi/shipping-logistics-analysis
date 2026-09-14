USE LogistikDB;

SELECT TOP 10 * FROM dbo.ShippingLogistics_Cleaned;

--duplicate table for analysis
DROP TABLE IF EXISTS dbo.ShippingLogistics_Analysis;

SELECT * INTO dbo.ShippingLogistics_Analysis
FROM dbo.ShippingLogistics_Cleaned;


SELECT TOP 10 * FROM dbo.ShippingLogistics_Analysis;
