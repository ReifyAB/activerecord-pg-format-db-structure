# frozen_string_literal: true

require_relative "base"

module ActiveRecordPgFormatDbStructure
  module Preprocessors
    # Remove \restrict and \unrestrict pragmas added by newer versions
    # of pg_dump
    class RemoveRestrictPragmas < Base
      def preprocess!
        source.gsub!(/^(\\restrict .*)$/, "")
        source.gsub!(/^(\\unrestrict .*)$/, "")
      end
    end
  end
end
