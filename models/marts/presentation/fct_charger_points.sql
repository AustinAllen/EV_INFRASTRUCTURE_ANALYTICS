select
    e.site_id,
    e.number_of_connectors,

    -- point
    e.location,

    -- assign region
    upper(trim(t.tla_name)) as tla_code

from {{ ref('stg_ev_roam_sites') }} e
left join {{ ref('dim_tla') }} t
    on ST_WITHIN(e.location, t.geometry)