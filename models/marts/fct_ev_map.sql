with base as (

    select *
    from {{ ref('fct_ev_supply_demand') }}

),

tla as (

    select
        upper(trim(tla_name)) as tla_code,
        geometry
    from {{ ref('dim_tla') }}

)

select
    b.tla_code,
    b.year,
    b.ev_count,
    b.station_count,
    b.connector_count,
    b.evs_per_connector,
    b.evs_per_station,

    -- 🔥 geometry for map
    t.geometry

from base b
left join tla t
    on b.tla_code = t.tla_code