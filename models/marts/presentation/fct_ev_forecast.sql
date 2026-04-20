with base as (

    -- historical EV stock
    select
        year,
        sum(ev_count) as ev_count
    from {{ ref('int_ev_demand_by_tla') }}
    where motive_power in ('BEV','PHEV')
    group by 1

),

growth as (

    -- get first & last year
    select
        min(year) as start_year,
        max(year) as end_year,
        min(ev_count) as start_ev,
        max(ev_count) as end_ev
    from base

),

cagr as (

    select
        *,
        power(end_ev::float / start_ev, 1.0 / (end_year - start_year)) - 1 as growth_rate
    from growth

),

years as (

    -- generate future years to 2030
    select
        year
    from (
        select distinct year from base
        union all
        select 2024 union all
        select 2025 union all
        select 2026 union all
        select 2027 union all
        select 2028 union all
        select 2029 union all
        select 2030
    )

),

forecast as (

    select
        y.year,

        case 
            when b.ev_count is not null then b.ev_count

            else
                g.start_ev * power(1 + g.growth_rate, y.year - g.start_year)
        end as ev_count,

        case 
            when b.ev_count is not null then 'actual'
            else 'forecast'
        end as data_type

    from years y
    left join base b
        on y.year = b.year
    cross join cagr g

)

select * from forecast
order by year