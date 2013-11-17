package Build;

use Exporter 'import';
@EXPORT = qw/ project task install from github cpan build cleanup option run clone /;

use Data::Dumper;

my %project = ();
my %tasks = ();
my @cleanup = ();

my %options = (
    tasks => [],
);

my $is_task = 1;
for $arg (@ARGV) {
    $is_task = 0 if $arg =~ /^--/;
    push $options{tasks}, $arg if $is_task;
    my ($key, $value) = $arg =~ /^(--[^=]*)(?:=(.*))?$/;
    $value //= 1;
    $options{$key} = $value if $key;
}

print Dumper \%options;
sub option (;$) {
    my $arg = shift;
    return $options{$arg} if $arg;
    return %options;
}

sub run (*) {
    my $task = shift;
    die "No task specified" unless $task;
    $tasks{$task}->() or die "Unknown task $task";
}

sub build {
    print Dumper \%tasks;
    $tasks{$_}->() for @{$options{tasks}};
    1;
}

sub cleanup {
    print Dumper \@cleanup;
    $_->() for @cleanup;
    1;
}

sub project (&) {
    my ($args) = @_;
    my %args = $args->();
    print "Args: ", Dumper \%args;
    %project = %args;
}

sub task (%) {
    my ($name, $task) = @_;
    print "Task: $name\n";
    $tasks{$name} = $task;
}

sub install ($$) {
    my ($project, $from) = @_;
    my ($from, $do) = $from->($project);
    print "Install project: $project\nFrom: $from\n";
    my $state = 'install';
    $do->($state);
}

sub clone ($$) {
    my ($project, $from) = @_;
    my ($from, $do) = $from->($project);
    print "Clone project: $project\nFrom: $from\n";
    my $state = 'clone';
    $do->($state);
}

sub from ($) {
    return shift;
}

sub github (;&) {
    my $options = shift;
    my %options = $options ? $options->() : ();
    return sub {
        my $project = shift;
        return ("github", sub {
            my $state = shift;
            if($state eq 'clone') {
                print "Cloning $project from github\n";
            } else {
                print "Installing $project from github\n";
            }
            push @cleanup, sub {
                print "Cleaning up $project (state: $state)\n";
            };
        });
    };
}

sub cpan (;&) {
    my $options = shift;
    my %options = $options ? $options->() : ();
    return sub {
        my $project = shift;
        return ("cpan", sub {
            my $state = shift;
            print "Installing $project from cpan\n";
            push @cleanup, sub {
                print "Cleaning up $project\n";
            }
        });
    };
}

1;
