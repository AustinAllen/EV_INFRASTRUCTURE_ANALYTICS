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

    -- all pair combinations (excluding self)
    select
        a.site_id as site_a,
        b.site_id as site_b,

        ST_DISTANCE(a.location, b.location) / 1000 as distance_km

    from stations a
    join stations b
        on a.site_id <> b.site_id

),

nearest as (

    -- find nearest station for each station
    select
        site_a,
        site_b,
        distance_km,

        row_number() over (
            partition by site_a
            order by distance_km asc
        ) as rn

    from pairs

),

nearest_only as (

    -- keep ONLY nearest neighbor
    select
        site_a,
        site_b,
        distance_km
    from nearest
    where rn = 1

),

ranked as (

    -- 🔥 GLOBAL ranking (important)
    select
        *,
        rank() over (order by distance_km desc) as gap_rank
    from nearest_only

)

select * from ranked