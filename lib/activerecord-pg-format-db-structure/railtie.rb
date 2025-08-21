# frozen_string_literal: true

module ActiveRecordPgFormatDbStructure
  # Setup for Rails
  class Railtie < Rails::Railtie
    config.activerecord_pg_format_db_structure = ActiveSupport::OrderedOptions.new
    config.activerecord_pg_format_db_structure.preprocessors = DEFAULT_PREPROCESSORS.dup
    config.activerecord_pg_format_db_structure.transforms = DEFAULT_TRANSFORMS.dup
    config.activerecord_pg_format_db_structure.deparser = DEFAULT_DEPARSER
    config.activerecord_pg_format_db_structure.statement_appender = DEFAULT_STATEMENT_APPENDER

    rake_tasks do
      load "activerecord-pg-format-db-structure/tasks/clean_db_structure.rake"
    end
  end
end
