# frozen_string_literal: true

require "pg_query"

module ActiveRecordPgFormatDbStructure
  # Inserts newlines and whitespace on a deparsed SQL string
  class Indenter
    Token = Data.define(:type, :string)

    # Reserved Keywords
    ADD = :ADD_P
    ALTER = :ALTER
    AND = :AND
    AS = :AS
    CASE = :CASE
    CREATE = :CREATE
    CROSS = :CROSS
    DROP = :DROP
    ELSE = :ELSE
    END_P = :END_P
    EXCEPT = :EXCEPT
    FETCH = :FETCH
    FOR = :FOR
    FROM = :FROM
    GROUP = :GROUP_P
    HAVING = :HAVING
    INNER = :INNER
    INSERT = :INSERT
    INTERSECT = :INTERSECT
    JOIN = :JOIN
    LEFT = :LEFT
    LIMIT = :LIMIT
    OFFSET = :OFFSET
    OR = :OR
    ORDER = :ORDER
    RIGHT = :RIGHT
    SELECT = :SELECT
    TABLE = :TABLE
    THEN = :THEN
    UNION = :UNION
    VALUES = :VALUES
    VIEW = :VIEW
    WHEN = :WHEN
    WHERE = :WHERE
    WHITESPACE = :WHITESPACE
    WINDOW = :WINDOW
    WITH = :WITH

    # ASCII tokens
    COMMA = :ASCII_44
    OPEN_PARENS = :ASCII_40
    CLOSE_PARENS = :ASCII_41

    # Helpers
    PARENS = :PARENS
    INDENT_STRING = "  "
    SELECT_PADDING = "   "
    TABLE_ELTS = :TABLE_ELTS

    attr_reader :source

    def initialize(source)
      @source = PgQuery.deparse(PgQuery.parse(source).tree)
    end

    def indent
      output = Output.new
      prev_token = nil
      tokens.each do |token|
        output.current_token = token
        case { current_token: token.type, prev_token: prev_token&.type, inside: output.current_scope_type }
        in { current_token: CREATE, inside: nil }
          output.append_scope(type: CREATE)
          output.append_token
        in { current_token: ALTER, inside: nil }
          output.append_scope(type: ALTER, indent: 1)
          output.append_token
        in { current_token: INSERT, inside: nil }
          output.append_scope(type: INSERT, indent: 0)
          output.append_token
        in { current_token: VIEW, inside: CREATE }
          output.append_scope(type: VIEW, indent: 2)
          output.append_token
        in { current_token: WITH, inside: CREATE | VIEW | nil }
          output.append_scope(type: WITH)
          output.append_token
        in { current_token: WHITESPACE, prev_token: AS, inside: VIEW }
          output.append_token
          output.newline
          output.apply_indent
        in { current_token: WHITESPACE, prev_token: COMMA, inside: WITH | SELECT | TABLE_ELTS }
          output.append_token
          output.newline
          output.apply_indent
        in { current_token: COMMA, inside: INSERT }
          output.newline
          output.apply_indent
          output.append_token
        in { current_token: SELECT, inside: WITH | INSERT }
          output.pop_scope
          output.newline
          output.apply_indent
          output.append_token
          output.append_scope(type: SELECT, indent: 2, padding: SELECT_PADDING)
        in { current_token: SELECT }
          output.append_token
          output.append_scope(type: SELECT, indent: 2, padding: SELECT_PADDING)
        in { current_token: ALTER | ADD | DROP, inside: ALTER }
          output.newline
          output.apply_indent
          output.append_token
        in {
          current_token: CROSS | INNER | LEFT | RIGHT | JOIN => type,
          inside: SELECT | FROM | JOIN
        }
          output.pop_scope
          output.newline
          output.apply_indent
          output.append_token
          output.append_scope(type:, indent: 0)
        in {
          current_token: CROSS | INNER | LEFT | RIGHT | JOIN => type,
          inside: CROSS | INNER | LEFT | RIGHT
        }
          output.append_token
          output.pop_scope
          output.append_scope(type:, indent: 0)
        in { current_token: WHERE, inside: PARENS }
          output.append_token
        in {
          current_token: FROM | WHERE | GROUP | ORDER | WINDOW | HAVING | LIMIT | OFFSET | FETCH | FOR | UNION |
            INTERSECT | EXCEPT => token_type
        }
          output.pop_scope
          output.newline
          output.apply_indent
          output.append_token
          output.append_scope(type: token_type, indent: 1)
        in { current_token: OR | AND, inside: WHERE }
          output.newline
          output.apply_indent
          output.append_token(rjust: 3)
        in { current_token: CASE }
          output.append_token
          output.append_scope(type: CASE, indent: 1, padding: output.current_padding)
        in { current_token: WHEN | ELSE, inside: CASE }
          output.newline
          output.apply_indent
          output.append_token
        in { current_token: END_P }
          output.pop_scope
          output.newline
          output.apply_indent
          output.append_token
        in { current_token: VALUES, inside: INSERT }
          output.append_token
          output.newline
          output.append_whitespace
        in { current_token: OPEN_PARENS, inside: CREATE }
          output.append_token
          output.newline
          output.append_scope(type: TABLE_ELTS, indent: 2)
          output.apply_indent
        in { current_token: OPEN_PARENS, inside: WITH }
          output.append_token
          output.newline
          output.append_scope(type: PARENS, indent: 2)
          output.apply_indent
        in { current_token: OPEN_PARENS, inside: JOIN }
          output.append_token
          output.newline
          output.append_scope(type: PARENS, indent: 2)
          output.apply_indent
        in { current_token: OPEN_PARENS }
          output.append_scope(type: PARENS)
          output.append_token
        in { current_token: CLOSE_PARENS, inside: TABLE_ELTS }
          output.pop_scope
          output.newline
          output.apply_indent
          output.append_token
        in { current_token: CLOSE_PARENS, inside: PARENS }
          output.pop_scope
          output.append_token
        in { current_token: CLOSE_PARENS }
          loop do
            break if output.pop_scope in PARENS | nil
          end
          output.newline
          output.apply_indent
          output.append_token
        else
          output.append_token
        end
        prev_token = token
      end
      output.to_s
    end

    private

    def tokens
      tmp_tokens = []
      prev_token = Data.define(:end).new(0)
      PgQuery.scan(source).first.tokens.each do |token|
        if prev_token.end != token.start
          tmp_tokens << Token.new(
            type: WHITESPACE,
            string: " "
          )
        end
        prev_token = token
        tmp_tokens << Token.new(
          type: token.token,
          string: source[token.start...token.end]
        )
      end
      tmp_tokens
    end

    # Wrapper that ensures we only append whitespace, and always
    # append the current token exactly once for each loop.
    class Output
      Scope = Data.define(:type, :indent, :padding)

      def initialize
        @string = +""
        @scopes = [Scope.new(type: nil, indent: 0, padding: "")]
        @current_token = nil
      end

      def to_s
        # clean extra whitespace at end of string
        @string.gsub(/\s+\n/, "\n").freeze
      end

      def current_scope_type
        @scopes.last.type
      end

      def current_token=(token)
        raise "Previous token was not appended!" unless @current_token.nil?

        @current_token = token
      end

      def append_scope(type:, indent: 0, padding: "")
        @scopes << Scope.new(type:, indent:, padding:)
      end

      def current_padding
        @scopes.last.padding
      end

      def pop_scope
        @scopes.pop.type
      end

      def newline
        @string << "\n"
      end

      def append_whitespace
        @string << " "
      end

      def apply_indent
        @string << (INDENT_STRING * @scopes.sum(&:indent))
        @string << @scopes.last.padding
      end

      def append_token(rjust: 0)
        raise "Token was already appended!" if @current_token.nil?

        @string << @current_token.string.rjust(rjust)
        @current_token = nil
      end
    end
  end
end
