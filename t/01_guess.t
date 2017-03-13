use strict;
use warnings;
use Test::More;

use OpenCloset::Schema;

use_ok('OpenCloset::Size::Guess');

my $db = {
    dsn  => $ENV{OPENCLOSET_DATABASE_DSN}  || "dbi:mysql:opencloset:127.0.0.1",
    name => $ENV{OPENCLOSET_DATABASE_NAME} || 'opencloset',
    user => $ENV{OPENCLOSET_DATABASE_USER} || 'opencloset',
    pass => $ENV{OPENCLOSET_DATABASE_PASS} // 'opencloset',
    opts => {
        quote_char        => q{`},
        mysql_enable_utf8 => 1,
        on_connect_do     => 'SET NAMES utf8',
        RaiseError        => 1,
        AutoCommit        => 1,
    },
};

my $schema = OpenCloset::Schema->connect(
    {
        dsn      => $db->{dsn},
        user     => $db->{user},
        password => $db->{pass},
        %{ $db->{opts} },
    }
);

my $guess = OpenCloset::Size::Guess->new(
    'DB',
    height     => 168,
    weight     => 57,
    gender     => 'male',
    _time_zone => 'Asia/Seoul',
    _schema    => $schema,

    _waist    => 78,
    _bust     => 85,
    _topbelly => 75,
);

my $info = $guess->guess;
like( $info->{height}, qr/168/, 'height' );
like( $info->{weight}, qr/57/,  'weight' );

cmp_ok( $info->{waist},    '>', 78 - 1, 'waist' );
cmp_ok( $info->{waist},    '<', 78 + 1, 'waist' );
cmp_ok( $info->{bust},     '>', 85 - 1, 'bust' );
cmp_ok( $info->{bust},     '<', 85 + 1, 'bust' );
cmp_ok( $info->{topbelly}, '>', 75 - 1, 'topbelly' );
cmp_ok( $info->{topbelly}, '<', 75 + 1, 'topbelly' );
ok( $info->{arm},   'arm' );
ok( $info->{leg},   'leg' );
ok( $info->{thigh}, 'thigh' );

done_testing();
