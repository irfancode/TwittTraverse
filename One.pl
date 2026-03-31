#!/usr/bin/perl
use strict;
use warnings;
use Net::Twitter;
use Scalar::Util 'blessed';
use Getopt::Long;
use POSIX qw(strftime);
use Fcntl qw(:O_CREAT :O_WRONLY :O_APPEND);

# Get command line options
my $search_term;
my $hashtag;
my $user;
my $count = 10;   # number of tweets to fetch
GetOptions(
    'search=s' => \$search_term,
    'hashtag=s' => \$hashtag,
    'user=s' => \$user,
    'count=i' => \$count,
) or die "Usage: $0 --search <term> | --hashtag <tag> | --user <username> [--count <number>]\n";

# Validate: exactly one of search, hashtag, user must be provided
my $num_options = grep { defined $_ } ($search_term, $hashtag, $user);
die "Please provide exactly one of --search, --hashtag, or --user\n" if $num_options != 1;

# Build the query
my $query;
if (defined $search_term) {
    $query = $search_term;
} elsif (defined $hashtag) {
    $query = "#$hashtag";
} elsif (defined $user) {
    # For user timeline, we don't use the search API
    $query = undef;   # we'll handle separately
}

# Set up Net::Twitter
my $nt = Net::Twitter->new(
    traits                 => [qw/OAuth API::REST/],
    consumer_key           => $ENV{TWITTER_CONSUMER_KEY},
    consumer_secret        => $ENV{TWITTER_CONSUMER_SECRET},
    access_token           => $ENV{TWITTER_ACCESS_TOKEN},
    access_token_secret    => $ENV{TWITTER_ACCESS_TOKEN_SECRET},
    ssl                    => 1,
    decode_html_entities   => 1,
);

# Check for credentials
die "Missing Twitter credentials in environment variables\n"
    unless $nt->consumer_key && $nt->consumer_secret && $nt->access_token && $nt->access_token_secret;

# Prepare output file: we'll use /data directory and a filename based on the query and timestamp
my $timestamp = strftime("%Y%m%d_%H%M%S", localtime);
my $safe_query = (defined $query ? $query : $user);
$safe_query =~ s/[^a-zA-Z0-9_-]/_/g;   # make it filesystem safe
my $output_file = sprintf("/data/twitter_%s_%s.csv", $safe_query, $timestamp);

# Open the output file for writing (create if not exists, append if exists)
open my $fh, '>>:encoding(UTF-8)', $output_file
    or die "Cannot open file '$output_file': $!";

# Write header if file is empty (or we can write header every time? Let's write header only if file is empty)
if (-z $output_file) {
    print $fh "created_at,from_user,text\n";
}

# Fetch tweets
eval {
    if (defined $query) {
        my $response = $nt->search({ query => $query, count => $count });
        foreach my $tweet (@{$response->{results}}) {
            print $fh sprintf("%s,%s,\"%s\"\n",
                $tweet->{created_at},
                $tweet->{from_user},
                $tweet->{text});
        }
    } else {
        # user timeline
        my $response = $nt->user_timeline({ screen_name => $user, count => $count });
        foreach my $tweet (@{$response}) {
            print $fh sprintf("%s,%s,\"%s\"\n",
                $tweet->{created_at},
                $tweet->{user}{screen_name},
                $tweet->{text});
        }
    }
};
if (my $err = $@) {
    die $@ unless blessed $err && $err->isa('Net::Twitter::Error');
    # Handle Twitter error
    warn "Twitter error: ", $err->error, "\n";
    close $fh;
    exit 1;
}

close $fh;
print "Results saved to $output_file\n";