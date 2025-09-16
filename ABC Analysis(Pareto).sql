WITH ProductRevenue AS (
    SELECT 
        p.ProductID,
        p.ProductName,
        SUM(od.UnitPrice * od.Quantity * (1 - od.Discount)) AS TotalRevenue
    FROM 
        Products p
    INNER JOIN 
        [Order Details] od ON p.ProductID = od.ProductID
    GROUP BY 
        p.ProductID, p.ProductName
),
RevenueSummary AS (
    SELECT 
        ProductID,
        ProductName,
        TotalRevenue,
        SUM(TotalRevenue) OVER () AS OverallRevenue,
        (TotalRevenue / SUM(TotalRevenue) OVER ()) * 100 AS RevenuePercentage,
        SUM(TotalRevenue) OVER (ORDER BY TotalRevenue DESC) / SUM(TotalRevenue) OVER () * 100 AS CumulativePercentage
    FROM 
        ProductRevenue
)
SELECT 
    ProductID,
    ProductName,
    TotalRevenue,
    RevenuePercentage,
    CumulativePercentage,
    CASE 
        WHEN CumulativePercentage <= 80 THEN 'A'
        WHEN CumulativePercentage <= 95 THEN 'B'
        ELSE 'C'
    END AS ABCCategory
FROM 
    RevenueSummary
ORDER BY 
    TotalRevenue DESC;