-- models/intermediate/int_ev_demand_by_tla.sql
select
  upper(trim(tla)) as tla_code,
  first_registration_year as year,
  count(*) as ev_count
from {{ ref('stg_motor_vehicle_register') }}
where motive_power = 'ELECTRIC'
group by 1, 2