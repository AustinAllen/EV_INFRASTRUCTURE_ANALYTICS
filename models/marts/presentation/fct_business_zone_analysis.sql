select
    b.tla_code,
    b.business_zone,
    b.population,
    b.geometry,
    b.total_ev,
    c.station_count,
    c.connector_count,

    --  KEY METRIC
    b.total_ev::float / nullif(c.station_count, 0) as evs_per_station

from {{ ref('int_business_zone_classification') }} b
left join {{ ref('int_chargers_by_tla') }} c
    on b.tla_code = c.tla_code