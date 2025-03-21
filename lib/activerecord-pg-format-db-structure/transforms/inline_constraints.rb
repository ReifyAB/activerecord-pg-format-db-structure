# frozen_string_literal: true

require_relative "base"

module ActiveRecordPgFormatDbStructure
  module Transforms
    # Inline non-foreign key constraints into table declaration
    class InlineConstraints < Base
      def transform!
        tables_with_constraint = extract_constraints_to_inline!
        raw_statements.each do |raw_statement|
          next unless raw_statement.stmt.to_h in create_stmt: { relation: { schemaname:, relname: }}

          relation = { schemaname:, relname: }
          next unless tables_with_constraint.include?(relation)

          tables_with_constraint[relation].each do |constraint|
            add_constraint!(raw_statement, constraint)
          end
        end
      end

      private

      def extract_constraints_to_inline!
        tables_with_constraint = {}
        raw_statements.delete_if do |raw_statement|
          next unless match_alter_column_statement(raw_statement) in { table:, constraint: }

          tables_with_constraint[table] ||= []
          tables_with_constraint[table] << constraint

          true
        end
        tables_with_constraint
      end

      def match_alter_column_statement(raw_statement)
        return unless raw_statement.stmt.to_h in {
          alter_table_stmt: {
            objtype: :OBJECT_TABLE,
            relation: {
              schemaname:,
              relname:
            },
            cmds: [{
              alter_table_cmd: {
                subtype: :AT_AddConstraint,
                def: { constraint: },
                behavior: :DROP_RESTRICT
              }
            }]
          }
        }

        # Skip foreign keys
        return if constraint in contype: :CONSTR_FOREIGN

        {
          table: { schemaname:, relname: },
          constraint:
        }
      end

      def add_constraint!(raw_statement, constraint)
        raw_statement.stmt.create_stmt.table_elts << PgQuery::Node.from(
          PgQuery::Constraint.new(constraint.merge(skip_validation: nil))
        )
      end
    end
  end
end
