use strict;
use warnings;

use 5.010;

use ExtUtils::MakeMaker 6.17;

my %WriteMakefileArgs = (
  "ABSTRACT" => "OpenCloset::Size::Guess driver for the database",
  "AUTHOR" => "\x{d64d}\x{d615}\x{c11d} - Hyungsuk Hong <aanoaa\@cpan.org>",
  "CONFIGURE_REQUIRES" => {
    "ExtUtils::MakeMaker" => "6.17"
  },
  "DISTNAME" => "OpenCloset-Size-Guess-DB",
  "LICENSE" => "perl",
  "MIN_PERL_VERSION" => "5.010",
  "NAME" => "OpenCloset::Size::Guess::DB",
  "PREREQ_PM" => {
    "DateTime" => 0,
    "Moo" => 0,
    "OpenCloset::Schema" => "0.012",
    "OpenCloset::Size::Guess" => "0.002",
    "OpenCloset::Size::Guess::Role::Base" => 0,
    "Statistics::Basic" => 0,
    "Try::Tiny" => 0,
    "Types::Standard" => 0,
    "utf8" => 0
  },
  "TEST_REQUIRES" => {
    "ExtUtils::MakeMaker" => 0,
    "File::Spec" => 0,
    "OpenCloset::Schema" => "0.012",
    "Test::More" => 0,
    "strict" => 0,
    "warnings" => 0
  },
  "VERSION" => "0.009",
  "test" => {
    "TESTS" => "t/*.t"
  }
);


my %FallbackPrereqs = (
  "DateTime" => 0,
  "ExtUtils::MakeMaker" => 0,
  "File::Spec" => 0,
  "Moo" => 0,
  "OpenCloset::Schema" => "0.012",
  "OpenCloset::Size::Guess" => "0.002",
  "OpenCloset::Size::Guess::Role::Base" => 0,
  "Statistics::Basic" => 0,
  "Test::More" => 0,
  "Try::Tiny" => 0,
  "Types::Standard" => 0,
  "strict" => 0,
  "utf8" => 0,
  "warnings" => 0
);


unless ( eval { ExtUtils::MakeMaker->VERSION(6.63_03) } ) {
  delete $WriteMakefileArgs{TEST_REQUIRES};
  delete $WriteMakefileArgs{BUILD_REQUIRES};
  $WriteMakefileArgs{PREREQ_PM} = \%FallbackPrereqs;
}

delete $WriteMakefileArgs{CONFIGURE_REQUIRES}
  unless eval { ExtUtils::MakeMaker->VERSION(6.52) };

WriteMakefile(%WriteMakefileArgs);
