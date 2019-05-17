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

By default the output uses the supertabular environment.  Sometimes
supertabular does the wrong thing.  To use the tabular environment and
explicit pagebreaks instead, set the lines field to a postive value of
the number of lines that should be on one page.

```
$bc->{lines} = 60;
```

By default a colon and any characters following it will be removed
from the title.  To keep subtitles, set the nosubtitles slot to 0 (its
default is 1).

```perl
$bc->{nosubtitles} = 0;
```

By default the report has two catalogs, one after the other: the first
is ordered by author (or editor, etc.); the second, by Library of
Congress number in the loc field.  To change the number of lists or
their sorting, use the sorter slot.  It should be a list of sorter
functions for the Perl sort function.  The default setting references
the two provided sorter functions,

```
$bc->{sorters} = [\&BibCat::BibCat::standardSort,
                  \&BibCat::BibCat::sortByLoC];
```
