with ev as (

     -- aggregate FIRST 
    select
        tla_code,
        sum(ev_count) as total_ev
    from {{ ref('int_ev_demand_by_tla') }}
    group by 1

),

pop as (
    select
        tla_code,
        population,
        geometry
    from {{ ref('stg_tla_population') }}

),

joined as (

    select
        e.tla_code,
        2023 as snapshot_year, 
        e.total_ev,
        p.population,
        p.geometry,

        case when p.population > 0
            then e.total_ev::float / p.population * 1000
        end as ev_per_1000

    from ev e
    left join pop p
        on e.tla_code = p.tla_code

)

select * from joined