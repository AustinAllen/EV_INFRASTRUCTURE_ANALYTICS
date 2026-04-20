with base as (
    select
        upper(trim(tla_name)) as tla_name,
        population,
        geometry
    from {{ source('raw', 'TLA_POPULATION') }}
),

clean as (

    select
        case
            when tla_name like '%LOCAL BOARD AREA%' 
                then replace(tla_name, ' LOCAL BOARD AREA', '')
            else tla_name
        end as tla_code,

        population,
        geometry

    from base

)

select * from clean