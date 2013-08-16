package JSV::Keyword::MaxItems;

use strict;
use warnings;
use parent qw(JSV::Keyword);

use JSV::Exception;

sub keyword { "maxItems" }

sub validate {
    my ($class, $validator, $schema, $instance, $opts) = @_;
    return 1 unless $class->has_keyword($schema);

    $opts         ||= {};
    $class->initialize_args($schema, $instance, $opts);

    unless ($opts->{type} eq "array") {
        return 1;
    }

    my $keyword_value = $class->keyword_value($schema);

    if (scalar(@$instance) <= $keyword_value) {
        return 1;
    }
    else {
        JSV::Exception->throw(
            "The instance array length is greater than maxItems value",
            $opts,
        );
    }
}

1;
