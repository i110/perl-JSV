package JSV::Keyword::Draft4::Items;

use strict;
use warnings;
use parent qw(JSV::Keyword);

use Carp;
use JSON::XS;

use JSV::Keyword qw(:constants);
use JSV::Exception;
use JSV::Util::Type qw(detect_instance_type);

sub instance_type() { INSTANCE_TYPE_ARRAY(); }
sub keyword() { "items" }
sub keyword_priority() { 10; }

sub validate {
    my ($class, $context, $schema, $instance) = @_;

    my $items            = $class->keyword_value($schema);
    my $additional_items = $class->keyword_value($schema, "additionalItems");

    my $items_type = detect_instance_type($items);
    my $additional_items_type = detect_instance_type($additional_items);

    if ($items_type eq "object") { ### items as schema
        for (my $i = 0, my $l = scalar @$instance; $i < $l; $i++) {
            push(@{$context->pointer_tokens}, $i);
            $context->validate($items, $instance->[$i]);
            pop(@{$context->pointer_tokens});
        }
    }
    elsif ($items_type eq "array") { ### items as schema array
        for (my $i = 0, my $l = scalar @$instance; $i < $l; $i++) {
            push(@{$context->pointer_tokens}, $i);

            if (defined $items->[$i]) {
                $context->validate($items->[$i], $instance->[$i]);
            }
            elsif ($additional_items_type eq "object") {
                $context->validate($additional_items, $instance->[$i]);
            }
            elsif ($additional_items_type eq "boolean" && $additional_items == JSON::false) {
                $context->log_error("additionalItems are now allowed");
            }

            pop(@{$context->pointer_tokens});
         }
    }
    else { ### wrong schema
        $context->log_error("Wrong schema definition");
    }
}

1;
