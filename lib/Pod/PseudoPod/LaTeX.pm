package Pod::PseudoPod::LaTeX;

use base 'Pod::PseudoPod';

use strict;
use warnings;

our $VERSION = '0.10';

sub new
{
	my ($class, %args)  = @_;
	my $self            = $class->SUPER::new( %args );
	$self->accept_targets_as_text( qw( blockquote programlisting ));
	$self->{scratch}  ||= '';
	$self->{stack}      = [];
	return $self;
}

sub end_Document
{
	my $self = shift;
	$self->emit();
}

sub emit
{
	my $self = shift;
	return unless defined $self->{scratch};
	print { $self->{output_fh} } delete $self->{scratch};
}

sub handle_text
{
	my ($self, $text) = @_;
	$self->{scratch} .= $self->encode_text( $text );
}

sub encode_text
{
	my ($self, $text) = @_;
	return $text if $self->{flags}{in_verbatim};

	# escape LaTeX-specific characters
	$text =~ s/([#\$&%_{}\\])/\\$1/g;

	# use the right beginning quotes
	$text =~ s/(^|\s)"/$1``/g;

	# and the right ending quotes
	$text =~ s/"(\s|$)/''$1/g;

	# fix the ellipses
	$text =~ s/\.{3}\s*/\\ldots /g;

	# fix the ligatures
	$text =~ s/f([fil])/f\\mbox{}$1/g;

	# fix emdashes
	$text =~ s/\s--\s/---/g;

	# fix tildes
	$text =~ s/~/\$\\sim\$/g;

	return $text;
}

sub start_head0
{
	my $self = shift;
	$self->{scratch} .= '\\chapter{';
}

sub end_head0
{
	my $self = shift;
	$self->{scratch} .= "}\n\n";
	$self->emit();
}

sub end_Para
{
	my $self = shift;
	$self->{scratch} .= "\n\n";
	$self->emit();
}

BEGIN
{
	for my $level ( 1 .. 3 )
	{
		my $prefix    = '\\' . ( 'sub' x ( $level - 1 ) ) . 'section*{';
		my $start_sub = sub
		{
			my $self = shift;
			$self->{scratch} .= $prefix;
		};

		my $end_sub  = sub
		{
			my $self = shift;
			$self->{scratch} .= "}\n\n";
			$self->emit();
		};

		no strict 'refs';
		*{ 'start_head' . $level } = $start_sub;
		*{ 'end_head'   . $level } = $end_sub;
	}
}

sub start_E
{
	my $self = shift;
	push @{ $self->{stack} }, delete $self->{scratch};
	$self->{scratch} = '';
}

my %characters =
(
	acute => sub { qq|\\'| . shift },
	grave => sub { qq|\\`| . shift },
	uml   => sub { qq|\\"| . shift },
	opy   => sub { '\copyright' },
	dash  => sub { '---' },
	lusmn => sub { '\pm' },
);

sub end_E
{
	my $self    = shift;

	# XXX - error checking here
	(my $entity = delete $self->{scratch}) =~ s/(\w)(\w+)/
		exists $characters{$2} ?
			$characters{$2}->( $1 ) : die "Unrecognized character '$2'\n" /e;

	$self->{scratch} = pop @{ $self->{stack } };
	$self->{scratch} .= $entity;
}

sub _treat_Es {}

sub start_for
{
	my ($self, $flags) = @_;
}

sub end_for
{
	my $self = shift;
}

sub start_Verbatim
{
	my $self = shift;
	$self->{scratch} .= "\\begin{verbatim}\n";
	$self->{flags}{in_verbatim}++;
}

sub end_Verbatim
{
	my $self = shift;
	$self->{scratch} .= "\\end{verbatim}\n";
	$self->{flags}{in_verbatim}--;
	$self->emit();
}

BEGIN
{
	for my $listtype (
		[qw( bullet itemize     )],
		[qw( number enumerate   )],
		[qw( text   description )],
		[qw( block  description )],
	)
	{

		my $start_sub = sub 
		{
			my $self = shift;
			$self->{scratch} .= "\\flushleft\n\\begin{$listtype->[1]}\n";
		};

		my $end_sub = sub
		{
			my $self = shift;
			$self->{scratch} .= "\\end{$listtype->[1]}\n";
			$self->emit();
		};

		no strict 'refs';
		*{ 'start_over_' . $listtype->[0] } = $start_sub;
		*{ 'end_over_'   . $listtype->[0] } = $end_sub;
	}
}

sub start_item_bullet
{
	my $self = shift;
	$self->{scratch} .= '\item ';
}

sub start_item_number
{
	my ($self, $flags) = @_;
	$self->{scratch}  .= "\\item[$flags->{number}] ";
}

sub start_item_text
{
	my $self = shift;
	$self->{scratch} .= '\item[] ';
}

BEGIN
{
	for my $end (qw( bullet number text))
	{
		my $end_sub = sub
		{
			my $self = shift;
			$self->emit();
		};

		no strict 'refs';
		*{ 'end_item_' . $end } = $end_sub;
	}
}

my %formats =
(
	B => [ 'textbf',   '' ],
	C => [ 'texttt',   '' ],
	F => [ 'emph',     '' ],
	I => [ 'emph',     '' ],
	N => [ 'footnote', '' ],
	X => [ 'index',    '|textit' ],
);

while (my ($code, $fixes) = each %formats)
{
	my $start_sub = sub
	{
		my $self = shift;
		$self->{scratch} .= '\\' . $fixes->[0] . '{';
	};

	my $end_sub = sub
	{
		my $self = shift;
		$self->{scratch} .= $fixes->[1] . '}';
	};

	no strict 'refs';
	*{ 'start_' . $code } = $start_sub;
	*{ 'end_'   . $code } = $end_sub;
}

1;
__END__

=head1 NAME

Pod::PseudoPod::LaTeX - convert Pod::PseudoPod documents into LaTeX

=head1 VERSION

Version 0.10

=head1 SYNOPSIS

This module is a Pod::PseudoPod subclass, itself a Pod::Simple subclass.  This
means that this is a full-fledged POD parser.  Anything those modules can do,
this can do.

Perhaps a little code snippet.

    use Pod::PseudoPod::LaTeX;

    my $parser = Pod::PseudoPod::LaTeX->new();
	$parser->output_fh( $some_fh );
	$parser->parse_file( 'some_document.pod' );

    ...

There aren't really any user-servicable parts inside.

=head1 AUTHOR

chromatic, C<< <chromatic at wgz.org> >>

=head1 BUGS

Please report any bugs or feature requests to C<bug-pod-pseudopod-tex at
rt.cpan.org>, or through the web interface at
L<http://rt.cpan.org/NoAuth/ReportBug.html?Queue=Pod-PseudoPod-LaTeX>.  I'll
hear about it and you'll hear about any progress on your bug as I make changes.

=head1 SUPPORT

Read this documentation with the perldoc command:

    $ B<perldoc Pod::PseudoPod::LaTeX>

You can also look for information at:

=over 4

=item * AnnoCPAN: Annotated CPAN documentation

L<http://annocpan.org/dist/Pod-PseudoPod-LaTeX>

=item * CPAN Ratings

L<http://cpanratings.perl.org/d/Pod-PseudoPod-LaTeX>

=item * RT: CPAN's request tracker

L<http://rt.cpan.org/NoAuth/Bugs.html?Dist=Pod-PseudoPod-LaTeX>

=item * Search CPAN

L<http://search.cpan.org/dist/Pod-PseudoPod-LaTeX>

=back

=head1 ACKNOWLEDGEMENTS and SEE ALSO

Based on Allison Randal's L<Pod::PseudoPod> module.

See also L<perlpod>, L<Pod::Simple> and L<Pod::TeX>.  I did not reuse the
latter because I need to support the additional POD directives found in
PseudoPod.

Thanks to Onyx Neon Press (L<http://www.onyxneon.com/>) for sponsoring this
work under free software guidelines.

=head1 COPYRIGHT & LICENSE

Copyright (c) 2006 chromatic, some rights reserved.

This program is free software; you can redistribute it and/or modify it under
the same terms as Perl 5.8 itself.

=cut
