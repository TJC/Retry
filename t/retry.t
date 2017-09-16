use strict;
use warnings;
use Test::More;
use Test::Exception;
use Retry;

{
    my $retry = Retry->new;
    lives_ok {
        $retry->retry(sub { 1 });
    } 'Simple case works';
}

{
    local $Retry::SLEEP_METHOD = sub { };
    my $retry = Retry->new( retry_delay => 1 );
    my $count = 3;
    lives_ok {
        $retry->retry(sub { die('for dethklok') unless not $count-- });
    } 'Succeed with retries';
}

{
    local $Retry::SLEEP_METHOD = sub { };
    my $retry = Retry->new( retry_delay => 1, max_retry_attempts => 3 );
    my $count = 3;

    lives_ok {
        $retry->retry(sub { die('for dethklok') unless not $count-- });
    } 'Succeed with exactly 3 retries';

    $count = 4;
    dies_ok {
        $retry->retry(sub { die('for dethklok') unless not $count-- });
    } 'Fails with more than 3 retries';
}

{
    local $Retry::SLEEP_METHOD = sub { };
    my $callbacks = 0;
    my $retry = Retry->new(
        retry_delay => 1,
        failure_callback => sub { $callbacks++; },
    );
    my $count = 3;
    $retry->retry(sub { die('for dethklok') unless not $count-- });

    is($callbacks, 3, "Callback called three times.");
}

{
    local $Retry::SLEEP_METHOD = sub { };
    my $retry = Retry->new( retry_delay => 1 );
    my $count = 3;
    my $result = $retry->retry(
        sub {
            die('for dethklok') unless not $count--;
            return "win!";
        }
    );
    is($result, 'win!', "Return value from sub was passed through.");
}

{
    is(\&CORE::sleep, $Retry::SLEEP_METHOD, 'Sleep method is initially CORE::sleep');
}

{
    my @sleeps;
    local $Retry::SLEEP_METHOD = sub { push @sleeps, shift };
    my $retry = Retry->new;
    eval { $retry->retry(sub { die 'custom sleep method' }); };
    is_deeply([8, 16, 32, 64, 128], \@sleeps);
}

done_testing();
