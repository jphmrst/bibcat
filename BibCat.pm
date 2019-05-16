#
# BibCat --- BibTeX-to-catalog-listing converter for finding stuff
#
# (C) 2019, John Maraist, licensed under GPL3, see file included

package BibCat;
{
  $BibCat::VERSION = '0.01';
}
use warnings;
use strict;

use BibTeX::Parser;
use IO::File;

our $verbose=0;

sub new {
  my $class = shift;
  my $this = bless {
    entries => [],
    tag => "loc"
  }, $class;
  $this->load(@_);
  return $this;
}

sub load {
  my $this = shift;
  while (my $file = shift) {
    print "- Parsing $file\n" if $verbose>1;
    my $fh     = IO::File->new($file);
    my $parser = BibTeX::Parser->new($fh);
    $parser->{strings} = $this->{strings};
    while (my $entry = $parser->next) {
      if ($entry->parse_ok) {
        push @{$this->{entries}}, $entry;
      } else {
        warn "Error parsing $file: " . $entry->error;
      }
    }
  }
}

sub write {
  my $self = shift;
  my $fname = shift;
  # open OUT, ">$fname";

  my @entries = sort sorter @{$self->{entries}};

  # close OUT;
}

sub sorter { # args $a $b
  my @authorsA = $a->author;
  my @authorsB = $b->author;
  if (defined @authorsB && $#authorsB > -1) {
    if (defined @authorsA && $#authorsA > -1) {

      ## They both have authors, so compare them
      my $max = $#authorsA;
      $max = $#authorsB  if $#authorsB>$max;

      for(my $i=0; $i<=$max; $i++) {
        return -1  unless defined $authorsA[$i];
        return 1   unless defined $authorsB[$i];

        my $cmp = $authorsA[$i] cmp $authorsB[$i];
        return $cmp  unless $cmp == 0;
      }

      ## Authors the same, use the titles
      return $a->field("title") cmp $b->field("title");
    } else {
      ## B has authors, not A
      return 1;
    }
  } else {
    if (defined @authorsA && $#authorsA > -1) {
      ## A has authors, not B
      return -1;
    } else {
      ## Neither has authors, so use the titles
      return $a->field("title") cmp $b->field("title");
    }
  }

}

1;
