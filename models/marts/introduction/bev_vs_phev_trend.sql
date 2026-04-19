SELECT
    DATE_FROM_PARTS(first_registration_year, first_registration_month, 1) AS month,
    motive_power as vehicle_type,
    COUNT(*) AS vehicle_count
FROM {{ ref('stg_motor_vehicle_register') }}
WHERE motive_power IN ('BEV', 'PHEV')
GROUP BY 1,2