with base as (

    select
        site_id,
        tla_code,
        ST_Y(location) as lat,
        ST_X(location) as lon

    from {{ ref('fct_charger_points') }}

),

ordered as (

    select
        *,
        row_number() over (
            partition by tla_code
            order by lat, lon
        ) as rn

    from base

),

paired as (

    select
        a.tla_code,
        a.site_id as site_a,
        b.site_id as site_b,

        a.lat as lat_a,
        a.lon as lon_a,
        b.lat as lat_b,
        b.lon as lon_b

    from ordered a
    join ordered b
        on a.tla_code = b.tla_code
        and a.rn = b.rn - 1

),

-------- structure for Tableau (Path)
expanded as (

    select
        tla_code,
        site_a,
        site_b,
        1 as path_order,
        lat_a as lat,
        lon_a as lon

    from paired

    union all

    select
        tla_code,
        site_a,
        site_b,
        2 as path_order,
        lat_b as lat,
        lon_b as lon

    from paired

),

---------------- compute distance
distance_calc as (

    select
        tla_code,
        site_a,
        site_b,

        6371 * 2 * ASIN(
            SQRT(
                POWER(SIN(RADIANS(lat_b - lat_a) / 2), 2) +
                COS(RADIANS(lat_a)) * COS(RADIANS(lat_b)) *
                POWER(SIN(RADIANS(lon_b - lon_a) / 2), 2)
            )
        ) as distance_km

    from paired

),

------ rank gaps
ranked as (

    select
        *,
        RANK() OVER (ORDER BY distance_km DESC) as gap_rank
    from distance_calc

)

------------ FINAL OUTPUT (THIS IS THE FIX)
select
    e.tla_code,
    e.site_a,
    e.site_b,
    e.path_order,
    e.lat,
    e.lon,

    r.distance_km,
    r.gap_rank

from expanded e
left join ranked r
    on e.site_a = r.site_a
    and e.site_b = r.site_b