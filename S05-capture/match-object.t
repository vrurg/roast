use v6;
use Test;

# this file should become the test for systematically testing
# Match objects. Exception: .caps and .chunks are tested in caps.t

plan 18;

ok 'ab12de' ~~ /\d+/,           'match successful';
is $/.WHAT.gist, Match.gist,    'got right type';
ok $/.Bool,                     '.Bool';
ok $/.defined,                  '.defined';
is $/.Str,         '12',        '.Str';
is $/.from,           2,        '.from';
is $/.to,             4,        '.to';
#?niecza skip 'Unable to resolve method prematch in class Match'
is $/.prematch,    'ab',        '.prematch';
#?niecza skip 'Unable to resolve method postmatch in class Match'
is $/.postmatch,   'de',        '.postmatch';
#?niecza todo
is $/.list.elems,     0,        '.list (empty)';
is $/.hash.elems,     0,        '.hash (empty)';
is $/.keys.elems,     0,        '.keys (empty)';
#?niecza todo
is $/.values.elems,   0,        '.values (empty)';
#?niecza todo
is $/.pairs.elems,    0,        '.pairs (empty)';
#?niecza todo
is $/.kv.elems,       0,        '.kv (empty)';

nok 'abde' ~~ /\d/,             'no match';
nok $/.Bool,                    'failed match is False';
is  $/.Str,          '',        'false match stringifies to empty string';
