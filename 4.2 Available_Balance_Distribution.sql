SELECT 
BALANCE_ON_DATE,
COUNT(USER_ID) AS NUM_USERS,
SUM(CASE WHEN AVAILABLE_BALANCE<0 THEN 1 ELSE 0 END) AS NEGATIVE_USERS,
AVG(AVAILABLE_BALANCE) AS DAILY_AVG_BALANCE
FROM
  (SELECT USER_ID, BALANCE_ON_DATE, MAX(AVAILABLE_BALANCE) AS AVAILABLE_BALANCE
  FROM mysql_db.galileo.GALILEO_DAILY_BALANCES
  WHERE ACCOUNT_TYPE = '6' AND USER_ID IN (SELECT DISTINCT USER_ID
        FROM REST.TEST.Risk_Segmentation_disputes_02_25_2021
        WHERE TYPE_OF_TRXN IN ('ATM Withdrawals') AND LATEST_TIER = 'TIER1' AND DD_AMT_BIN = '2.>=200') -- only care this group. temp table logic from Shu
  GROUP BY 1,2) tmp
GROUP BY 1
ORDER BY 1;

select
AVG_BALANCE_ntile_100,
avg(AVG_BALANCE) as avg_balance_on_tile,
count(*) as num_users
from
(
  SELECT 
  ntile(100) over (order by AVG_BALANCE desc) as AVG_BALANCE_ntile_100,
  AVG_BALANCE
  FROM
  (
    SELECT 
    USER_ID,
    AVG(AVAILABLE_BALANCE) AS AVG_BALANCE
    FROM
      (SELECT USER_ID, BALANCE_ON_DATE, MAX(AVAILABLE_BALANCE) AS AVAILABLE_BALANCE
      FROM mysql_db.galileo.GALILEO_DAILY_BALANCES
      WHERE ACCOUNT_TYPE = '6' and BALANCE_ON_DATE >= '2020-03-01' AND USER_ID IN (SELECT DISTINCT USER_ID
              FROM REST.TEST.Risk_Segmentation_disputes_02_25_2021
              WHERE TYPE_OF_TRXN IN ('ATM Withdrawals') AND LATEST_TIER = 'TIER1' AND DD_AMT_BIN = '2.>=200')
      GROUP BY 1,2) tmp
    GROUP BY 1
    ORDER BY 1
  ) tmp1
)
group by 1
order by 1;

