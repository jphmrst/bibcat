# NAME

BibCat::BibCat - Format a catalog-style list of the references in BibTeX files

# SYNOPSIS

There is no associated script.  Write your own very short one like this:

```perl
#!/usr/bin/env perl

use strict;
use Carp;
use FindBin;
use lib (($FindBin::Bin)); ## Assumes BibCat dir in the same dir as script
use BibCat::BibCat;

my $bc = new BibCat::BibCat('file1.bib', 'file2.bib');
$bc->write('out/catalog.tex');
exit(0);
```

## Other tweaks and switches

(Using the above as an example)

Set the slot tag to change the field which BibCat uses in the left
column:

```
$bc->{tag} = 'month';
```

Set the slot verbose to a positive integer to get debugging output.
