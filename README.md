# Snowflake AI Demo — PXC (PlatformX Communications)

## Snowflake Intelligence: Sample Questions
Use these prompts with the PXC Intelligence agent:
- Network & resilience: “How many Ethernet/optical backhaul circuits are live by UK region and what’s our 99.995% SLA adherence?”
- Partner performance: “Show revenue and units by partner type (reseller, carrier, SI, alt-net) for the last quarter; highlight top service providers.”
- Product mix: “Connectivity vs Voice & Collaboration vs Cloud & Security revenue in GBP; include gross margin and YoY growth.”
- Managed security: “Which managed security services have the highest attach rate on new connectivity deals? Break down by region.”
- Portal & automation: “What volume of orders were placed through 1Portal and APIs this month, and how long did they take to activate?”
- Customer experience: “Summarize NPS, churn risk, and key drivers from support interactions over the past 30 days.”

## What Was Done (PXC Fit)
- Branding: Agents, schemas, products, regions, and documents aligned to PXC—the UK’s fastest growing independent wholesale telecoms platform with nationwide coverage and the 1Portal experience (https://www.pxc.co.uk/).
- Data: UK wholesale/partner context (reseller, carrier, SI, alt-net, service provider), B2B/B2G customers, B2C subscriptions, KPIs, and city/region metrics; currency set to GBP.
- Products: Connectivity, Voice & Collaboration, Cloud & Security Software, and Managed Security Solutions, with resilience options and partner enablement.
- Docs: PXC-branded PDFs and portal/API context for search-driven answers.

## Datasets (loaded via Data Foundation)
- KPIs: `pxc_kpi` (platform KPIs: broadband/TV/voice/backhaul totals, WiFi assurance, resilience/readiness).
- City subs: `city_subs` (broadband, TV, voice, mobile by city).
- B2C: `b2c_customers`, `b2c_subscriptions` (bundles, SIM counts, WiFi assurance, GBP fees).
- B2B/CRM: `sales_fact`, `customer_dim`, `product_dim`, `region_dim`, `vendor_dim`, plus `sf_accounts`, `sf_opportunities`, `sf_contacts`.
- Infra: UK POP/edge sites and MVNO/backhaul interconnects in `infrastructure_capacity.csv`.

## Agent Tools & Semantic Views
- Finance: FINANCE_SEMANTIC_VIEW → “Query Finance Datamart”
- Sales (B2B): SALES_SEMANTIC_VIEW → “Query Sales Datamart”
- Marketing: MARKETING_SEMANTIC_VIEW → “Query Marketing Datamart”
- HR: HR_SEMANTIC_VIEW → “Query HR Datamart”
- KPIs/City subs: KPI_SEMANTIC_VIEW → “Query KPI Datamart”
- B2C: B2C_SUBS_SEMANTIC_VIEW → “Query B2C Subscriptions”
- B2B summary: B2B_SUMMARY_SEMANTIC_VIEW → “Query B2B Summary”
- Docs: Finance/HR/Marketing/Sales/Strategy/Network search services + Dynamic_Doc_URL tool

## How to Ask (examples you can copy/paste)
- “Connectivity, Voice & Collaboration, Cloud & Security revenue by partner type; include GBP growth vs last quarter.”
- “Top 10 partners by Ethernet/backhaul orders and on-time activation; show resilience add-ons.”
- “List active B2C subs with WiFi assurance and streaming add-ons; show GBP monthly fee and SIM count.”
- “Marketing campaigns that drove the most leads and closed-won revenue in 2024; include spend and impressions.”
- “Finance summary by product category and top vendors (GBP) across the PXC footprint.”
- “Network latency/jitter and SLA breaches for London, Manchester, and Glasgow; flag impacted partners.”