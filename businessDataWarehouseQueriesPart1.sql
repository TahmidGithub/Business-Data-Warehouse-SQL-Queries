-- ============================================================
-- QUERY 1: Game Operational Efficiency by Stadium and Game Stage
-- Business Rationale: Operations managers can identify which stadiums
-- and game stages experience the most interruptions and longest durations.
-- This supports better scheduling decisions, venue selection, and helps
-- the league minimise operational disruptions that affect viewer experience.
-- DW Concepts: RANK(), AVG() OVER, MAX() OVER, running SUM() OVER
-- ============================================================

SELECT
    s.StadiumName,
    s.StadiumCapacity,
    s.StadiumOwner,
    gd.GameStage,
    e.EventName,
    e.EventYear,
    gf.GameDuration,
    gf.GameNumberOfPause,
    gf.GameInterruption,
    gf.GameDurationOfPause,
    AVG(gf.GameDuration) OVER (PARTITION BY s.StadiumID) AS AvgDurationByStadium,
    AVG(gf.GameInterruption) OVER (PARTITION BY s.StadiumID) AS AvgInterruptionsByStadium,
    MAX(gf.GameDuration) OVER (PARTITION BY gd.GameStage) AS MaxDurationByStage,
    RANK()
        OVER (PARTITION BY gd.GameStage
              ORDER BY gf.GameDuration DESC) AS DurationRankInStage,
    SUM(gf.GameNumberOfPause)
        OVER (PARTITION BY e.EventID
              ORDER BY dt.DateValue
              ROWS UNBOUNDED PRECEDING) AS RunningPausesTotalByEvent
FROM GameFact gf
JOIN StadiumDim s ON s.StadiumID = gf.StadiumID
JOIN GameDim gd ON gd.GameID = gf.GameID
JOIN EventDim e ON e.EventID = gf.EventID
JOIN DateDim dt  ON dt.DateID = gf.DateID
ORDER BY s.StadiumName, gd.GameStage, gf.GameDuration DESC;


-- ============================================================
-- QUERY 2: Referee Game Management Analysis by Pause Type and Event
-- Business Rationale: Operations managers can assess which referees are
-- associated with the most disruptive games and whether years of experience
-- correlates with smoother game management. This supports referee selection
-- decisions for high-stakes events and highlights training needs.
-- DW Concepts: AVG() OVER PARTITION BY, RANK() OVER PARTITION BY,
--              running SUM() OVER ROWS UNBOUNDED PRECEDING
-- ============================================================

SELECT
    r.RefereeName,
    r.RefereeYearsOfExperience,
    p.PauseType,
    p.PauseReason,
    e.EventName,
    e.EventYear,
    gf.GameDuration,
    gf.GameInterruption,
    gf.GameDurationOfPause,
    AVG(gf.GameDuration) OVER (PARTITION BY r.RefereeID) AS AvgGameDurationByReferee,
    AVG(gf.GameInterruption) OVER (PARTITION BY r.RefereeID) AS AvgInterruptionsByReferee,
    RANK() OVER (PARTITION BY e.EventYear
                 ORDER BY gf.GameInterruption DESC) AS InterruptionRankByYear,
    SUM(gf.GameDurationOfPause)
        OVER (PARTITION BY r.RefereeID
              ORDER BY gf.GameID
              ROWS UNBOUNDED PRECEDING) AS RunningPauseDurationByReferee
FROM GameFact gf
JOIN RefereeDim r ON r.RefereeID = gf.RefereeID
JOIN PauseDim p ON p.PauseID = gf.PauseID
JOIN EventDim e ON e.EventID = gf.EventID
ORDER BY r.RefereeName, gf.GameInterruption DESC;


-- ============================================================
-- QUERY 3: Player KDA Performance by Champion Type with Running Kill Totals
-- Business Rationale: Team coaches and analysts can identify which players
-- perform best on specific champion types and track their cumulative kill
-- contribution across games. This informs draft strategy, player selection,
-- and highlights performance trends across tournament stages.
-- DW Concepts: DENSE_RANK(), AVG() OVER, running SUM() OVER,
--              multi-dimension join through GameFact as anchor fact
-- ============================================================

SELECT
    pl.PlayerGameName,
    pl.PlayerRealName,
    c.ChampionName,
    c.ChampionType,
    cb.ClubName,
    gd.GameStage,
    pr.PRKills,
    pr.PRAssists,
    pr.PRDeaths,
    CAST(
        (pr.PRKills + pr.PRAssists) / NULLIF(CAST(pr.PRDeaths AS FLOAT), 0) AS DECIMAL(10,2)) 
    AS KDA_Ratio,

    AVG(
        CAST((pr.PRKills + pr.PRAssists) / NULLIF(CAST(pr.PRDeaths AS FLOAT), 0)
        AS DECIMAL(10,2))
    ) OVER (PARTITION BY pig.PlayerID, c.ChampionType) 
        AS AvgKDAByPlayerAndChampionType,

    SUM(pr.PRKills)
        OVER (PARTITION BY pig.PlayerID
              ORDER BY gf.GameID
              ROWS UNBOUNDED PRECEDING)
        AS RunningKillTotal,

    DENSE_RANK()
        OVER (PARTITION BY c.ChampionType
              ORDER BY pr.PRKills + pr.PRAssists - pr.PRDeaths DESC)            
        AS PerformanceRankByChampionType
FROM GameFact gf
JOIN GameDim gd ON gd.GameID = gf.GameID
JOIN PlayerInGameDim pig ON pig.GameID = gd.GameID
JOIN PersonalRecordDim pr ON pr.PRID = pig.PRID
JOIN PlayerDim pl ON pl.PlayerID = pig.PlayerID
JOIN ChampionDim c ON c.ChampionID = pig.ChampionID
JOIN ClubDim cb ON cb.ClubID = pig.ClubID
ORDER BY c.ChampionType, KDA_Ratio DESC;


-- ============================================================
-- QUERY 4: Online Merchandise Sales Year-over-Year Growth by Provider
-- Business Rationale: E-commerce and supply chain managers can track
-- year-on-year revenue trends by merchandise type and provider, identifying
-- growth leaders and declining categories. This supports renegotiation of
-- supplier contracts and informs inventory investment decisions.
-- DW Concepts: CTE, LAG() for YoY comparison, RANK(), running SUM() OVER
-- ============================================================

WITH YearlySales AS (
    SELECT
        dt.DateYear,
        md.MerchandiseType,
        pv.ProviderName,
        ld.Country AS ProviderCountry,
        SUM(osf.MerchandiseSold) AS TotalUnitsSold,
        SUM(osf.MerchandiseSoldPND) AS TotalRevenuePND,
        SUM(osf.MerchandiseStocked) AS TotalStocked,
        CAST(
            SUM(osf.MerchandiseSold) * 100.0
            / NULLIF(SUM(osf.MerchandiseStocked), 0)
        AS DECIMAL(5,2)) AS SellThroughRatePct
    FROM OnlineSalesFact osf
    JOIN DateDim dt ON dt.DateID = osf.DateID
    JOIN MerchandiseDim md ON md.MerchandiseID = osf.MerchandiseID
    JOIN ProviderDim pv ON pv.ProviderID = md.MerchandiseProviderID
    JOIN LocationDim ld ON ld.LocationID = pv.ProviderLocation
    GROUP BY dt.DateYear, md.MerchandiseType, pv.ProviderName, ld.Country
)
SELECT
    DateYear,
    MerchandiseType,
    ProviderName,
    ProviderCountry,
    TotalRevenuePND,
    TotalUnitsSold,
    SellThroughRatePct,
    LAG(TotalRevenuePND)
        OVER (PARTITION BY MerchandiseType, ProviderName
              ORDER BY DateYear) AS PrevYearRevenuePND,
    CAST(
        (TotalRevenuePND
            - LAG(TotalRevenuePND) OVER (
                PARTITION BY MerchandiseType, ProviderName ORDER BY DateYear)
        ) * 100.0
        / NULLIF(
            LAG(TotalRevenuePND) OVER (
                PARTITION BY MerchandiseType, ProviderName ORDER BY DateYear)
        , 0)
    AS DECIMAL(10,2)) AS YoY_GrowthPct,
    RANK()
        OVER (PARTITION BY DateYear
              ORDER BY TotalRevenuePND DESC) AS RevenueRankThisYear,
    SUM(TotalRevenuePND)
        OVER (PARTITION BY DateYear
              ORDER BY TotalRevenuePND DESC
              ROWS UNBOUNDED PRECEDING) AS RunningRevenueByYear
FROM YearlySales
ORDER BY DateYear, TotalRevenuePND DESC;


-- ============================================================
-- QUERY 5: Refund Cost Analysis by Ticket Type and Refund Method (ROLLUP)
-- Business Rationale: Finance and customer service teams can identify which
-- ticket categories and refund methods generate the highest refund costs.
-- ROLLUP produces automatic subtotals and a grand total row, enabling
-- hierarchical reporting to support policy improvements and loss reduction.
-- DW Concepts: GROUP BY ROLLUP, GROUPING() function
-- ============================================================

SELECT
    ISNULL(td.TicketType, 'ALL TICKET TYPES') AS TicketType,
    ISNULL(td.TicketEvent, 'ALL EVENT TYPES') AS TicketEvent,
    ISNULL(rd.RefundType, 'ALL REFUND TYPES') AS RefundType,
    ISNULL(CAST(dt.DateYear AS VARCHAR(4)), 'ALL YEARS') AS YearOfRefund,
    SUM(rf.TicketsRefunded) AS TotalTicketsRefunded,
    SUM(rf.TicketsRefundedPND) AS TotalTicketRefundPND,
    SUM(rf.MerchandiseRefunded) AS TotalMerchandiseRefunded,
    SUM(rf.MerchandiseRefundedPND) AS TotalMerchandiseRefundPND,
    SUM(rf.OnlineMerchandiseRefunded) AS TotalOnlineMerchandiseRefunded,
    SUM(rf.OnlineMerchantiseRefundedPND) AS TotalOnlineRefundPND,
    COUNT(*) AS NumberOfRefundTransactions,
    GROUPING(td.TicketType) AS IsTicketTypeSubtotal,
    GROUPING(rd.RefundType) AS IsRefundTypeSubtotal,
    GROUPING(dt.DateYear) AS IsYearSubtotal
FROM RefundFact rf
JOIN TicketDim td ON td.TicketID = rf.TicketID
JOIN RefundDim rd ON rd.RefundID = rf.RefundID
JOIN DateDim dt ON dt.DateID = rf.DateID
GROUP BY ROLLUP(td.TicketType, td.TicketEvent, rd.RefundType, dt.DateYear)
ORDER BY
    GROUPING(td.TicketType),
    GROUPING(rd.RefundType),
    GROUPING(dt.DateYear),
    TotalTicketRefundPND DESC;


-- ============================================================
-- QUERY 6: Merchandise Provider Refund Analysis by Country
-- Business Rationale: Supply chain and finance managers can identify which
-- merchandise providers generate the highest refund losses, broken down by
-- provider country and merchandise type. This flags unreliable suppliers
-- and supports contract renegotiation decisions.
-- DW Concepts: CTE, RANK(), NTILE(), AVG() OVER PARTITION BY
-- ============================================================

WITH ProviderRefunds AS (
    SELECT
        pv.ProviderName,
        ld.Country AS ProviderCountry,
        md.MerchandiseType,
        SUM(rf.MerchandiseRefunded) AS TotalUnitsRefunded,
        SUM(rf.MerchandiseRefundedPND) AS TotalRefundValuePND,
        SUM(rf.OnlineMerchandiseRefunded) AS TotalOnlineRefunded,
        SUM(rf.OnlineMerchantiseRefundedPND) AS TotalOnlineRefundPND
    FROM RefundFact rf
    JOIN MerchandiseDim md ON md.MerchandiseID = rf.MerchandiseID
    JOIN ProviderDim pv ON pv.ProviderID = md.MerchandiseProviderID
    JOIN LocationDim ld ON ld.LocationID = pv.ProviderLocation
    GROUP BY pv.ProviderName, ld.Country, md.MerchandiseType
)
SELECT
    ProviderName,
    ProviderCountry,
    MerchandiseType,
    TotalUnitsRefunded,
    TotalRefundValuePND,
    TotalOnlineRefunded,
    TotalOnlineRefundPND,
    RANK() OVER (ORDER BY TotalRefundValuePND DESC) AS RefundValueRank,
    NTILE(4) OVER (ORDER BY TotalRefundValuePND DESC) AS RefundQuartile,
    AVG(TotalRefundValuePND) OVER (PARTITION BY ProviderCountry) AS AvgRefundByCountry
FROM ProviderRefunds
ORDER BY TotalRefundValuePND DESC;