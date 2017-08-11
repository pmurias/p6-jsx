use v6;
use lib 'lib';
use Test;
use JSX;

my sub create-element(*@args) {
  item @args;
}

is-deeply jsx <img/>, ['img'], 'jsx <img/>';
is-deeply jsx<img/>, ['img'], 'jsx<img/>';

is-deeply jsx <img></img>, ['img'], 'jsx <img></img>';

is-deeply jsx <span><span/><span/></span>, ['span', ['span'], ['span']], 'nested elements';

is-deeply jsx <span>Hello <span>World</span></span>, ['span', "Hello ", ['span', "World"], ], 'raw text';

done-testing;
