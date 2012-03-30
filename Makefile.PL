use inc::Module::Install;
name 'WebService-WolframAlpha';
all_from 'lib/WebService/WolframAlpha.pm';
readme_markdown_from 'lib/WebService/WolframAlpha.pm';
githubmeta;

# requires '';
requires 'URI';
requires 'LWP::UserAgent';

tests 't/*.t';
author_tests 'xt';

build_requires 'Test::More';
auto_set_repository;
auto_include;
WriteAll;
