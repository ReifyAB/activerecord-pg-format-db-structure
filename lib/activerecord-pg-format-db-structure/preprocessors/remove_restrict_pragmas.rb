# frozen_string_literal: true

require_relative "base"

module ActiveRecordPgFormatDbStructure
  module Preprocessors
    class RemoveRestrictPragmas < Base
      def preprocess!
        source.gsub!(/^(\\restrict .*)$/, "")
        source.gsub!(/^(\\unrestrict .*)$/, "")
      end
    end
  end
end
