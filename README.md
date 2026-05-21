# Business Data Warehouse — SQL Queries
 
A set of SQL queries written against an esports business data warehouse, exploring game analytics, referee performance, player KDA, merchandise sales, refund costs, and event profitability. Completed as part of a Business Intelligence coursework module at the University of Portsmouth.
 
## 🛠️ Built With
 
- **SQL Server** (T-SQL)
- Window functions (`RANK()`, `DENSE_RANK()`, `LAG()`, `NTILE()`, `SUM() OVER`)
- CTEs (`WITH` clauses)
- `GROUP BY ROLLUP` for subtotals
- Star schema joins across fact and dimension tables
## 📌 About
 
The queries below run against a star schema data warehouse for an esports tournament business, with fact tables for games, events, online sales, and refunds, plus dimension tables for stadiums, referees, players, champions, clubs, providers, merchandise, tickets, dates, and locations.
 
The coursework was split into three questions:
 
- **Part 1** — Six analytical queries answering business questions about game operations, referee performance, player performance, merchandise sales, refund analysis, and supplier reliability.
- **Part 2** — Two report queries: Report A (top events by net commercial value) and Report B (underperforming segments by promotion ROI).
- **Part 3** — Proposed schema extensions: two new dimensions (BroadcastDim, SponsorDim) and one new fact table (ViewershipFact) to capture digital viewership and sponsorship data.
