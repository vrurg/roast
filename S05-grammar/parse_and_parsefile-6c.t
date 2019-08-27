use v6.c;
use Test;

plan 17;

# tests .parse and .parsefile methods on a grammar

grammar Foo { token TOP { \d+ } }
grammar Bar { token untop { \d+ } }
grammar Baz { token TOP { \d+ \n } }

is Foo.parse("abc123xyz"), Nil, ".parse method invokes TOP rule, no match";
is(~Foo.parse("123"), "123",  ".parse method invokes TOP rule, match");
nok(Foo.parse("123xyz"),  ".parse method requires match to end");
is(~Foo.subparse("123xyz"), "123",  ".subparse method doesn't require match to end");
dies-ok({ Bar.parse("abc123xyz") }, "dies if no TOP rule");


#?rakudo.js.browser skip 'writing to a file is not supported in the browser'
{
  my $fh = open("parse_and_parsefile_test", :w);
  $fh.say("abc\n123\nxyz");
  $fh.close();
  nok(Foo.parsefile("parse_and_parsefile_test"), ".parsefile method invokes TOP rule, no match");
  unlink("parse_and_parsefile_test");

  $fh = open("parse_and_parsefile_test", :w);
  $fh.say("123");
  $fh.close();
  is(~Baz.parsefile("parse_and_parsefile_test"), "123\n",  ".parsefile method invokes TOP rule, match");
  dies-ok({ Bar.parsefile("parse_and_parsefile_test") }, "dies if no TOP rule");
  dies-ok({ Foo.parsefile("non_existent_file") },        "dies if file not found");

  unlink("parse_and_parsefile_test");
}


grammar A::B {
    token TOP { \d+ }
}
nok(A::B.parse("zzz42zzz"), ".parse works with namespaced grammars, no match");
is(~A::B.parse("42"), "42", ".parse works with namespaced grammars, match");

# TODO: Check for a good error message, not just the absence of a bad one.
throws-like '::No::Such::Grammar.parse()', Exception, '.parse on missing grammar dies';

# RT #71062
{
    grammar Integer { rule TOP { x } };
    lives-ok { Integer.parse('x') }, 'can .parse grammar named "Integer"';
}

# RT #76884
{
    grammar grr {
        token TOP {
            <line>*
        }
        token line { .* \n }
    }

    my $match = grr.parse('foo bar asd');
    ok $match[0].perl, 'empty match is perlable, not Null PMC access';
}

# RT #116597
{
    grammar RT116597 {
        token TOP() { <lit 'a'> };
        token lit($s) { $s };
    }
    lives-ok { RT116597.parse('a') },
        'can use <rule "param"> form of rule invocation in grammar';
}

# RT #111768
{
    grammar RT111768 {
        token e {
            | 'a' <e> { make ';' ~ $<e>.ast }
            | ';'     { make 'a' }
        }
    }
    is RT111768.parse("aaaa;", :rule<e>).ast, ';;;;a', "Recursive .ast calls work";
}

# RT #130081
{
    my grammar G { regex TOP { ‘a’ || ‘abc’ } };
    is G.parse(‘abc’), 'abc', 'A regex TOP will be backtracked into to get a long enough match';
}

# vim: ft=perl6 expandtab sw=4
