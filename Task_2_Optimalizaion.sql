--- Point to parts that could be optimized
--- Feel free to comment any row that you think could be optimize/adjusted in some way!
--- The following query is from SAP HANA but applies to any DB
--- Do not worry if the tables/columns are not familiar to you 
----   -> you do not need to interpret the result (in fact the query does not reflect actual DB content)
SELECT 
	RSEG.EBELN,
	RSEG.EBELP,
    RSEG.BELNR,
    RSEG.AUGBL AS AUGBL_W,
    LPAD(EKPO.BSART,6,0) as BSART,
	BKPF.GJAHR,
	BSEG.BUKRS,
	BSEG.BUZEI,
	BSEG.BSCHL,
	BSEG.SHKZG,
    CASE WHEN BSEG.SHKZG = 'H' THEN (-1) * BSEG.DMBTR ELSE BSEG.DMBTR END AS DMBTR, -- Instead of CASE we can use iif function - iif(BSEG.SHKZG = 'H',(-1) * BSEG.DMBTR,BSEG.DMBTR)
    COALESCE(BSEG.AUFNR, 'Kein SM-A Zuordnung') AS AUFNR,					    -- Instead of COALESCE we can use isnull function - isnull(BSEG.AUFNR,'Kein SM-A Zuordnung')
    COALESCE(LFA1.LAND1, 'Andere') AS LAND1,								    -- Unnecessary command due to condition LFA1.LAND1 in ('DE','SK')
    LFA1.LIFNR,
    LFA1.ZSYSNAME,
    BKPF.BLART as BLART,	   --Unnecessarily renamed
    BKPF.BUDAT as BUDAT,	   --Unnecessarily renamed
    BKPF.CPUDT as CPUDT	   --Unnecessarily renamed
FROM "DTAG_DEV_CSBI_CELONIS_DATA"."dtag.dev.csbi.celonis.data.elog::V_RSEG" AS RSEG
-- I don't know how big table "DTAG_DEV_CSBI_CELONIS_WORK"."dtag.dev.csbi.celonis.app.p2p_elog::__P2P_REF_CASES" AS EKPO is, but instead of Left Join I would rather use the update in the next step.
LEFT JOIN "DTAG_DEV_CSBI_CELONIS_WORK"."dtag.dev.csbi.celonis.app.p2p_elog::__P2P_REF_CASES" AS EKPO ON 1=1  
    AND RSEG.ZSYSNAME = EKPO.SOURCE_SYSTEM
    AND RSEG.MANDT = EKPO.MANDT
    AND RSEG.EBELN || RSEG.EBELP = EKPO.EBELN || EKPO.EBELP 
INNER JOIN "DTAG_DEV_CSBI_CELONIS_DATA"."dtag.dev.csbi.celonis.data.elog::V_BKPF" AS BKPF ON 1=1
    AND BKPF.AWKEY = RSEG.AWKEY
    AND RSEG.ZSYSNAME = BKPF.ZSYSNAME
    AND RSEG.MANDT in ('200')		  -- this condition should be in WHERE / In case of one value in the condition it is enough to use = 
INNER JOIN "DTAG_DEV_CSBI_CELONIS_DATA"."dtag.dev.csbi.celonis.data.elog::V_BSEG" AS BSEG ON 1=1
    AND DATS_IS_VALID(BSEG.ZFBDT) = 1
    AND BSEG.KOART = 'K'
    AND CAST(BSEG.GJAHR AS INT) = 2020
    AND BKPF.ZSYSNAME = BSEG.ZSYSNAME
    AND BKPF.MANDT = BSEG.MANDT
    AND BKPF.BUKRS = BSEG.BUKRS
    AND BKPF.GJAHR = BSEG.GJAHR
    AND BKPF.BELNR = BSEG.BELNR
    AND BSEG.DMBTR*-1 >= 0		 -- It's enought to use BSEG.DMBTR <=0
INNER JOIN (SELECT * FROM "DTAG_DEV_CSBI_CELONIS_DATA"."dtag.dev.csbi.celonis.data.elog::V_LFA1" AS TEMP  -- Instead of an internal select, I would rather use CTE
            WHERE TEMP.LIFNR > '020000000') AS LFA1 ON 1=1 -- we cannot use the > to text
    AND BSEG.ZSYSNAME = LFA1.ZSYSNAME
    AND BSEG.LIFNR=LFA1.LIFNR
    AND BSEG.MANDT=LFA1.MANDT
    AND LFA1.LAND1 in ('DE','SK')
;

