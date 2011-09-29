use v6;
use Test;
plan 6;

#L<S03/"Smart matching"/Array Hash hash slice existence>
{
    my %h = (a => 'b', c => Mu);
    #?niecza todo
    ok  (['a']      ~~ %h), 'Array ~~ Hash (exists and True)';
    #?niecza todo
    ok  (['c']      ~~ %h), 'Array ~~ Hash (exists but Mu)';
    #?rakudo 2 todo 'nom regression'
    #?niecza todo
    ok  ([<a c>]    ~~ %h), 'Array ~~ Hash (both exist)';
    #?niecza todo
    ok  ([<c d>]    ~~ %h), 'Array ~~ Hash (one exists)';
    # note that ?any() evaluates to False
    ok !( ()        ~~ %h), 'Array ~~ Hash (empty list)';
    ok !(['e']      ~~ %h), 'Array ~~ Hash (not exists)';

}

done;

# vim: ft=perl6
