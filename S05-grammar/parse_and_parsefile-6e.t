use v6.e.PREVIEW;
use Test;

plan 24;

# tests .parse and .parsefile methods on a grammar

grammar Foo { token TOP { \d+ } }
grammar Bar { token untop { \d+ } }
grammar Baz { token TOP { \d+ \n } }

my Mu \parent = Foo.^mro.first( *.^name eq 'Grammar' );
is parent.^ver, '6.e', 'grammar is created using 6.e version of Grammar class';

ok Foo.parse("abc123xyz") ~~ Failure, ".parse method invokes TOP rule, no match";
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
    lives-ok { RT116597.parse('a') ~~ Failure },
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

{
    my grammar G1 {
        token TOP { [ || [ <line> ]+ ] }
        token line { ^^ '#' \N+ [ \n | $ ] }
    }

    my $res = G1.parse: q:to/BADTEXT/;
                        # l1
                        # l2
                        # l3
                        l4
                        # l5
                        BADTEXT
    ok $res ~~ Failure, "parse failed with Failure";
    my $ex = $res.exception;
    isa-ok $ex, X::Syntax::Confused, "failure exception is X::Syntax::Confused";
    is $ex.line, 3, "parsing failed at line 1";
    is $ex.pos, 14, "pos is 14";
    is ~$ex.pre, "# l3", "pre is '# l3'";
    is ~$ex.post, "<EOL>", "post is <EOL>";
}

# vim: ft=perl6 expandtab sw=4
