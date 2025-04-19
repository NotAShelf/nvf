; extends

(binding
  attrpath: (attrpath
    (identifier) @_path)
  expression: [
    (string_expression
      (string_fragment) @injection.content)
    (indented_string_expression
      (string_fragment) @injection.content)
  ]
  (#set! injection.language "lua")
  (#match? @_path "^luaConfig\(Pre\|Post\)$"))

(apply_expression
  function: [
    (variable_expression
      name: (identifier) @funcName
      (#eq? @funcName "mkLuaInline"))
    ;; matches lib.generators.mkLuaInline
    (select_expression
      expression: _ @lib
      (#eq? @lib "lib")
      (attrpath
        attr: (identifier) @generators
        attr: (identifier) @funcName)
        (#eq? @generators "generators"))
  ]
  argument: [
    (string_expression
      (string_fragment) @injection.content)
    (indented_string_expression
      (string_fragment) @injection.content)
  ]
  (#set! injection.language "lua"))

(apply_expression
  function: (apply_expression
    function: [
      (variable_expression
        name: (identifier) @_func)
      ;; matches lib.nvim.bla.bla.entryBefore
      (select_expression
        expression: (variable_expression)
        attrpath: (attrpath
          attr: (identifier) @_func .))
    ]
    argument: _)
  argument: (indented_string_expression
    (string_fragment) @injection.content)
  (#match? @_func "^entry(Anywhere|After|Before)$")
  (#set! injection.language "lua")
  (#set! injection.combined))
