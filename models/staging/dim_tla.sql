select
    tla_name,
    geometry
from {{ source('raw', 'TLA_BOUNDARIES') }}