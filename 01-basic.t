use v6;
use lib 'lib';
use Test;
use JSX;

my sub create-element(*@args) {
  @args;
}

is-deeply jsx <img/>, ['img'], 'jsx <img/>';
is-deeply jsx<img/>, ['img'], 'jsx<img/>';

done-testing;
