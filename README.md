# activerecord-pg-format-db-structure
[![Gem Version](https://img.shields.io/gem/v/activerecord-pg-format-db-structure)](https://rubygems.org/gems/activerecord-pg-format-db-structure)
![GitHub Actions Workflow Status](https://img.shields.io/github/actions/workflow/status/ReifyAB/activerecord-pg-format-db-structure/main.yml)


Automatically cleans up your PostgreSQL `structure.sql` file after each rails migration.

Say good-bye to those pesky diffs you get between coworkers!

By default, it will:

* Inline primary key declarations
* Inline SERIAL type declarations
* Inline table constraints
* Move index creation below their corresponding tables
* Group `ALTER TABLE` statements into a single statement per table
* Sorts table column declarations (primary key / foreign keys / data / timestamp / constraints)
* Sorts `schema_migrations` inserts
* Format and indent the entire file consistently

It can also optionally inline foreign key declarations (see below).

As an example, the task will transform this raw `structure.sql`:

<details>

<summary>Click to expand</summary>

```sql
--
-- Name: pgcrypto; Type: EXTENSION; Schema: -; Owner: -
--

CREATE EXTENSION IF NOT EXISTS pgcrypto WITH SCHEMA public;


--
-- Name: EXTENSION pgcrypto; Type: COMMENT; Schema: -; Owner: -
--

COMMENT ON EXTENSION pgcrypto IS 'cryptographic functions';

--
-- Name: comments; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.comments (
    id bigint NOT NULL,
    user_id bigint NOT NULL,
    post_id bigint NOT NULL,
    created_at timestamp(6) without time zone NOT NULL,
    updated_at timestamp(6) without time zone NOT NULL
);


--
-- Name: comments_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.comments_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: comments_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.comments_id_seq OWNED BY public.comments.id;

--
-- Name: posts; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.posts (
    id bigint NOT NULL,
    created_at timestamp(6) without time zone NOT NULL,
    updated_at timestamp(6) without time zone NOT NULL
);


--
-- Name: posts_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.posts_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: posts_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.posts_id_seq OWNED BY public.posts.id;


--
-- Name: users; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.users (
    id bigint NOT NULL,
    created_at timestamp(6) without time zone NOT NULL,
    updated_at timestamp(6) without time zone NOT NULL
);


--
-- Name: users_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.users_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: users_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.users_id_seq OWNED BY public.users.id;

--
-- Name: comments id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.comments ALTER COLUMN id SET DEFAULT nextval('public.comments_id_seq'::regclass);

--
-- Name: posts id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.posts ALTER COLUMN id SET DEFAULT nextval('public.posts_id_seq'::regclass);

--
-- Name: users id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.users ALTER COLUMN id SET DEFAULT nextval('public.users_id_seq'::regclass);

--
-- Name: comments comments_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.comments
    ADD CONSTRAINT comments_pkey PRIMARY KEY (id);

--
-- Name: posts posts_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.posts
    ADD CONSTRAINT posts_pkey PRIMARY KEY (id);

--
-- Name: users users_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_pkey PRIMARY KEY (id);

--
-- Name: comments fk_rails_0000000001; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.comments
    ADD CONSTRAINT fk_rails_0000000001 FOREIGN KEY (post_id) REFERENCES public.posts(id);

--
-- Name: comments fk_rails_0000000002; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.comments
    ADD CONSTRAINT fk_rails_0000000002 FOREIGN KEY (user_id) REFERENCES public.users(id);

INSERT INTO "schema_migrations" (version) VALUES
('20250124155339');
```
</details>

into this normalize (and much more compatch & readable) version:

```sql
CREATE EXTENSION IF NOT EXISTS pgcrypto SCHEMA public;


-- Name: comments; Type: TABLE;

CREATE TABLE public.comments (
    id bigserial PRIMARY KEY,
    user_id bigint NOT NULL,
    post_id bigint NOT NULL,
    created_at timestamp(6) NOT NULL,
    updated_at timestamp(6) NOT NULL
);


-- Name: posts; Type: TABLE;

CREATE TABLE public.posts (
    id bigserial PRIMARY KEY,
    created_at timestamp(6) NOT NULL,
    updated_at timestamp(6) NOT NULL
);


-- Name: users; Type: TABLE;

CREATE TABLE public.users (
    id bigserial PRIMARY KEY,
    created_at timestamp(6) NOT NULL,
    updated_at timestamp(6) NOT NULL
);

ALTER TABLE ONLY public.comments
  ADD CONSTRAINT fk_rails_0000000001 FOREIGN KEY (post_id) REFERENCES public.posts (id),
  ADD CONSTRAINT fk_rails_0000000002 FOREIGN KEY (user_id) REFERENCES public.users (id);


INSERT INTO schema_migrations (version) VALUES
  ('20250124155339')
;
```

The goal is to make your `structure.sql` file easier to read and to
reduce the risk of getting random diffs between machines after each
migration.

Those transformations are made by manipulating the SQL AST directly
using [pg_query](https://github.com/pganalyze/pg_query), and each
transformation is opt-in and can be run independently.

You can also add your own transforms (see below).


## Installation

Add the following to your Gemfile:

```ruby
gem 'activerecord-pg-format-db-structure'
```

## Usage

### Rails

Adding the gem to your dependencies this will automatically hook the library into your `rake db:migrate` task.

If you want to configure which transforms to use, you can configure the library with the following:

```ruby
Rails.application.configure do
  config.activerecord_pg_format_db_structure.transforms = [
    ActiveRecordPgFormatDbStructure::Transforms::RemoveCommentsOnExtensions,
    ActiveRecordPgFormatDbStructure::Transforms::RemoveDefaultsSetCommands,
    ActiveRecordPgFormatDbStructure::Transforms::SortSchemaMigrations,
    ActiveRecordPgFormatDbStructure::Transforms::InlinePrimaryKeys,
    # ActiveRecordPgFormatDbStructure::Transforms::InlineForeignKeys,
    ActiveRecordPgFormatDbStructure::Transforms::InlineSerials,
    ActiveRecordPgFormatDbStructure::Transforms::InlineConstraints,
    ActiveRecordPgFormatDbStructure::Transforms::MoveIndicesAfterCreateTable,
    ActiveRecordPgFormatDbStructure::Transforms::GroupAlterTableStatements,
    ActiveRecordPgFormatDbStructure::Transforms::SortTableColumns,
  ]

  config.activerecord_pg_format_db_structure.deparser = ActiveRecordPgFormatDbStructure::Deparser
end
```

### Use outside of Rails

```ruby
require "activerecord-pg-format-db-structure/formatter"

structure = File.read("db/structure.sql")
formatted = ActiveRecordPgFormatDbStructure::Formatter.new.format(structure)
File.write("db/structure.sql", formatted)
```

## Transformers

### RemoveCommentsOnExtensions

Remove COMMENT statement applied to extensions

### RemoveDefaultsSetCommands

Remove SET commands that apply default values to postgres settings. By default, the following defaults are handled:

```ruby
ActiveRecordPgFormatDbStructure::Transforms::RemoveDefaultsSetCommands.postgres_config_defaults = {
  default_table_access_method: "heap",
  default_with_oids: false,
  idle_in_transaction_session_timeout: 0,
  lock_timeout: 0,
  statement_timeout: 0,
  transaction_timeout: 0,
  standard_conforming_strings: true,
  xmloption: "content"
}
```

Which are the default values since Postgres 9.1. You can make changes
to the above config in case you want to handle more cases.


### SortSchemaMigrations

Sort schema_migrations inserts to be in chronological order, helps with reducing merge conflicts.

### InlinePrimaryKeys

Inlines primary keys with the table declaration

### InlineForeignKeys

Inline foreign key constraints.

Note: using this transform makes the structure file no longer
loadable, since tables should be created before a foreign key
can target it, so it is not included by default.

### InlineSerials

Inline SERIAL declaration inside table declaration.

Note: the logic looks for statements of this shape:

```sql
ALTER TABLE ONLY ts.tn ALTER COLUMN c SET DEFAULT nextval('ts.tn_c_seq'::regclass);
```

It also assumes that the associated sequence has default settings. A
later version could try to be more strict / validate that the
sequence indeed has default settings.

### InlineConstraints

Inline non-foreign key constraints into table declaration.

Note that this also remove the `NOT VALID` setting if present, since that's a no-op when the constraint is created at the same time as the table.

### MoveIndicesAfterCreateTable

Move indice declaration just below the table they index

### GroupAlterTableStatements

Group alter table statements into one operation per
table.

Should be run after other operations that inline alter statements.

### SortTableColumns

Sort table columns, by order of priority and alphabetically:

 1. primary key
 2. foreign keys
 3. generic columns
 4. timestamps
 5. constraints

Note that you can define your own ordering by replacing the default `priority_mapping`:

```ruby
ActiveRecordPgFormatDbStructure::Transforms::SortTableColumns.priority_mapping = lambda do |sortable_entry|
  case sortable_entry
  in is_column: true, is_primary_key: true, name:
    [0, name]
  in is_column: true, is_foreign_key: true, name:
    [1, name]
  in is_column: true, is_timestamp: false, name:
    [2, name]
  in is_column: true, is_timestamp: true, name:
    [3, name]
  in is_constraint: true, name:
    [5, name]
  end
end
```

where `sortable_entry` is an instance of:

```ruby
SORTABLE_ENTRY = Data.define(
  :name,
  :is_column,
  :is_constraint,
  :is_primary_key,
  :is_foreign_key,
  :is_timestamp,
  :raw_entry
)
```

## Deparser

Returns an SQL string from raw PgQuery statements.

Relying mostly on `PgQuery.deparse`, and does a best effort to add some indentation where possible.

## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run `rake spec` to run the tests. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release`, which will create a git tag for the version, push git commits and the created tag, and push the `.gem` file to [rubygems.org](https://rubygems.org).

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/ReifyAB/activerecord-pg-format-db-structure. This project is intended to be a safe, welcoming space for collaboration, and contributors are expected to adhere to the [code of conduct](https://github.com/ReifyAB/activerecord-pg-format-db-structure/blob/main/CODE_OF_CONDUCT.md).

## Credits

Using the awesome [pg_query](https://github.com/pganalyze/pg_query) that provides a ruby interface to the native Postgres SQL parser.

Inspired by the [activerecord-clean-db-structure](https://github.com/lfittl/activerecord-clean-db-structure) gem by [Lukas Fittl](https://github.com/lfittl). I wanted to achieved something like that, but using a proper SQL parser instead of search / replace using regexps.

## License

The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).

## Code of Conduct

Everyone interacting in the activerecord-pg-format-db-structure project's codebases, issue trackers, chat rooms and mailing lists is expected to follow the [code of conduct](https://github.com/ReifyAB/activerecord-pg-format-db-structure/blob/main/CODE_OF_CONDUCT.md).
