package MyCache;

use strict;
use warnings;
use base qw( Cache::Funky );
use Test::More tests => 3;

MyCache->setup( 'Storage::Simple' => {} );
MyCache->register( 'foo', sub { time } );

my $foo;
like( $foo = MyCache->foo , qr/^\d+$/, "ok get foo() : $foo");
sleep 1;
ok( $foo eq MyCache->foo , "cache ok");
MyCache->delete(qw/foo/);
ok( $foo ne MyCache->foo , "re cache ok");

diag( "Testing Cache::Funky $Cache::Funky::VERSION" );


