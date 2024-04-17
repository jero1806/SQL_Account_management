USE invest;

-- We'll start by getting to know our client

SELECT hc.ticker
	FROM customer_details cd -- Client info
	LEFT JOIN account_dim ad 
		ON cd.customer_id = ad.client_id -- account id
	INNER JOIN holdings_current hc
		USING(account_id)
	WHERE ad.client_id = 148
	ORDER BY hc.ticker
;

-- Looking at distribution of tickers in asset classes
SELECT hc.account_id, sm.major_asset_class, COUNT(ticker)
FROM holdings_current hc
LEFT JOIN security_masterlist sm
	USING(ticker)
WHERE hc.account_id IN('28','2801','2802')
GROUP BY hc.account_id, sm.major_asset_class
;




SELECT cd.full_name, ad.account_id, FORMAT(SUM(hc.value*hc.quantity),2) AS AUM, COUNT(hc.ticker), ad.acct_open_date
FROM customer_details cd -- Client info
LEFT JOIN account_dim ad 
	ON cd.customer_id = ad.client_id -- account id
INNER JOIN holdings_current hc
	USING(account_id)
WHERE ad.client_id = 148
GROUP BY ad.account_id
ORDER BY cd.full_name, SUM(hc.value*hc.quantity)
;


SELECT cd.full_name,  FORMAT(SUM(hc.value*hc.quantity),2) AS AUM, COUNT(DISTINCT hc.ticker)
FROM customer_details cd -- Client info
LEFT JOIN account_dim ad 
	ON cd.customer_id = ad.client_id -- account id
INNER JOIN holdings_current hc
	USING(account_id)
WHERE ad.client_id = 148
GROUP BY cd.full_name
ORDER BY cd.full_name, SUM(hc.value*hc.quantity)
;



SELECT cd.full_name, ad.account_id,
 hc.ticker,
 sm.major_asset_class,
 sm.minor_asset_class,
 FORMAT((hc.quantity*hc.value),'NO') AS tot_invested
FROM customer_details cd
LEFT JOIN account_dim ad 
	ON cd.customer_id = ad.client_id
INNER JOIN holdings_current hc
	USING(account_id)
LEFT JOIN security_masterlist sm
	USING(ticker)
WHERE ad.client_id = 148;



/*
AUM per major asset class in account number 28
*/
SELECT  FORMAT(SUM(hc.value*hc.quantity),2) AS AUM, sm.major_asset_class
FROM customer_details cd -- Client info
LEFT JOIN account_dim ad 
	ON cd.customer_id = ad.client_id -- account id
INNER JOIN holdings_current hc
	USING(account_id)
LEFT JOIN security_masterlist sm
	USING(ticker)
WHERE ad.client_id = 148 AND ad.account_id = 28
GROUP BY sm.major_asset_class
ORDER BY SUM(hc.value*hc.quantity) DESC
;

/*
AUM per major asset class in account number 2801
*/
SELECT  FORMAT(SUM(hc.value*hc.quantity),2) AS AUM, sm.major_asset_class
FROM customer_details cd -- Client info
LEFT JOIN account_dim ad 
	ON cd.customer_id = ad.client_id -- account id
INNER JOIN holdings_current hc
	USING(account_id)
LEFT JOIN security_masterlist sm
	USING(ticker)
WHERE ad.client_id = 148 AND ad.account_id = 2801
GROUP BY sm.major_asset_class
ORDER BY SUM(hc.value*hc.quantity) DESC
;



/*
AUM per major asset class in account number 2802
*/
SELECT  FORMAT(SUM(hc.value*hc.quantity),2) AS AUM, 
	CASE
		WHEN sm.`major_asset_class` = 'equty' THEN 'equity'
		WHEN sm.`major_asset_class` IN ('fixed income corporate','fixed_income') THEN 'fixed income'
		ELSE sm.`major_asset_class` END AS `major_asset_class_new`
FROM customer_details cd -- Client info
LEFT JOIN account_dim ad 
	ON cd.customer_id = ad.client_id -- account id
INNER JOIN holdings_current hc
	USING(account_id)
LEFT JOIN security_masterlist sm
	USING(ticker)
WHERE ad.client_id = 148 AND ad.account_id = 2802
GROUP BY major_asset_class_new
ORDER BY SUM(hc.value*hc.quantity) DESC
;



SELECT  FORMAT(SUM(hc.value*hc.quantity),2) AS AUM, 
	CASE
		WHEN sm.`major_asset_class` = 'equty' THEN 'equity'
		WHEN sm.`major_asset_class` IN ('fixed income corporate','fixed_income') THEN 'fixed income'
		ELSE sm.`major_asset_class` END AS `major_asset_class_new`
FROM customer_details cd -- Client info
LEFT JOIN account_dim ad 
	ON cd.customer_id = ad.client_id -- account id
INNER JOIN holdings_current hc
	USING(account_id)
LEFT JOIN security_masterlist sm
	USING(ticker)
WHERE ad.client_id = 148 AND ad.account_id = 2802
GROUP BY major_asset_class_new
ORDER BY SUM(hc.value*hc.quantity) DESC
;


SELECT ticker, date, value, price_type
FROM pricing_daily
WHERE price_type = 'adjusted' 
	AND ticker IN
			(
			SELECT hc.ticker
			FROM customer_details cd -- Client info
			LEFT JOIN account_dim ad 
				ON cd.customer_id = ad.client_id -- account id
			INNER JOIN holdings_current hc
				USING(account_id)
			WHERE ad.client_id = 148
			ORDER BY hc.ticker
			)
	AND date >
			(
			SELECT DATE_SUB(MAX(`date`), INTERVAL 24 MONTH) AS ResultDate
			FROM pricing_daily
            )
;

SELECT ticker,
		date,
        value,
        price_type,
        LAG(`value`,250)OVER  -- First lag will get us the "P0" of 12M ago
			(
            PARTITION BY `ticker` 
			ORDER BY `date` 
			) AS "P-12M",
            
            LAG(`value`, 375)OVER -- Second lag will get us the "P0" of 18M ago
			(
            PARTITION BY `ticker` 
			ORDER BY `date` 
			) AS "P-18M",
            
            LAG(`value`,500)OVER -- Third lag will get us the "P0" of 24M ago
			(
            PARTITION BY `ticker` 
			ORDER BY `date` 
			) AS "P-24M"
FROM pricing_daily
WHERE price_type = 'adjusted' 
	AND ticker IN
			(
			SELECT hc.ticker
			FROM customer_details cd -- Client info
			LEFT JOIN account_dim ad 
				ON cd.customer_id = ad.client_id -- account id
			INNER JOIN holdings_current hc
				USING(account_id)
			WHERE ad.client_id = 148
			ORDER BY hc.ticker
			)
	AND date >
			(
			SELECT DATE_SUB(MAX(`date`), INTERVAL 24 MONTH) AS ResultDate
			FROM pricing_daily
            )
;


-- CREATE VIEW jossa_view AS 
SELECT ticker,
		date,
        value,
        price_type,
        LAG(`value`,250)OVER  -- First lag will get us the "P0" of 12M ago
			(
            PARTITION BY `ticker` 
			ORDER BY `date` 
			) AS "P-12M",
            
		LAG(`value`, 375)OVER -- Second lag will get us the "P0" of 18M ago
			(
            PARTITION BY `ticker` 
			ORDER BY `date` 
			) AS "P-18M",
            
		LAG(`value`,500)OVER -- Third lag will get us the "P0" of 24M ago
			(
            PARTITION BY `ticker` 
			ORDER BY `date` 
			) AS "P-24M"
FROM pricing_daily
WHERE price_type = 'adjusted' 
	AND ticker IN -- subquery to filter for only our client's tickers
			(
			SELECT hc.ticker
			FROM customer_details cd 
			LEFT JOIN account_dim ad 
				ON cd.customer_id = ad.client_id 
			INNER JOIN holdings_current hc
				USING(account_id)
			WHERE ad.client_id = 148 
			ORDER BY hc.ticker
			)
	AND date > -- This filters data for the Max date, minus 24 calendar days, to give us a few days to play with. *Not 500 lag*
			(
			SELECT DATE_SUB(MAX(`date`), INTERVAL 24 MONTH) AS ResultDate
			FROM pricing_daily
            )
            ;
            

SELECT 
	z.date,
	z.ticker,
    z.value,
 FORMAT(((z.`value`- z.P0_1D)/z.P0_1D)*100,2) AS "DailyReturn",
 FORMAT(((z.`value`- z.P0_12M)/z.P0_12M)*100,2) AS "12MReturn",
 FORMAT(((z.`value`- z.P0_18M)/z.P0_18M)*100,2) AS "18MReturn",
 FORMAT(((z.`value`- z.P0_24M)/z.P0_24M)*100,2) AS "24MReturn"
FROM (SELECT ticker,
		date,
        value,
        price_type,
        LAG(`value`,1)OVER  -- This lag will get us the "P0" of 1Day
			(
            PARTITION BY `ticker` 
			ORDER BY `date` 
			) AS "P0_1D",
        LAG(`value`,250)OVER  -- First lag will get us the "P0" of 12M ago
			(
            PARTITION BY `ticker` 
			ORDER BY `date` 
			) AS "P0_12M",
            
		LAG(`value`, 375)OVER -- Second lag will get us the "P0" of 18M ago
			(
            PARTITION BY `ticker` 
			ORDER BY `date` 
			) AS "P0_18M",
            
		LAG(`value`,500)OVER -- Third lag will get us the "P0" of 24M ago
			(
            PARTITION BY `ticker` 
			ORDER BY `date` 
			) AS "P0_24M"
FROM pricing_daily
WHERE price_type = 'adjusted' 
	AND ticker IN -- subquery to filter for only our client's tickers
			(
			SELECT hc.ticker
			FROM customer_details cd 
			LEFT JOIN account_dim ad 
				ON cd.customer_id = ad.client_id 
			INNER JOIN holdings_current hc
				USING(account_id)
			WHERE ad.client_id = 148 
			ORDER BY hc.ticker
			)
	AND date > -- This filters data for the Max date, minus 24 calendar days, to give us a few days to play with. *Not 500 lag*
			(
			SELECT DATE_SUB(MAX(`date`), INTERVAL 24 MONTH) AS ResultDate
			FROM pricing_daily
            )
            ) z
ORDER BY `date` DESC , `12MReturn` DESC
            ;
  
/*
This View will create a table with the last two years Adjusted Prices
of the securities in all of our client's portfolio.
Only 67 different securities will show up, with the change in daily, yearly, 18M, and 24M prices
*/  
CREATE VIEW jossa AS
SELECT ticker,
		date,
        value,
        price_type,
        LAG(`value`,1)OVER  -- This lag will get us the "P0" of 1Day
			(
            PARTITION BY `ticker` 
			ORDER BY `date` 
			) AS "P0_1D",
        LAG(`value`,250)OVER  -- First lag will get us the "P0" of 12M ago
			(
            PARTITION BY `ticker` 
			ORDER BY `date` 
			) AS "P0_12M",
            
		LAG(`value`, 375)OVER -- Second lag will get us the "P0" of 18M ago
			(
            PARTITION BY `ticker` 
			ORDER BY `date` 
			) AS "P0_18M",
            
		LAG(`value`,500)OVER -- Third lag will get us the "P0" of 24M ago
			(
            PARTITION BY `ticker` 
			ORDER BY `date` 
			) AS "P0_24M"
FROM pricing_daily
WHERE price_type = 'adjusted' 
	AND ticker IN -- subquery to filter for only our client's tickers
			(
			SELECT hc.ticker
			FROM customer_details cd 
			LEFT JOIN account_dim ad 
				ON cd.customer_id = ad.client_id 
			INNER JOIN holdings_current hc
				USING(account_id)
			WHERE ad.client_id = 148 
			ORDER BY hc.ticker
			)
	AND date > -- This filters data for the Max date, minus 24 calendar days, to give us a few days to play with. *Not 500 lag*
			(
			SELECT DATE_SUB(MAX(`date`), INTERVAL 24 MONTH) AS ResultDate
			FROM pricing_daily
            )
           ;
           
-- calculating returns for each ticker, showing the price used to calculate the return          
SELECT 
	`date`,
    ticker,
    `value`,
    P0_1D,
    FORMAT(((`value`- P0_1D)/P0_1D)*100,2) AS "DailyReturn",
    P0_12M,
	ROUND(((`value`- P0_12M)/P0_12M)*100,2) AS "12MReturn",
    P0_18M,
	FORMAT(((`value`- P0_18M)/P0_18M)*100,2) AS "18MReturn",
    P0_24M,
	FORMAT(((`value`- P0_24M)/P0_24M)*100,2) AS "24MReturn"           
FROM jossa
ORDER BY `date` DESC	
;


-- Daily for every ticker
SELECT 
	y.ticker,
	ROUND(AVG(y.DailyReturn),5)  AS "Average Daily Return",
    ROUND(STD(y.DailyReturn),5) AS `12M_Sigma`, -- Standard Deviation of Daily Returns | Filter for the last twelve months
    ROUND(AVG(y.DailyReturn)/STD(y.DailyReturn),5) AS Sharpe_ratio
FROM
	( 
    SELECT 
		`date`,
		ticker,
		`value`,
		((`value`- P0_1D)/P0_1D)*100 AS "DailyReturn"         
	FROM jossa
    WHERE date > -- This filters data for the Max date, minus 12M
			(
			SELECT DATE_SUB(MAX(`date`), INTERVAL 12 MONTH) AS ResultDate
			FROM pricing_daily
            )
	ORDER BY `date` DESC
	) y
GROUP BY ticker
ORDER BY `12M_Sigma` DESC
;


/*
Portfolio Return:
	Get the return of the portfolio from the last 12M, 18M and 24M
    P1 * Q1 / SUMPRODUCT(P1*Q1)
    Value of ticker today / account AUM
    
    SUM(Value 12 M ago (View) * Quantity)
    SUM(Value Today (view) * quantity)

Start using the account id and other stuff to calculate portfolio weight

*/
SELECT ad.account_id, AVG(jo.mean_ror), AVG(jo.Sigma), AVG(jo.Sharpe_ratio)
FROM account_dim ad
LEFT JOIN 
	holdings_current hc
	USING(account_id)
LEFT JOIN 
	security_masterlist sm
	USING(ticker)
LEFT JOIN(
	SELECT 
		y.ticker,
		AVG(y.DailyReturn)  AS mean_ror,
		STD(y.DailyReturn) AS Sigma,
		AVG(y.DailyReturn)/STD(y.DailyReturn) AS Sharpe_ratio
	FROM
		( 
		SELECT 
			`date`,
			ticker,
			`value`,
			((`value`- P0_1D)/P0_1D)*100 AS "DailyReturn",
			((`value`- P0_12M)/P0_12M)*100 AS "12MReturn",
			((`value`- P0_18M)/P0_18M)*100 AS "18MReturn",
			((`value`- P0_24M)/P0_24M)*100 AS "24MReturn"           
		FROM jossa
		ORDER BY `date` DESC

		) y
	GROUP BY ticker
	ORDER BY Sharpe_ratio DESC
	) jo
    USING(ticker)
WHERE ad.client_id = 148
GROUP BY ad.account_id;



SELECT 
	y.ticker,
	AVG(y.DailyReturn)  AS mean_ror,
    STD(y.DailyReturn) AS Sigma,
    AVG(y.DailyReturn)/STD(y.DailyReturn) AS Sharpe_ratio
FROM
	( 
    SELECT 
		`date`,
		ticker,
		`value`,
		((`value`- P0_1D)/P0_1D)*100 AS "DailyReturn",
		((`value`- P0_12M)/P0_12M)*100 AS "12MReturn",
		((`value`- P0_18M)/P0_18M)*100 AS "18MReturn",
		((`value`- P0_24M)/P0_24M)*100 AS "24MReturn"           
	FROM jossa
	ORDER BY `date` DESC

	) y
GROUP BY ticker
ORDER BY Sharpe_ratio DESC;

/*
Portfolio Return:
	Get the return of the portfolio from the last 12M, 18M and 24M
    P1 * Q1 / SUMPRODUCT(P1*Q1)
    Value of ticker today / account AUM
    
    SUM(Value 12 M ago (View) * Quantity) P0
    SUM(Value Today (view) * quantity) P1

Start using the account id and other stuff to calculate portfolio weight

*/

SELECT *
FROM holdings_current hc
LEFT JOIN 
	(SELECT *
    FROM jossa
    ORDER BY `date` DESC
    LIMIT 67
    ) y 
    USING(ticker)
WHERE hc.account_id IN('28','2801','2802');

SELECT 
	y.date,
	hc.account_id,
	FORMAT(SUM(hc.quantity*y.value),"NO") AS AUM_today, 
    FORMAT(SUM(hc.quantity*y.P0_12M),"NO") AS AUM_12M, 
    FORMAT(SUM(hc.quantity*y.P0_18M),"NO") AS AUM_18M, 
    FORMAT(SUM(hc.quantity*y.P0_24M),"NO") AS AUM_24M
FROM holdings_current hc
LEFT JOIN 
	(SELECT *
    FROM jossa
    ORDER BY `date` DESC
    LIMIT 67
    ) y 
    USING(ticker)
WHERE hc.account_id IN('28','2801','2802')
GROUP BY hc.account_id;

-- ORDER BY `date` DESC;

WITH AUM_calc AS
(

SELECT 
	y.date,
	hc.account_id,
	SUM(hc.quantity*y.value) AS AUM_today, 
    SUM(hc.quantity*y.P0_12M) AS AUM_12M, 
    SUM(hc.quantity*y.P0_18M) AS AUM_18M, 
    SUM(hc.quantity*y.P0_24M) AS AUM_24M
FROM holdings_current hc
LEFT JOIN 
	(SELECT *
    FROM jossa
    ORDER BY `date` DESC
    LIMIT 67
    ) y 
    USING(ticker)
WHERE hc.account_id IN('28','2801','2802')
GROUP BY hc.account_id)

SELECT
	`date`,
    account_id,
    ROUND((((AUM_today-AUM_12M)/AUM_12M)*100),2) AS "12 Month ror",
    ROUND((((AUM_today-AUM_18M)/AUM_18M)*100),2) AS "18 Month ror",
    ROUND((((AUM_today-AUM_24M)/AUM_24M)*100),2) AS "24 Month ror"
FROM AUM_calc
;


WITH shp AS(
SELECT 
	y.ticker,
	ROUND(AVG(y.DailyReturn),5)  AS "Average Daily Return",
    ROUND(STD(y.DailyReturn),5) AS "12M Sigma", -- Standard Deviation of Daily Returns | Filter for the last twelve months
    ROUND(AVG(y.DailyReturn)/STD(y.DailyReturn),5) AS Sharpe_ratio
FROM
	( 
    SELECT 
		`date`,
		ticker,
		`value`,
		((`value`- P0_1D)/P0_1D)*100 AS "DailyReturn"         
	FROM jossa
    WHERE date > -- This filters data for the Max date, minus 12M
			(
			SELECT DATE_SUB(MAX(`date`), INTERVAL 12 MONTH) AS ResultDate
			FROM pricing_daily
            )
	ORDER BY `date` DESC
	) y
GROUP BY ticker
ORDER BY Sharpe_ratio DESC)

SELECT CASE
		WHEN sm.`major_asset_class` = 'equty' THEN 'equity'
		WHEN sm.`major_asset_class` IN ('fixed income corporate','fixed_income') THEN 'fixed income'
		ELSE sm.`major_asset_class` END AS `major_asset_class_new`,
        sm.minor_asset_class,
        shp.*, hc.account_id
FROM holdings_current hc
LEFT JOIN security_masterlist sm
	USING(ticker)
LEFT JOIN shp
	USING(ticker)
WHERE hc.account_id IN('28','2801','2802')
ORDER BY shp.Sharpe_ratio ASC;
