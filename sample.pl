#!/usr/bin/env perl
use strict;
use warnings;
use Config::Pit;
use XML::Simple;
use WebService::WolframAlpha;

## Load AppID from Config
my $config = pit_get('WolframAlpha', require => {
    appid => 'AppID',
} );
my $appid = $config->{appid} or die 'perl -MConfig::Pit -e\'Config::Pit::set("WolframAlpha", data => { appid => "Your AppID" } )\'';

## Create WebService::WolframAlpha Object
my $wa = WebService::WolframAlpha->new( {
    appid => $appid,
    useragent => 'Your App',
} );

## Call query
$wa->query( {
    input         => 'pi',
    format        => 'plaintext',
} );

## Check Result
die $wa->error if !$wa->is_success;

## Use XML
my $xs = XML::Simple->new();
my $ref = $xs->XMLin($wa->xml);

## Check WolframAlpha API Result
die 'WolframAlpha doesn\'t know how to interpret your input.' if $ref->{success} ne 'true';

## Print Pods ID
foreach(keys(%{$ref->{pod}})) {
    print $_ . "\n";
}

## Print Input plaintext
print $_ . "\n" if $_ = $ref->{pod}->{Input}->{subpod}->{plaintext};
