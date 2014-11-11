grammar ConfigurationFile;

configuration
    :    setting_list
    ;

setting_list
    :    setting+
    ;

setting
    :    NAME (':' | '=') value (';' | ',')?
    ;

value
    :    scalar_value | array | list | group
    ;

value_list
    :    value (',' value)*
    ;

scalar_value
    :    BOOLEAN
    |    INTEGER
    |    INTEGER64
    |    HEX
    |    HEX64
    |    FLOAT
    |    STRING+
    ;

scalar_value_list
    :    scalar_value (',' scalar_value)*
    ;

array
    :    '[' scalar_value_list? ']'
    ;

list
    :    '(' value_list? ')'
    ;

group
    :    '{' setting_list? '}'
    ;

BOOLEAN
    :    ('T'|'t')('R'|'r')('U'|'u')('E'|'e')
    |    ('F'|'f')('A'|'a')('L'|'l')('S'|'s')('E'|'e')
    ;

fragment ESCAPE_SEQUENCE
    :    '\\' ('\\' | '"' | 't' | 'n' | 'r')
    ;

STRING
    :    '"' (ESCAPE_SEQUENCE | ~('"' | '\\'))* '"'
    ;

NAME
    :    ('A'..'Z'|'a'..'z'|'*') ('-'|'A'..'Z'|'a'..'z'|'0'..'9'|'_'|'*')*
    ;

fragment DIGITS
    :    ('-'|'+')? ('0'..'9')+
    ;

INTEGER
    :    DIGITS
    ;

INTEGER64
    :    DIGITS 'L' 'L'?
    ;

fragment HEXDIGITS
    :    '0' ('X'|'x') ('0'..'9'|'A'..'F'|'a'..'f')+
    ;

HEX
    :    HEXDIGITS
    ;

HEX64
    :    HEXDIGITS 'L' 'L'?
    ;

FLOAT
    :     ('-'|'+')? ('0'..'9')* ('.' ('0'..'9')*)? (('e'|'E') ('-'|'+')? ('0'..'9')+)?
    ;

/* Ignore white space */
WS
    :    (' '|'\t'|'\f'|'\n'|'\r')+ { skip(); }
    ;

ML_COMMENT
    :    '/*' .* '*/' { skip(); }
    ;

OL_COMMENT
    :    '#' ~( '\r' | '\n' )* { skip(); }
    |    '//' ~( '\r' | '\n' )* { skip(); }
    ;
