use v6;
use lib 'lib';
use Test;
use JSX;

my sub create-element(*@children, *%attrs) {
  my @children-and-attrs = @children;
  if %attrs {
    @children-and-attrs.push(%attrs);
  }
  item @children-and-attrs;
}

is-deeply jsx <img/>, ['img'], 'jsx <img/>';
is-deeply jsx<img/>, ['img'], 'jsx<img/>';

is-deeply jsx <img></img>, ['img'], 'jsx <img></img>';

is-deeply jsx <span><span/><span/></span>, ['span', ['span'], ['span']], 'nested elements';

is-deeply jsx <span>Hello <span>World</span></span>, ['span', "Hello ", ['span', "World"], ], 'raw text';

is-deeply jsx <img src="camelia.jpg"/>, ['img', {src => "camelia.jpg"}], 'attributes to autoclosing tags';
is-deeply jsx <img src="camelia.jpg"></img>, ['img', {src => "camelia.jpg"}], 'attributes to normal tags';

is-deeply jsx <img src='camelia.jpg'/>, ['img', {src => "camelia.jpg"}], 'single quotes attribute to autoclosing tags';
is-deeply jsx <img src='camelia.jpg'></img>, ['img', {src => "camelia.jpg"}], 'single quotes attribute to normal tags';

is-deeply jsx <span element=<span>attr</span>>content</span>, ['span', 'content', {element => ['span', 'attr']}], 'using an element as attribute value';

is-deeply jsx <span attr={123}/>, ['span', {attr => 123}], 'using an Perl 6 expression as attribute value';

done-testing;
