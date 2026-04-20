with ev as (

    select
        tla_code,
        year,
        SUM(case when motive_power in ('BEV','PHEV') then ev_count else 0 end) as ev_count

    from {{ ref('int_ev_demand_by_tla') }}
    group by 1,2

),

chargers as (

    select
        tla_code,
        year,
        station_count,
        connector_count

    from {{ ref('int_chargers_by_tla') }}

),

combined as (

    select
        coalesce(e.tla_code, c.tla_code) as tla_code,
        coalesce(e.year, c.year) as year,

        e.ev_count,
        c.station_count,
        c.connector_count,

        case when c.station_count > 0 
            then e.ev_count::float / c.station_count 
        end as evs_per_station

    from ev e
    full join chargers c
        on e.tla_code = c.tla_code
        and e.year = c.year
)

select
    c.*,
    t.geometry

from combined c
left join {{ ref('dim_tla') }} t
    on c.tla_code = upper(trim(t.tla_name))