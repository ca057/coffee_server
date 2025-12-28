-- migrate:up
create table images (
    original_filename text not null,
    captured_at timestamptz not null,
    original_metadata jsonb not null,
    day date,
    sequence int,
    public_filename text,

    -- internal
    created_at timestamptz default now(),
    updated_at timestamptz default now()
);

-- migrate:down
drop table images;
