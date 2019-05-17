
README.md: BibCat.pm
	perl -MPod::Markdown::Github -e "Pod::Markdown::Github->filter('BibCat.pm')" > README.md
