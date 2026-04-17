with source as (

    select *
    from {{ source('raw', 'MOTOR_VEHICLE_REGISTER') }}

),

renamed as (

    select
        "c1"::number as vehicle_id,
        "c2" as alternative_motive_power,
        "c3" as colour,
        "c4" as body_type,
        "c5"::number as engine_cc,
        "c6" as chassis7,
        "c7" as vehicle_class,
        "c8" as engine_number,
        "c9"::number as first_registration_year,
        "c10"::number as first_registration_month,
        "c11"::number as gross_vehicle_mass,
        "c12"::number as height,
        "c13" as import_status,
        "c14" as industry_class,
        "c15" as industry_model_code,
        "c16" as make,
        "c17" as model,
        "c18" as motive_power,
        "c19" as mvma_model_code,
        "c20"::number as number_of_axles,
        "c21"::number as number_of_seats,
        "c22" as nz_assembled,
        "c23" as original_country,
        "c24"::number as power_rating,
        "c25" as previous_country,
        "c26" as road_transport_code,
        "c27" as submodel,
        "c28" as tla,
        "c29" as transmission_type,
        "c30"::number as vdam_weight,
        "c31" as vehicle_type,
        "c32" as vehicle_usage,
        "c33"::number as vehicle_year,
        "c34" as vin11,
        "c35"::number as width,
        "c36" as synthetic_greenhouse_gas,
        "c37"::float as fc_combined,
        "c38"::float as fc_urban,
        "c39"::float as fc_extra_urban

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
        upper(trim(motive_power)) as motive_power,
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