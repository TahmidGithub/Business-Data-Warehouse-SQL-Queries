-- ============================================================
-- REPORT A: Top 10 Events by Net Commercial Value
-- Senior management wants to understand which performance events drive
-- commercial value. Only events starting in January or September are
-- included. For each qualifying event, broken down by Ticket Type and
-- Ticket Event Stage, the report shows gross revenue, refund losses,
-- net commercial value, sell-through percentage, and refund rate.
-- ============================================================

WITH GrossRevenue AS (
    SELECT
        e.EventID,
        e.EventName,
        e.EventYear,
        td.TicketType,
        td.TicketEvent,
        SUM(ef.TicketsSoldPND) + SUM(ef.MerchandiseSoldPND) AS GrossOnsiteValuePND,
        SUM(ef.TicketsSold) AS TotalTicketsSold,
        SUM(ef.SpectatorsNumber) AS TotalSpectators
    FROM EventFact ef
    JOIN EventDim e ON e.EventID = ef.EventID
    JOIN DateDim sd ON sd.DateID = e.EventStartDateID
    JOIN TicketDim td ON td.TicketID = ef.TicketID
    WHERE MONTH(sd.DateValue) IN (1, 9)
    GROUP BY e.EventID, e.EventName, e.EventYear, td.TicketType, td.TicketEvent
),
RefundLosses AS (
    SELECT
        e.EventID,
        td.TicketType,
        td.TicketEvent,
        SUM(rf.TicketsRefundedPND) + SUM(rf.MerchandiseRefundedPND) + SUM(rf.OnlineMerchantiseRefundedPND) AS TotalRefundValuePND
    FROM RefundFact rf
    JOIN DateDim rfd ON rfd.DateID = rf.DateID
    JOIN EventFact ef ON ef.TicketID = rf.TicketID AND ef.MerchandiseID = rf.MerchandiseID
    JOIN EventDim e ON e.EventID = ef.EventID
    JOIN DateDim sd ON sd.DateID = e.EventStartDateID
    JOIN DateDim ed ON ed.DateID = e.EventEndDateID
    JOIN TicketDim td ON td.TicketID = rf.TicketID
    WHERE MONTH(sd.DateValue) IN (1, 9)
    AND rfd.DateValue BETWEEN sd.DateValue AND ed.DateValue
    GROUP BY e.EventID, td.TicketType, td.TicketEvent
),
RankedEvents AS (
    SELECT
        gr.EventID,
        RANK() OVER (ORDER BY SUM(gr.GrossOnsiteValuePND - ISNULL(rl.TotalRefundValuePND, 0)) DESC) AS EventRank
    FROM GrossRevenue gr
    LEFT JOIN RefundLosses rl ON rl.EventID = gr.EventID
    AND rl.TicketType = gr.TicketType
    AND rl.TicketEvent = gr.TicketEvent
    GROUP BY gr.EventID
)
SELECT
    gr.EventName,
    gr.EventYear,
    gr.TicketType,
    gr.TicketEvent,
    gr.GrossOnsiteValuePND,
    ISNULL(rl.TotalRefundValuePND, 0) AS RefundValuePND,
    gr.GrossOnsiteValuePND - ISNULL(rl.TotalRefundValuePND, 0) AS NetCommercialValuePND,
    CAST(gr.TotalTicketsSold * 100.0 / NULLIF(gr.TotalSpectators, 0) AS DECIMAL(5,2)) AS SellThroughPct,
    CAST(ISNULL(rl.TotalRefundValuePND, 0) * 100.0 / NULLIF(gr.GrossOnsiteValuePND, 0) AS DECIMAL(5,2)) AS RefundRatePct,
    re.EventRank
FROM GrossRevenue gr
LEFT JOIN RefundLosses rl ON rl.EventID = gr.EventID
AND rl.TicketType = gr.TicketType
AND rl.TicketEvent = gr.TicketEvent
JOIN RankedEvents re ON re.EventID = gr.EventID
WHERE re.EventRank <= 10
ORDER BY re.EventRank, gr.TicketType, gr.TicketEvent;


-- ============================================================
-- REPORT B: Underperforming Ticket Segments Despite High Promotion Cost
-- Management suspects that some ticket segments attract investment but
-- fail to convert well. A segment is flagged as underperforming if,
-- within the same event year, its conversion rate is below the
-- championship average AND its promotion cost is above the average.
-- Results show only flagged segments, sorted by worst Promotion ROI first.
-- ============================================================

WITH SegmentStats AS (
    SELECT
        td.TicketType,
        td.TicketEvent,
        e.EventYear,
        COUNT(DISTINCT ef.EventID) AS NumberOfEvents,
        AVG(CAST(ef.SpectatorsNumber AS FLOAT)) AS AvgSpectators,
        AVG(CAST(ef.TicketsSold AS FLOAT)) AS AvgTicketsSold,
        AVG(CAST(ef.VIPSpectatorsNumber AS FLOAT))
            / NULLIF(AVG(CAST(ef.TicketsSold AS FLOAT)), 0) AS VIPShare,
        AVG(CAST(ef.TicketsSold AS FLOAT))
            / NULLIF(AVG(CAST(ef.SpectatorsNumber AS FLOAT)), 0) AS ConversionRate,
        CAST(
            SUM(ef.PromotionRevenue)
            / NULLIF(SUM(ef.PromotionCost), 0)
        AS DECIMAL(10,2)) AS PromotionROI,
        AVG(ef.PromotionCost) AS AvgPromotionCost
    FROM EventFact ef
    JOIN TicketDim td ON td.TicketID = ef.TicketID
    JOIN EventDim e   ON e.EventID   = ef.EventID
    GROUP BY td.TicketType, td.TicketEvent, e.EventYear
),
YearAverages AS (
    SELECT
        EventYear,
        AVG(ConversionRate) AS ChampAvgConversionRate,
        AVG(AvgPromotionCost) AS ChampAvgPromotionCost
    FROM SegmentStats
    GROUP BY EventYear
)
SELECT
    ss.TicketType,
    ss.TicketEvent,
    ss.EventYear,
    ss.NumberOfEvents,
    CAST(ss.AvgSpectators AS DECIMAL(10,2)) AS AvgSpectators,
    CAST(ss.AvgTicketsSold AS DECIMAL(10,2)) AS AvgTicketsSold,
    CAST(ss.ConversionRate AS DECIMAL(5,4))  AS ConversionRate,
    ss.PromotionROI,
    CAST(ss.VIPShare AS DECIMAL(5,4))  AS VIPShare,
    CAST(ya.ChampAvgConversionRate AS DECIMAL(5,4)) AS ChampAvgConversionRate,
    CAST(ya.ChampAvgPromotionCost AS DECIMAL(10,2)) AS ChampAvgPromotionCost
FROM SegmentStats ss
JOIN YearAverages ya ON ya.EventYear = ss.EventYear
WHERE ss.ConversionRate   < ya.ChampAvgConversionRate
  AND ss.AvgPromotionCost > ya.ChampAvgPromotionCost
ORDER BY ss.PromotionROI ASC;