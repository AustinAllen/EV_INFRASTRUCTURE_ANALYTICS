-- models/marts/introduction/fct_ev_registrations_by_tla.sql

with base as (

    select 
        upper(trim(tla)) as tla_code,
        first_registration_year,
        first_registration_month
    from {{ ref('stg_motor_vehicle_register') }}
    WHERE motive_power = 'BEV'

),

aggregated as (

    select
        tla_code,
        DATE_FROM_PARTS(first_registration_year, first_registration_month, 1) AS timestamp,
        COUNT(*) AS ev_count
    from base
    GROUP BY 1,2

),

tla as (

    select
        upper(trim(tla_name)) as tla_code,
        geometry
    from {{ ref('dim_tla') }}

)

select
    a.*,
    t.geometry

from aggregated a
left join tla t
    on a.tla_code = t.tla_code
{#with base as (

    select 
    upper(trim(tla)) as tla_code,
    first_registration_year,
    first_registration_month
    from {{ ref('stg_motor_vehicle_register') }}
    WHERE motive_power = 'BEV'

),

tla as (

    select
        upper(trim(tla_name)) as tla_code,
        geometry
    from {{ ref('dim_tla') }}

)

select
    b.tla_code,
    DATE_FROM_PARTS(b.first_registration_year, b.first_registration_month, 1) AS timestamp,
    COUNT(*) AS ev_count,
    -- geometry for map
    t.geometry

from base b
left join tla t
    on b.tla_code = t.tla_code
GROUP BY 1,2
#}
{#SELECT
    tla as tla_name,
    DATE_FROM_PARTS(first_registration_year, first_registration_month, 1) AS timestamp,
    COUNT(*) AS ev_count
FROM {{ ref('stg_motor_vehicle_register') }}
WHERE motive_power = 'BEV'
GROUP BY 1,2,3,4
#}