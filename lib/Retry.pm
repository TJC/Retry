package Retry;
use Moose 1.01; # Probably fine with 0.92 or later, but untested.
our $VERSION = '0.10';

=head1 NAME

Retry

=head1 SYNOPSIS

A one-feature module, this provides a method to wrap any function in automatic
retry logic, with exponential back-off delays, and a callback for each time an
attempt fails.

Example:

  my $agent = Retry->new(
    failure_callback => sub { warn "oh dear, error: " . $_[0]; },
  );
  eval {
    $agent->retry(
      sub {
        this_code_might_die();
      }
    );
  };
  if ($@) {
    die "We totally failed!";
    # Note that if we succeeded on a retry, this won't get called.
  }

=head1 ATTRIBUTES

=cut

=head2 retry_delay

This is the initial delay used when the routine failed, before retrying again.

Every subsequent failure doubles the amount.

It defaults to 8 seconds.

=cut

has 'retry_delay' => (
    is => 'rw',
    isa => 'Int',
    default => 8
);

=head2 max_retry_attempts

The maximum number of retries we should attempt before giving up completely.

It defaults to 5.

=cut

has 'max_retry_attempts' => (
    is => 'rw',
    isa => 'Int',
    default => 5,
);

=head2 failure_callback

Optional. To be notified of *every* failure (even if we eventually succeed on a
later retry), install a subroutine callback here.

For example:

  Retry->new(
      failure_callback => sub { warn "failed $count++ times" }
  );

=cut

has 'failure_callback' => (
    is => 'rw',
    isa => 'CodeRef',
    default => sub { sub {} }, # The way of the Moose is sometimes confusing.
);

=head1 METHODS

=head2 retry

Its purpose is to execute the passed subroutine, over and over, until it
succeeds, or the number of retries is exceeded. The delay between retries
increases exponentially.

=cut

sub retry {
    my ($self, $sub) = @_;

    my $delay = $self->retry_delay;
    my $retries = $self->max_retry_attempts;

    while () {
        eval { $sub->() };
        return unless $@;
        my $error = $@;
        $self->failure_callback->($error);

        die($error) unless $retries--;

        sleep($delay);
        $delay *= 2;
    }
}

=head1 AUTHOR

Toby Corkindale, L<mailto:tjc@cpan.org>

=head1 LICENSE

This module is released under the Perl Artistic License.

It is based upon source code which is Copyright 2010 Strategic Data Pty Ltd,
however it is used and released with permission.

=head1 SEE ALSO

L<Attempt>

Retry differs from Attempt in having exponentially increasing delays, and by
having a callback inbetween attempts.

However L<Attempt> has a simpler syntax.

=cut

no Moose;
__PACKAGE__->meta->make_immutable;
1;
