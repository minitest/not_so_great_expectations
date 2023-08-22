require 'English'
require 'rainbow'

require 'forwardable'
require 'regexp_parser'
require 'set'
require 'unicode/display_width'

# we have to require RuboCop's version, before rubocop-ast's
require 'rubocop/version'
require 'rubocop-ast'

require 'rubocop/ast_aliases'
require 'rubocop/ext/comment'
require 'rubocop/ext/range'
require 'rubocop/ext/regexp_node'
require 'rubocop/ext/regexp_parser'

# require 'rubocop/core_ext/string'
require 'rubocop/ext/processed_source'
#
require 'rubocop/error'
require 'rubocop/file_finder'
# require 'rubocop/file_patterns'
# require 'rubocop/name_similarity'
require 'rubocop/path_util'
# require 'rubocop/platform'
# require 'rubocop/string_interpreter'
require 'rubocop/util'
# require 'rubocop/warning'
#
# require 'rubocop/cop/util'
require 'rubocop/cop/offense'
require 'rubocop/cop/message_annotator'
require 'rubocop/cop/ignored_node'
require 'rubocop/cop/autocorrect_logic'
require 'rubocop/cop/exclude_limit'
require 'rubocop/cop/badge'
require 'rubocop/cop/registry'
require 'rubocop/cop/base'
# require 'rubocop/cop/cop'
require 'rubocop/cop/commissioner'
# require 'rubocop/cop/documentation'
# require 'rubocop/cop/corrector'
# require 'rubocop/cop/force'
require 'rubocop/cop/severity'
# require 'rubocop/cop/generator'
# require 'rubocop/cop/generator/configuration_injector'
# require 'rubocop/cop/generator/require_file_injector'
# require 'rubocop/magic_comment'
#
# require 'rubocop/cop/variable_force'
# require 'rubocop/cop/variable_force/branch'
# require 'rubocop/cop/variable_force/branchable'
# require 'rubocop/cop/variable_force/variable'
# require 'rubocop/cop/variable_force/assignment'
# require 'rubocop/cop/variable_force/reference'
# require 'rubocop/cop/variable_force/scope'
# require 'rubocop/cop/variable_force/variable_table'
#
# require 'rubocop/cop/mixin/array_min_size'
# require 'rubocop/cop/mixin/array_syntax'
# require 'rubocop/cop/mixin/alignment'
# require 'rubocop/cop/mixin/allowed_identifiers'
# require 'rubocop/cop/mixin/allowed_methods'
# require 'rubocop/cop/mixin/allowed_pattern'
# require 'rubocop/cop/mixin/allowed_receivers'
require 'rubocop/cop/mixin/auto_corrector' # rubocop:todo Naming/InclusiveLanguage
# require 'rubocop/cop/mixin/check_assignment'
# require 'rubocop/cop/mixin/check_line_breakable'
# require 'rubocop/cop/mixin/configurable_max'
# require 'rubocop/cop/mixin/code_length' # relies on configurable_max
# require 'rubocop/cop/mixin/configurable_enforced_style'
# require 'rubocop/cop/mixin/configurable_formatting'
# require 'rubocop/cop/mixin/configurable_naming'
# require 'rubocop/cop/mixin/configurable_numbering'
# require 'rubocop/cop/mixin/documentation_comment'
# require 'rubocop/cop/mixin/duplication'
# require 'rubocop/cop/mixin/range_help'
# require 'rubocop/cop/mixin/annotation_comment' # relies on range
# require 'rubocop/cop/mixin/empty_lines_around_body' # relies on range
# require 'rubocop/cop/mixin/empty_parameter'
# require 'rubocop/cop/mixin/end_keyword_alignment'
# require 'rubocop/cop/mixin/enforce_superclass'
# require 'rubocop/cop/mixin/first_element_line_break'
# require 'rubocop/cop/mixin/frozen_string_literal'
# require 'rubocop/cop/mixin/gem_declaration'
# require 'rubocop/cop/mixin/gemspec_help'
# require 'rubocop/cop/mixin/hash_alignment_styles'
# require 'rubocop/cop/mixin/hash_transform_method'
# require 'rubocop/cop/mixin/integer_node'
# require 'rubocop/cop/mixin/interpolation'
# require 'rubocop/cop/mixin/line_length_help'
# require 'rubocop/cop/mixin/match_range'
# require 'rubocop/cop/metrics/utils/repeated_csend_discount'
# require 'rubocop/cop/metrics/utils/repeated_attribute_discount'
# require 'rubocop/cop/mixin/hash_shorthand_syntax'
# require 'rubocop/cop/mixin/method_complexity'
# require 'rubocop/cop/mixin/method_preference'
# require 'rubocop/cop/mixin/min_body_length'
# require 'rubocop/cop/mixin/min_branches_count'
# require 'rubocop/cop/mixin/multiline_element_indentation'
# require 'rubocop/cop/mixin/multiline_element_line_breaks'
# require 'rubocop/cop/mixin/multiline_expression_indentation'
# require 'rubocop/cop/mixin/multiline_literal_brace_layout'
# require 'rubocop/cop/mixin/negative_conditional'
# require 'rubocop/cop/mixin/heredoc'
# require 'rubocop/cop/mixin/nil_methods'
# require 'rubocop/cop/mixin/on_normal_if_unless'
# require 'rubocop/cop/mixin/ordered_gem_node'
# require 'rubocop/cop/mixin/parentheses'
# require 'rubocop/cop/mixin/percent_array'
# require 'rubocop/cop/mixin/percent_literal'
# require 'rubocop/cop/mixin/preceding_following_alignment'
# require 'rubocop/cop/mixin/preferred_delimiters'
# require 'rubocop/cop/mixin/rational_literal'
# require 'rubocop/cop/mixin/require_library'
# require 'rubocop/cop/mixin/rescue_node'
# require 'rubocop/cop/mixin/safe_assignment'
# require 'rubocop/cop/mixin/space_after_punctuation'
# require 'rubocop/cop/mixin/space_before_punctuation'
# require 'rubocop/cop/mixin/surrounding_space'
# require 'rubocop/cop/mixin/statement_modifier'
# require 'rubocop/cop/mixin/string_help'
# require 'rubocop/cop/mixin/string_literals_help'
# require 'rubocop/cop/mixin/symbol_help'
# require 'rubocop/cop/mixin/target_ruby_version'
# require 'rubocop/cop/mixin/trailing_body'
# require 'rubocop/cop/mixin/trailing_comma'
# require 'rubocop/cop/mixin/uncommunicative_name'
# require 'rubocop/cop/mixin/unused_argument'
# require 'rubocop/cop/mixin/visibility_help'
# require 'rubocop/cop/mixin/comments_help' # relies on visibility_help
# require 'rubocop/cop/mixin/def_node' # relies on visibility_help
#
# require 'rubocop/cop/utils/format_string'
# require 'rubocop/cop/utils/regexp_ranges'

# require 'rubocop/cop/correctors/alignment_corrector'
# require 'rubocop/cop/correctors/condition_corrector'
# require 'rubocop/cop/correctors/each_to_for_corrector'
# require 'rubocop/cop/correctors/empty_line_corrector'
# require 'rubocop/cop/correctors/for_to_each_corrector'
# require 'rubocop/cop/correctors/if_then_corrector'
# require 'rubocop/cop/correctors/lambda_literal_to_method_corrector'
# require 'rubocop/cop/correctors/line_break_corrector'
# require 'rubocop/cop/correctors/multiline_literal_brace_corrector'
# require 'rubocop/cop/correctors/ordered_gem_corrector'
# require 'rubocop/cop/correctors/parentheses_corrector'
# require 'rubocop/cop/correctors/percent_literal_corrector'
# require 'rubocop/cop/correctors/punctuation_corrector'
# require 'rubocop/cop/correctors/require_library_corrector'
# require 'rubocop/cop/correctors/space_corrector'
# require 'rubocop/cop/correctors/string_literal_corrector'
# require 'rubocop/cop/correctors/unused_arg_corrector'

require 'rubocop/cop/team'
require 'rubocop/formatter'
#
# require 'rubocop/cached_data'
require 'rubocop/config'
# require 'rubocop/config_loader_resolver'
require 'rubocop/config_loader'
require 'rubocop/config_obsoletion/rule'
require 'rubocop/config_obsoletion/cop_rule'
require 'rubocop/config_obsoletion/parameter_rule'
require 'rubocop/config_obsoletion/changed_enforced_styles'
require 'rubocop/config_obsoletion/changed_parameter'
require 'rubocop/config_obsoletion/extracted_cop'
require 'rubocop/config_obsoletion/removed_cop'
require 'rubocop/config_obsoletion/renamed_cop'
require 'rubocop/config_obsoletion/split_cop'
require 'rubocop/config_obsoletion'
# require 'rubocop/config_store'
require 'rubocop/config_validator'
# require 'rubocop/feature_loader'
# require 'rubocop/lockfile'
# require 'rubocop/target_finder'
# require 'rubocop/directive_comment'
require 'rubocop/comment_config'
# require 'rubocop/result_cache'
require 'rubocop/runner'
# require 'rubocop/cli'
# require 'rubocop/cli/command'
# require 'rubocop/cli/environment'
# require 'rubocop/cli/command/base'
# require 'rubocop/cli/command/auto_generate_config'
# require 'rubocop/cli/command/execute_runner'
# require 'rubocop/cli/command/init_dotfile'
# require 'rubocop/cli/command/lsp'
# require 'rubocop/cli/command/show_cops'
# require 'rubocop/cli/command/show_docs_url'
# require 'rubocop/cli/command/suggest_extensions'
# require 'rubocop/cli/command/version'
# require 'rubocop/config_regeneration'
# require 'rubocop/options'
# require 'rubocop/remote_config'
require 'rubocop/target_ruby'
# require 'rubocop/yaml_duplication_checker'