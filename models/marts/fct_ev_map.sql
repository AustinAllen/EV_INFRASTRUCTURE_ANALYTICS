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
    upper(trim(b.tla_code)) as tla_code,
    b.year,
    b.bev_count,
    b.phev_count,
    b.total_ev,
    b.station_count,
    b.connector_count,
    b.evs_per_connector,
    b.evs_per_station,

    --  geometry for map
    t.geometry

from base b
left join tla t
    on b.tla_code = t.tla_code