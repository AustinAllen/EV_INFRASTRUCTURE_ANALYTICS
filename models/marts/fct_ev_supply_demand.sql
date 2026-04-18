{#select
    coalesce(e.tla_code, c.tla_code) as tla_code,
    coalesce(e.year, c.year) as year,

    coalesce(e.ev_count, 0) as ev_count,
    coalesce(c.station_count, 0) as station_count,
    coalesce(c.connector_count, 0) as connector_count,

    -- KPI 1: EVs per connector
    case 
        when coalesce(c.connector_count, 0) > 0 
        then e.ev_count::float / c.connector_count 
    end as evs_per_connector,

    -- KPI 2: EVs per station
    case 
        when coalesce(c.station_count, 0) > 0 
        then e.ev_count::float / c.station_count 
    end as evs_per_station

from {{ ref('int_ev_demand_by_tla') }} e
full join {{ ref('int_chargers_by_tla') }} c
    on e.tla_code = c.tla_code

    
    -- and e.year = c.year -- ev year registered not matched with the station operation. 
    -- Add "where" still got problem because multiple tla_name with different year. Multipline
    -- because coalesce(e.year, c.year) as year c.year are not unique. 
    where e.year = (select max(year) from {{ ref('int_ev_demand_by_tla') }}) 
#}

{#select
    coalesce(e.tla_code, c.tla_code) as tla_code,

    sum(e.ev_count) as ev_count,
    sum(c.station_count) as station_count,
    sum(c.connector_count) as connector_count,

    case when sum(c.connector_count) > 0
        then sum(e.ev_count)::float / sum(c.connector_count)
    end as evs_per_connector,

from {{ ref('int_ev_demand_by_tla') }} e
full join {{ ref('int_chargers_by_tla') }} c
    on e.tla_code = c.tla_code
group by 1
#}

with latest_ev as (
    select *
    from {{ ref('int_ev_demand_by_tla') }}
    where year = (select max(year) from {{ ref('int_ev_demand_by_tla') }})
),

latest_chargers as (
    select *
    from {{ ref('int_chargers_by_tla') }}
    where year = (select max(year) from {{ ref('int_chargers_by_tla') }})
)

select
    coalesce(e.tla_code, c.tla_code) as tla_code,
    coalesce(e.year, c.year) as year,

    e.ev_count,
    c.station_count,
    c.connector_count,

    case when c.connector_count > 0 
        then e.ev_count::float / c.connector_count 
    end as evs_per_connector,

    case when c.station_count > 0 
        then e.ev_count::float / c.station_count 
    end as evs_per_station

from latest_ev e
full join latest_chargers c
    on e.tla_code = c.tla_code

{#select
    coalesce(e.tla_code, c.tla_code) as tla_code,

    -- aggregate first
    sum(e.ev_count) as ev_count,
    sum(c.station_count) as station_count,
    sum(c.connector_count) as connector_count,

    -- KPI 1
    case 
        when sum(c.connector_count) > 0 
        then sum(e.ev_count)::float / sum(c.connector_count)
    end as evs_per_connector,

    -- KPI 2 (THIS is what you want)
    case 
        when sum(c.station_count) > 0 
        then sum(e.ev_count)::float / sum(c.station_count)
    end as evs_per_station

from {{ ref('int_ev_demand_by_tla') }} e
full join {{ ref('int_chargers_by_tla') }} c
    on e.tla_code = c.tla_code

group by 1
#}

