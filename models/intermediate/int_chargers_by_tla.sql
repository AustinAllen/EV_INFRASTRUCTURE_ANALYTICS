select
    upper(trim(t.tla_name)) as tla_code,
    year(e.date_first_operational) as year,
    count(*) as station_count,
    sum(e.number_of_connectors) as connector_count
from {{ ref('stg_ev_roam_sites') }} e
join {{ ref('dim_tla') }} t
    on st_within(e.location, t.geometry)
group by 1, 2