# frozen_string_literal: true

RSpec.describe ActiveRecordPgFormatDbStructure::Formatter do
  describe "#format" do
    it "does a good job by default" do
      formatter = described_class.new

      source = +<<~SQL

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
      SQL

      expect(formatter.format(source)).to eq(<<~SQL.chomp)


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
      SQL
    end
  end
end
