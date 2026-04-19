with source as (

    select *
    from {{ source('raw', 'EV_CHARGING_STATIONS_RAW') }}

),

--- For the array data from Json, it must be flatten first. 
flattened as (

    select
       value as data
    from source,
    lateral flatten(input => RAW_DATA)

),

renamed as (

    select
        data:"Type"::string as record_type,
        data:"OBJECTID"::number as site_id,
        data:"NAME"::string as site_name,
        data:"OPERATOR"::string as operator,
        data:"OWNER"::string as owner,
        data:"ADDRESS"::string as address,

        data:"is24Hours"::string as is_24_hours,
        data:"carParkCount"::number as car_park_count,
        data:"hasCarparkCost"::string as has_carpark_cost,
        data:"maxTimeLimit"::string as max_time_limit,
        data:"hasTouristAttraction"::string as has_tourist_attraction,

        data:"latitude"::float as latitude,
        data:"longitude"::float as longitude,

        data:"currentType"::string as current_type,
        data:"dateFirstOperational"::string as date_first_operational,

        data:"numberOfConnectors"::number as number_of_connectors,
        data:"connectorsList"::string as connectors_list,

        data:"hasChargingCost"::string as has_charging_cost,
        data:"GlobalID"::string as global_id

    from flattened

),

cleaned as (

    select
        site_id,

        upper(trim(record_type)) as record_type,
        upper(trim(site_name)) as site_name,
        upper(trim(operator)) as operator,
        upper(trim(owner)) as owner,
        address,

        case when upper(trim(is_24_hours)) = 'TRUE' then true else false end as is_24_hours,
        car_park_count,
        case when upper(trim(has_carpark_cost)) = 'TRUE' then true else false end as has_carpark_cost,
        max_time_limit,
        case when upper(trim(has_tourist_attraction)) = 'TRUE' then true else false end as has_tourist_attraction,

        latitude,
        longitude,

        {#CASE 
            WHEN latitude IS NOT NULL AND longitude IS NOT NULL
            THEN TO_GEOGRAPHY(
                'POINT(' || 
                CASE 
                    WHEN longitude BETWEEN 60 AND 80 THEN longitude + 100
                    ELSE longitude
                END
                || ' ' || latitude || ')'
            )
        END AS location,#}
        -- geography column (important!)
        case 
            when latitude is not null and longitude is not null
            then to_geography('POINT(' || longitude || ' ' || latitude || ')')
        end as location,

        upper(trim(current_type)) as current_type,

        to_date(date_first_operational, 'DD/MM/YYYY') as date_first_operational,

        number_of_connectors,
        connectors_list,  -- keep as string for now

        case when upper(trim(has_charging_cost)) = 'TRUE' then true else false end as has_charging_cost,

        replace(replace(global_id, '{', ''), '}', '') as global_id

    from renamed

)

select * from cleaned