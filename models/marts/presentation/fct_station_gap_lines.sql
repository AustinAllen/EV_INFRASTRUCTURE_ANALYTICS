{#with stations as (

    select
        site_id,
        tla_code,
        ST_Y(location) as lat,
        ST_X(location) as lon,
        location

    from {{ ref('fct_charger_points') }}

),

pairs as (

    -- all pairs
    select
        a.tla_code as tla_code,
        a.site_id as site_a,
        b.site_id as site_b,

        a.lat as lat_a,
        a.lon as lon_a,
        b.lat as lat_b,
        b.lon as lon_b,

        ST_DISTANCE(a.location, b.location) / 1000 as distance_km

    from stations a
    join stations b
        on a.site_id < b.site_id

),

nearest as (

    -- nearest neighbor per station
    select
        *,
        row_number() over (
            partition by site_a
            order by distance_km asc
        ) as rn

    from pairs

),

nearest_only as (

    select *
    from nearest
    where rn = 1

),

ranked as (

    -- global ranking
    select
        *,
        rank() over (order by distance_km desc) as gap_rank
    from nearest_only

),

expanded as (

    -- build line structure for Tableau

    -- point A
    select
        tla_code,
        site_a,
        site_b,
        distance_km,
        gap_rank,
        1 as path_order,
        lat_a as lat,
        lon_a as lon

    from ranked

    union all

    -- point B
    select
        tla_code,
        site_a,
        site_b,
        distance_km,
        gap_rank,
        2 as path_order,
        lat_b as lat,
        lon_b as lon

    from ranked

)

select
    tla_code,
    site_a,
    site_b,
    distance_km,
    gap_rank,
    path_order,
    lat,
    lon

from expanded
#}

with stations as (

    select
        site_id,
        tla_code,
        ST_Y(location) as lat,
        ST_X(location) as lon,
        location
    from {{ ref('fct_charger_points') }}

),

pairs as (

    -- all possible pairs
    select
        a.site_id as site_a,
        b.site_id as site_b,
        a.tla_code,

        a.lat as lat_a,
        a.lon as lon_a,
        b.lat as lat_b,
        b.lon as lon_b,

        ST_DISTANCE(a.location, b.location) / 1000 as distance_km

    from stations a
    join stations b
        on a.site_id <> b.site_id

),

nearest as (

    -- ONLY keep nearest neighbor per station
    select
        *,
        row_number() over (
            partition by site_a
            order by distance_km asc
        ) as rn

    from pairs

),

nearest_only as (

    select *
    from nearest
    where rn = 1

),

deduplicated as (

    --  remove reverse duplicates (A-B vs B-A)
    select *
    from nearest_only
    where site_a < site_b

),

ranked as (

    select
        *,
        row_number() over (order by distance_km desc) as gap_rank
    from deduplicated

),

expanded as (

    -- point A
    select
        site_a,
        site_b,
        tla_code,
        distance_km,
        gap_rank,
        1 as path_order,
        lat_a as lat,
        lon_a as lon

    from ranked

    union all

    -- point B
    select
        site_a,
        site_b,
        tla_code,
        distance_km,
        gap_rank,
        2 as path_order,
        lat_b as lat,
        lon_b as lon

    from ranked

)

select
    *,
    site_a || '-' || site_b as line_id
from expanded