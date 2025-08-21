# frozen_string_literal: true

RSpec.describe ActiveRecordPgFormatDbStructure::Preprocessors::RemoveRestrictPragmas do
  describe "#preprocess!" do
    it 'removes \restrict and \unrestrict pragmas' do
      source = +<<~SQL
        \\restrict 1234

        CREATE TABLE public.comments (
            id bigint NOT NULL,
            user_id bigint NOT NULL,
            post_id bigint NOT NULL,
            created_at timestamp(6) without time zone NOT NULL,
            updated_at timestamp(6) without time zone NOT NULL
        );

        \\unrestrict 1234
      SQL

      described_class.new(
        source
      ).preprocess!

      expect(source).to eq(<<~SQL)


        CREATE TABLE public.comments (
            id bigint NOT NULL,
            user_id bigint NOT NULL,
            post_id bigint NOT NULL,
            created_at timestamp(6) without time zone NOT NULL,
            updated_at timestamp(6) without time zone NOT NULL
        );


      SQL
    end
  end
end
