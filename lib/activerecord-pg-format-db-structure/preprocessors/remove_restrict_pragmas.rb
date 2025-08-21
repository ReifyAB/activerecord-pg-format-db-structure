# frozen_string_literal: true

require_relative "base"

module ActiveRecordPgFormatDbStructure
  module Preprocessors
    # Inline non-foreign key constraints into table declaration
    class RemoveRestrictPragmas < Base
      def preprocess!
        source.gsub!(/^(\\restrict .*)$/, "")
        source.gsub!(/^(\\unrestrict .*)$/, "")
      end
    end
  end
end
