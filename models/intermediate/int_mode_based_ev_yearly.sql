{#with base as (

    SELECT
        DATE_FROM_PARTS(year, 1, 1)::TIMESTAMP_NTZ AS year,
        ev_count::FLOAT AS ev_count
    FROM {{ ref('int_ev_demand_by_tla') }}

)

select * from base
order by year#}
with base as (

    select
        to_date(year || '-01-01') as ts,
        sum(ev_count) as ev_count
    from {{ ref('int_ev_demand_by_tla') }}
    group by year

)

select *
from base
order by ts