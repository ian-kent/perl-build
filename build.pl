#!/usr/bin/env perl

eval { use Build; 1 } or eval `curl http://127.0.0.1/Build.pm` or die "Unable to load Build";

project {
    name    => "Example",
    version => "0.01",
};

task install => sub {
    install "https://github.com/ian-kent/Devel-Declare-Lexer", from github { protocol => "https" };
    install "Devel::Declare::Lexer", from cpan;
    run install_something if option '--something';
};

task install_something => sub {
    clone "Required", from github { to => "/foo/bar" };
    install "Something", from cpan;
};

build and cleanup;
