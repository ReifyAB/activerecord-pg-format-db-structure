# frozen_string_literal: true

RSpec.describe ActiveRecordPgFormatDbStructure::Transforms::InlineConstraints do
  describe "#transform!" do
    it "inline non-foreign key constraints in the table declaration" do
      formatter = ActiveRecordPgFormatDbStructure::Formatter.new(
        transforms: [described_class]
      )

      source = +<<~SQL
        CREATE TABLE public.comments (
            id bigint NOT NULL,
            user_id bigint NOT NULL,
            post_id bigint NOT NULL,
            created_at timestamp(6) without time zone NOT NULL,
            updated_at timestamp(6) without time zone NOT NULL
        );

        CREATE TABLE public.posts (
            id bigint NOT NULL,
            score int NOT NULL,
            created_at timestamp(6) without time zone NOT NULL,
            updated_at timestamp(6) without time zone NOT NULL
        );

        CREATE TABLE public.users (
            id bigint NOT NULL,
            created_at timestamp(6) without time zone NOT NULL,
            updated_at timestamp(6) without time zone NOT NULL
        );

        CREATE INDEX my_index ON public.users USING btree (id);

        ALTER TABLE ONLY public.comments
            ADD CONSTRAINT comments_pkey PRIMARY KEY (id);

        ALTER TABLE ONLY public.posts
            ADD CONSTRAINT posts_pkey PRIMARY KEY (id);

        ALTER TABLE ONLY public.users
            ADD CONSTRAINT users_pkey PRIMARY KEY (id);

        ALTER TABLE ONLY public.comments ADD CONSTRAINT fk_rails_0000000001 FOREIGN KEY (post_id) REFERENCES public.posts(id);

        ALTER TABLE ONLY public.comments ADD CONSTRAINT fk_rails_0000000002 FOREIGN KEY (user_id) REFERENCES public.users(id);

        ALTER TABLE ONLY public.posts ADD CONSTRAINT postive_score CHECK (score > 0);

        INSERT INTO "schema_migrations" (version) VALUES
        ('20250124155339');
      SQL

      expect(formatter.format(source)).to eq(<<~SQL)
        -- Name: comments; Type: TABLE;

        CREATE TABLE public.comments (
            id bigint NOT NULL,
            user_id bigint NOT NULL,
            post_id bigint NOT NULL,
            created_at timestamp(6) NOT NULL,
            updated_at timestamp(6) NOT NULL,
            CONSTRAINT comments_pkey PRIMARY KEY (id)
        );


        -- Name: posts; Type: TABLE;

        CREATE TABLE public.posts (
            id bigint NOT NULL,
            score int NOT NULL,
            created_at timestamp(6) NOT NULL,
            updated_at timestamp(6) NOT NULL,
            CONSTRAINT posts_pkey PRIMARY KEY (id),
            CONSTRAINT postive_score CHECK (score > 0)
        );


        -- Name: users; Type: TABLE;

        CREATE TABLE public.users (
            id bigint NOT NULL,
            created_at timestamp(6) NOT NULL,
            updated_at timestamp(6) NOT NULL,
            CONSTRAINT users_pkey PRIMARY KEY (id)
        );
        CREATE INDEX my_index ON public.users USING btree (id);

        ALTER TABLE ONLY public.comments
          ADD CONSTRAINT fk_rails_0000000001 FOREIGN KEY (post_id) REFERENCES public.posts (id);

        ALTER TABLE ONLY public.comments
          ADD CONSTRAINT fk_rails_0000000002 FOREIGN KEY (user_id) REFERENCES public.users (id);


        INSERT INTO schema_migrations (version) VALUES
          ('20250124155339')
        ;
      SQL
    end

    it "removes NO VALID when inlining since that's a no-op when inlined" do
      formatter = ActiveRecordPgFormatDbStructure::Formatter.new(
        transforms: [described_class]
      )

      source = +<<~SQL
        CREATE TABLE public.posts (
            id bigint NOT NULL,
            score int NOT NULL,
            created_at timestamp(6) without time zone NOT NULL,
            updated_at timestamp(6) without time zone NOT NULL
        );

        ALTER TABLE ONLY public.posts ADD CONSTRAINT postive_score CHECK (score > 0) NOT VALID;
      SQL

      expect(formatter.format(source)).to eq(<<~SQL)
        -- Name: posts; Type: TABLE;

        CREATE TABLE public.posts (
            id bigint NOT NULL,
            score int NOT NULL,
            created_at timestamp(6) NOT NULL,
            updated_at timestamp(6) NOT NULL,
            CONSTRAINT postive_score CHECK (score > 0)
        );
      SQL
    end
  end
end
