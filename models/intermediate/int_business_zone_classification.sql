with base as (

    select
        tla_code,
        total_ev,
        population,
        geometry,
        ev_per_1000

    from {{ ref('int_ev_per_capita') }}

),

classified as (

    select
        *,

        case
            when ev_per_1000 > 2 then 'Urban (High Activity)'
            when ev_per_1000 > 1 then 'Suburban (Medium)'
            else 'Rural (Low Activity)'
        end as business_zone

    from base

)

select * from classified