# frozen_string_literal: true

require "pg_query"

module ActiveRecordPgFormatDbStructure
  module Preprocessors
    # :nodoc:
    class Base
      attr_reader :source

      def initialize(source)
        @source = source
      end
    end
  end
end
