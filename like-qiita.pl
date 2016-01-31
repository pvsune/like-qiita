#!/usr/bin/perl
use strict;
use warnings;

use feature qw/say/;

use Furl;
use URI;
use JSON 2 'decode_json';
use DateTime;

my $base = 'https://yoyo-holdings.qiita.com';
my $u = URI->new("$base/api/v2/items");
$u->query_form({
    query => "created:>@{[DateTime->now->subtract(days => 1)->date]} title:daily",
    per_page => 100 });

my $f = Furl->new;
my $auth = [ Authorization => 'Bearer a0edcba12559f9b86a528c25abf302bf493f36ea' ];
my $res = $f->get($u->as_string, $auth);

for ( map { $_={ id => $_->{id}, name => $_->{user}->{id} } }
    @{ decode_json $res->content } ) {

    next if $_->{name} eq 'phil';
    say "Liking @{[$_->{name}]}'s Daily Report...";

    my $u = URI->new("$base/api/v2/items/@{[$_->{id}]}/like");
    my $res = Furl->new->put($u->as_string, $auth);

    ($res->is_success) ? say "OK\n"
        : say "FAILED:@{[(decode_json $res->content)->{message}]}\n";
}
