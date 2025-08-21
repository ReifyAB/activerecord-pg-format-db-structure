# frozen_string_literal: true

require_relative "activerecord-pg-format-db-structure/version"

require_relative "activerecord-pg-format-db-structure/deparser"
require_relative "activerecord-pg-format-db-structure/statement_appender"
require_relative "activerecord-pg-format-db-structure/preprocessors/remove_restrict_pragmas"
require_relative "activerecord-pg-format-db-structure/transforms/remove_comments_on_extensions"
require_relative "activerecord-pg-format-db-structure/transforms/inline_serials"
require_relative "activerecord-pg-format-db-structure/transforms/inline_primary_keys"
require_relative "activerecord-pg-format-db-structure/transforms/inline_foreign_keys"
require_relative "activerecord-pg-format-db-structure/transforms/move_indices_after_create_table"
require_relative "activerecord-pg-format-db-structure/transforms/inline_constraints"
require_relative "activerecord-pg-format-db-structure/transforms/group_alter_table_statements"
require_relative "activerecord-pg-format-db-structure/transforms/remove_defaults_set_commands"
require_relative "activerecord-pg-format-db-structure/transforms/sort_schema_migrations"
require_relative "activerecord-pg-format-db-structure/transforms/sort_table_columns"

module ActiveRecordPgFormatDbStructure
  DEFAULT_PREPROCESSORS = [
    Preprocessors::RemoveRestrictPragmas
  ].freeze

  DEFAULT_TRANSFORMS = [
    Transforms::RemoveCommentsOnExtensions,
    Transforms::RemoveDefaultsSetCommands,
    Transforms::SortSchemaMigrations,
    Transforms::InlinePrimaryKeys,
    # Transforms::InlineForeignKeys,
    Transforms::InlineSerials,
    Transforms::InlineConstraints,
    Transforms::MoveIndicesAfterCreateTable,
    Transforms::GroupAlterTableStatements,
    Transforms::SortTableColumns
  ].freeze

  DEFAULT_DEPARSER = Deparser
  DEFAULT_STATEMENT_APPENDER = StatementAppender
end

# :nocov:
require_relative "activerecord-pg-format-db-structure/railtie" if defined?(Rails)
# :nocov:
