with ev as (

    select *
    from {{ ref('fct_ev_forecast') }}

),

chargers as (

    -- real historical chargers
    select
        year,
        sum(station_count) as actual_chargers
    from {{ ref('int_chargers_by_tla') }}
    group by 1

),

final as (

    select
        e.year,
        e.ev_count,

        -- demand (this should grow!)
        e.ev_count / 40.0 as required_chargers,

        -- ONLY historical actual chargers
        c.actual_chargers,

        -- target ONLY from 2023 → 2030
        case
            when e.year < 2023 then null
            else
                10000.0 * (e.year - 2023) / (2030 - 2023)
        end as target_chargers

    from ev e
    left join chargers c
        on e.year = c.year

)

select * from final
order by year