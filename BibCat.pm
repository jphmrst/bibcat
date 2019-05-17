#
# BibCat --- BibTeX-to-catalog-listing converter for finding stuff
#
# (C) 2019, John Maraist, licensed under GPL3, see file included

package BibCat::BibCat;
{
  $BibCat::VERSION = '0.01';
}
use warnings;
use strict;

use BibTeX::Parser;
use IO::File;

sub new {
  my $class = shift;
  my $this = bless {
    strings => {  ## Hack around how BibTeX::Parser likes one file only
      jan => "January",
      feb => "February",
      mar => "March",
      apr => "April",
      may => "May",
      jun => "June",
      jul => "July",
      aug => "August",
      sep => "September",
      oct => "October",
      nov => "November",
      dec => "December",
    },
    entries => [],
    tag => "loc",
    lines => 0,
    verbose => 0,
    nosubtitles => 1
  }, $class;
  $this->load(@_);
  return $this;
}

sub load {
  my $this = shift;
  while (my $file = shift) {
    print "- Parsing $file\n" if $this->{verbose};
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
  print("Writing to $fname\n");
  my $maxLines = $self->{lines};
  my $nosubtitles = $self->{nosubtitles};

  open OUT, ">$fname";
  print OUT '
\documentclass{article}
\usepackage{supertabular}
\usepackage[margin=0.3in,bottom=0.6in]{geometry}
\parindent 0pt
\parskip 0pt
\begin{document}
';

  if ($maxLines<1) {
    print OUT "\\begin{supertabular}{ll}\n";
  }

  my @entries = sort sorter @{$self->{entries}};
  my $lines = 0;
  foreach my $en (@entries) {
    my $loc = $en->field($self->{tag});
    next unless defined $loc;

    print OUT "\\begin{tabular}{ll}\n"  if $maxLines>0 && $lines==0;
    print OUT ('\texttt{', $loc, '}&');
    my @authors = $en->author;
    my @editors = $en->editor;
    if (exists $authors[0]) {
      print OUT ($authors[0]->last);
      if ($#authors == 1) {
        print OUT (' and ', $authors[1]->last);
      } elsif ($#authors>1) {
        print OUT (' \emph{et al.}');
      }
      print OUT (', ');
    } elsif (exists $editors[0]) {
      print OUT ($editors[0]->last);
      if ($#editors == 1) {
        print OUT (' and ', $editors[1]->last);
      } elsif ($#editors>1) {
        print OUT (' \emph{et al.}');
      }
      print OUT (" (ed");
      print OUT ("s") if $#editors>0;
      print OUT (".), ");
    } else {
    }
    my $title = $en->field("title");
    $title =~ s/:.*$// if $nosubtitles;
    $title =~ s/Proceedings of the /Proc.\\ /;
    $title =~ s/(International )?Conference ((on|of|for)( the)? )?//;
    print OUT ('\emph{', $title, "}, ", $en->field("year"));
    print OUT ("\\\\\n");
    $lines += 1;

    if ($maxLines>0 && $lines==$maxLines) {
      print OUT "\\end{tabular}\n\\clearpage\n\n";
      $lines = 0;
    }
  }

  if ($maxLines<1) {
    print OUT "\\end{supertabular}{ll}\n";
  } elsif ($maxLines>0 && $lines>0) {
    print OUT "\\end{tabular}\n";
  }

  print OUT "\\end{document}\n";

  close OUT;
}

sub sorter { # args $a $b
  my @authorsA = $a->author;
  my @authorsB = $b->author;
  if ($#authorsB > -1) {
    if ($#authorsA > -1) {

      ## They both have authors, so compare them
      my $max = $#authorsA;
      $max = $#authorsB  if $#authorsB>$max;

      for(my $i=0; $i<=$max; $i++) {
        return -1  unless defined $authorsA[$i];
        return 1   unless defined $authorsB[$i];

        my $cmp = $authorsA[$i]->last cmp $authorsB[$i]->last;
        return $cmp  unless $cmp == 0;
      }

      ## Authors the same, use the titles
      return $a->field("title") cmp $b->field("title");
    } else {
      ## B has authors, not A
      return -1;
    }
  } else {
    if ($#authorsA > -1) {
      ## A has authors, not B
      return 1;
    } else {
      ## Neither has authors, so use the titles
      return $a->field("title") cmp $b->field("title");
    }
  }

}

1;

__END__
=head1 NAME

BibCat::BibCat - Format a catalog-style list of the references in BibTeX files

=head1 SYNOPSIS

There is no associated script.  Write your own very short one like this:

  #!/usr/bin/env perl

  use strict;
  use Carp;
  use FindBin;
  use lib (($FindBin::Bin)); ## Assumes BibCat dir in the same dir as script
  use BibCat::BibCat;

  my $bc = new BibCat::BibCat('file1.bib', 'file2.bib');
  $bc->write('out/catalog.tex');
  exit(0);

=head2 Other tweaks and switches

(Using the above as an example)

Set the slot tag to change the field which BibCat uses in the left
column:

  $bc->{tag} = 'month';

Set the slot verbose to a positive integer to get debugging output.

By default the output uses the supertabular environment.  Sometimes
supertabular does the wrong thing.  To use the tabular environment and
explicit pagebreaks instead, set the lines field to a postive value of
the number of lines that should be on one page.

  $bc->{lines} = 60;

By default a colon and any characters following it will be removed
from the title.  To keep subtitles, set the nosubtitles slot to 0 (its
default is 1).

  $bc->{nosubtitles} = 0;

