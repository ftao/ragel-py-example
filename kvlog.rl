'''
Parse k-v pairs
'''
cache = []
lineno = 0
current_line = {}
current_k = []
current_v = []

class FSM:
    def __init__(self, data):
        self.data = data

%%{
    machine kvlog;
    access fsm.;

    action save_vchar {
        current_v.append(chr(fc))
    }

    action save_kchar {
        current_k.append(chr(fc))
    }

    action newline {
        lineno += 1 
        cache.append(current_line)
        current_line = {}
    }

    action new_key {
        pass
    }
    action new_value {
        pass
    }
    action new_kv {
        current_line[''.join(current_k)] = ''.join(current_v)
        current_k = current_v = []
    }



    plainv =  (any - space - /['"]/)+  $save_vchar @new_value ;
    squotev = "'" . ( /[^\n\r\']*/  $save_vchar @new_value ). "'";
    dquotev = '"' . ( /[^\n\r\"]*/  $save_vchar @new_value ). '"';
    kv = ( /[a-zA-Z_][a-zA-Z0-9_]*/ $save_kchar  @new_key ) . "=" .  ( plainv | squotev | dquotev ) @new_kv;
    line = ( [ \t]* . kv )* . [ \t]* . '\n' @newline;
    main :=  line*;

}%%

import sys
fsm = FSM(sys.stdin.read())

%% write data;

%% write init;

p = 0
pe = len(fsm.data)

%% write exec;

for item in cache:
    print item
