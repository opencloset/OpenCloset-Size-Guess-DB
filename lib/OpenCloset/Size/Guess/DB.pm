package OpenCloset::Size::Guess::DB;
# ABSTRACT: OpenCloset::Size::Guess driver for the database

use utf8;

use Moo;
use Types::Standard qw( InstanceOf Str );

our $VERSION = '0.001';

with 'OpenCloset::Size::Guess::Role::Base';

use DateTime;
use Statistics::Basic;
use Try::Tiny;

has range => (
    is      => 'ro',
    default => 1,
);

has schema => (
    is       => 'ro',
    isa      => InstanceOf ['OpenCloset::Schema'],
    required => 1,
);

has time_zone => (
    is       => 'ro',
    isa      => Str,
    required => 1,
);

sub guess {
    my $self = shift;

    my ( $height, $weight ) = ( $self->height, $self->weight );

    my $dt_base = try {
        DateTime->new(
            time_zone => $self->time_zone,
            year      => 2015,
            month     => 5,
            day       => 29,
        );
    };
    return unless $dt_base;

    my $dtf      = $self->schema->storage->datetime_parser;
    my $order_rs = $self->schema->resultset('Order')->search(
        #
        # cond
        #
        {
            -or => [
                {
                    # 대여일이 2015-05-29 이전
                    -and => [
                        { 'booking.date' => { '<' => $dtf->format_datetime($dt_base) }, },
                        \[ "DATE_FORMAT(booking.date, '%H') < ?" => 19 ],
                    ],
                },
                {
                    # 대여일이 2015-05-29 이후
                    -and => [
                        { 'booking.date' => { '>=' => $dtf->format_datetime($dt_base) }, },
                        \[ "DATE_FORMAT(booking.date, '%H') < ?" => 22 ],
                    ],
                },
            ],
            'booking.gender' => $self->gender,
            'height' => { -between => [ $height - $self->range, $height + $self->range ] },
            'weight' => { -between => [ $weight - $self->range, $weight + $self->range ] },
        },
        #
        # attr
        #
        { join => [qw/ booking /] },
    );

    my %item = (
        arm      => [],
        belly    => [],
        bust     => [],
        foot     => [],
        hip      => [],
        knee     => [],
        leg      => [],
        thigh    => [],
        topbelly => [],
        waist    => [],
    );
    while ( my $order = $order_rs->next ) {
        for (
            qw/
            arm
            belly
            bust
            foot
            hip
            knee
            leg
            thigh
            topbelly
            waist
            /
            )
        {
            next unless $order->$_; # remove undef & 0

            push @{ $item{$_} }, $order->$_;
        }
    }
    my %average = (
        arm      => 0,
        belly    => 0,
        bust     => 0,
        foot     => 0,
        hip      => 0,
        knee     => 0,
        leg      => 0,
        thigh    => 0,
        topbelly => 0,
        waist    => 0,
    );
    $average{arm}      = Statistics::Basic::mean( $item{arm} )->query;
    $average{belly}    = Statistics::Basic::mean( $item{belly} )->query;
    $average{bust}     = Statistics::Basic::mean( $item{bust} )->query;
    $average{foot}     = Statistics::Basic::mean( $item{foot} )->query;
    $average{hip}      = Statistics::Basic::mean( $item{hip} )->query;
    $average{knee}     = Statistics::Basic::mean( $item{knee} )->query;
    $average{leg}      = Statistics::Basic::mean( $item{leg} )->query;
    $average{thigh}    = Statistics::Basic::mean( $item{thigh} )->query;
    $average{topbelly} = Statistics::Basic::mean( $item{topbelly} )->query;
    $average{waist}    = Statistics::Basic::mean( $item{waist} )->query;

    return \%average;
}

1;

# COPYRIGHT

__END__

=for Pod::Coverage BUILDARGS

=head1 SYNOPSIS

    use OpenCloset::Schema;
    use OpenCloset::Size::Guess;

    my $DB = OpenCloset::Schema->connect(
        {
            dsn               => 'dbi:mysql:opencloset:127.0.0.1',
            user              => 'opencloset',
            password          => 'opencloset',
            quote_char        => q{`},
            mysql_enable_utf8 => 1,
            on_connect_do     => 'SET NAMES utf8',
        }
    );

    # create a database guesser
    my $guesser = OpenCloset::Size::Guess->new(
        'DB',
        height     => 172,
        weight     => 72,
        gender     => 'male',
        _time_zone => 'Asia/Seoul',
        _schema    => $DB,
    );

    print $guesser->height . "\n";
    print $guesser->weight . "\n";
    print $guesser->gender . "\n";

    # get the body measurement information
    my $info = $guesser->guess;
    print "arm: $info{arm}\n";
    print "belly: $info{belly}\n";
    print "bust: $info{bust}\n";
    print "foot: $info{foot}\n";
    print "hip: $info{hip}\n";
    print "knee: $info{knee}\n";
    print "leg: $info{leg}\n";
    print "thigh: $info{thigh}\n";
    print "topbelly: $info{tobelly}\n";
    print "waist: $info{waist}\n";


=head1 DESCRIPTION

This module is a L<OpenCloset::Size::Guess> driver for the database.


=attr height

=attr weight

=attr gender

=attr range

=attr schema

=attr time_zone


=method guess
