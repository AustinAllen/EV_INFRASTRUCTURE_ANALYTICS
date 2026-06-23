-- int_chargers_by_tla_latest
with base as (

    select
        tla_code,
        year,
        station_count,
        connector_count,

        row_number() over (
            partition by tla_code
            order by year desc
        ) as rn

    from {{ ref('int_chargers_by_tla') }}

)

select
    tla_code,
    station_count,
    connector_count
from base
where rn = 1