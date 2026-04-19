with source as (

    select *
    from {{ source('raw', 'MOTOR_VEHICLE_REGISTER') }}

),

renamed as (

    select
        "OBJECTID"::number as vehicle_id,
        "ALTERNATIVE_MOTIVE_POWER" as alternative_motive_power,
        "BASIC_COLOUR" as colour,
        "BODY_TYPE" as body_type,
        "CC_RATING"::number as engine_cc,
        "CHASSIS7" as chassis7,
        "CLASS" as vehicle_class,
        "ENGINE_NUMBER" as engine_number,
        "FIRST_NZ_REGISTRATION_YEAR"::number as first_registration_year,
        "FIRST_NZ_REGISTRATION_MONTH"::number as first_registration_month,
        "GROSS_VEHICLE_MASS"::number as gross_vehicle_mass,
        "HEIGHT"::number as height,
        "IMPORT_STATUS" as import_status,
        "INDUSTRY_CLASS" as industry_class,
        "INDUSTRY_MODEL_CODE" as industry_model_code,
        "MAKE" as make,
        "MODEL" as model,
        "MOTIVE_POWER" as motive_power,
        "MVMA_MODEL_CODE" as mvma_model_code,
        "NUMBER_OF_AXLES"::number as number_of_axles,
        "NUMBER_OF_SEATS"::number as number_of_seats,
        "NZ_ASSEMBLED" as nz_assembled,
        "ORIGINAL_COUNTRY" as original_country,
        "POWER_RATING"::number as power_rating,
        "PREVIOUS_COUNTRY" as previous_country,
        "ROAD_TRANSPORT_CODE" as road_transport_code,
        "SUBMODEL" as submodel,
        "TLA" as tla,
        "TRANSMISSION_TYPE" as transmission_type,
        "VDAM_WEIGHT"::number as vdam_weight,
        "VEHICLE_TYPE" as vehicle_type,
        "VEHICLE_USAGE" as vehicle_usage,
        "VEHICLE_YEAR"::number as vehicle_year,
        "VIN11" as vin11,
        "WIDTH"::number as width,
        "SYNTHETIC_GREENHOUSE_GAS" as synthetic_greenhouse_gas,
        "FC_COMBINED"::float as fc_combined,
        "FC_URBAN"::float as fc_urban,
        "FC_EXTRA_URBAN"::float as fc_extra_urban

    from source

),

cleaned as (

    select
        vehicle_id,

        upper(trim(alternative_motive_power)) as alternative_motive_power,
        upper(trim(colour)) as colour,
        upper(trim(body_type)) as body_type,

        engine_cc,
        chassis7,
        upper(trim(vehicle_class)) as vehicle_class,
        engine_number,

        first_registration_year,
        first_registration_month,
        gross_vehicle_mass,
        height,

        upper(trim(import_status)) as import_status,
        upper(trim(industry_class)) as industry_class,
        industry_model_code,

        upper(trim(make)) as make,
        upper(trim(model)) as model,
        CASE
            -- PURE ELECTRIC (core)
            WHEN upper(trim(motive_power)) LIKE '%ELECTRIC%' 
            AND upper(trim(motive_power)) NOT LIKE '%HYBRID%' 
            THEN 'BEV'

            -- RANGE EXTENDED (still charging dependent)
            WHEN upper(trim(motive_power)) LIKE '%ELECTRIC%EXTENDED%' 
                THEN 'BEV'

            -- PLUG-IN HYBRID
            WHEN upper(trim(motive_power)) LIKE '%PLUGIN%' 
            OR upper(trim(motive_power)) LIKE '%PLUG-IN%' 
            THEN 'PHEV'

            -- HYBRID (non-charging)
            WHEN upper(trim(motive_power)) LIKE '%HYBRID%' 
            THEN 'HEV'

            -- FUEL CELL (edge case)
            WHEN upper(trim(motive_power)) LIKE '%FUEL CELL%' 
            THEN 'FCEV'

            WHEN upper(trim(motive_power)) IS NULL THEN 'UNKNOWN'

            ELSE 'OTHER'
        END AS motive_power,
        mvma_model_code,

        number_of_axles,
        number_of_seats,

        upper(trim(nz_assembled)) as nz_assembled,
        upper(trim(original_country)) as original_country,

        power_rating,
        upper(trim(previous_country)) as previous_country,

        road_transport_code,
        upper(trim(submodel)) as submodel,
        upper(trim(tla)) as tla,
        upper(trim(transmission_type)) as transmission_type,

        vdam_weight,
        upper(trim(vehicle_type)) as vehicle_type,
        upper(trim(vehicle_usage)) as vehicle_usage,

        vehicle_year,
        vin11,
        width,

        upper(trim(synthetic_greenhouse_gas)) as synthetic_greenhouse_gas,

        fc_combined,
        fc_urban,
        fc_extra_urban

    from renamed

)

select * from cleaned