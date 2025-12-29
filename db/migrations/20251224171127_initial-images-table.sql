-- migrate:up
create table images (
    original_filename text not null,
    captured_at timestamp not null,
    original_metadata jsonb not null,
    day date,
    sequence int,
    public_filename text,

    -- internal
    created_at timestamp default now(),
    updated_at timestamp default now()
);

-- migrate:down
drop table images;
