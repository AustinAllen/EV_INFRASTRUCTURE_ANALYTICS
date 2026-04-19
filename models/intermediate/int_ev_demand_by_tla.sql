-- models/intermediate/int_ev_demand_by_tla.sql
select
  upper(trim(tla)) as tla_code,
  first_registration_year as year,
  motive_power,
  count(*) as ev_count
from {{ ref('stg_motor_vehicle_register') }}
where motive_power = 'BEV' or motive_power = 'PHEV'
group by 1, 2, 3