-- migrate:up
create table images (
    original_filename text primary key,
    captured_at timestamp not null,
    original_metadata jsonb not null,
    local_path text not null,
    day date,
    sequence int,
    public_filename text,

    -- internal
    created_at timestamp default now(),
    updated_at timestamp default now()
);

-- migrate:down
drop table images;
