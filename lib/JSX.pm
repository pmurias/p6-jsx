use nqp;
use NQPHLL:from<NQP>;

use QAST:from<NQP>;

sub EXPORT(|) {
    sub atkeyish(Mu \h, \k) {
        nqp::atkey(nqp::findmethod(h, 'hash')(h), k)
    }

    sub atposish(Mu \h, \k) {
        nqp::atpos(nqp::findmethod(h, 'list')(h), k)
    }

    my role JSX::Grammar {
        rule term:sym<jsx> {
            jsx <jsx_element>
        }

        token jsx_element {
            <jsx_closed_element> | <jsx_self_closing_element>
        }

        token jsx_closed_element {
            <jsx_opening_element> <jsx_child>* <jsx_closing_element>
        }

        token jsx_self_closing_element {
            '<' <.ws> <jsx_element_name> <.ws> <jsx_attribute>* '/' <.ws> '>'
        }

        token jsx_opening_element {
            '<' <.ws> <jsx_element_name> <.ws> <jsx_attribute>* '>'
        }

        token jsx_closing_element {
            '<' <.ws> '/' <.ws> <jsx_element_name> <.ws> '>'
        }

        token jsx_child {
            <jsx_element> | <jsx_text> | '{' <.ws> <EXPR> '}'
        }

        token jsx_text {
          <-[{}<>]>+
        }

        token jsx_attribute {
          <jsx_attribute_name> <.ws> ['=' <.ws> <jsx_attribute_value>] <.ws>
        }

        proto token jsx_attribute_value {*}

        token jsx_attribute_value:sym<""> {
            '"' (<-["]>+) '"'
        }
        token jsx_attribute_value:sym<''> {
            "'" (<-[']>+) "'"
        }
        token jsx_attribute_value:sym<jsx_element> {
            <jsx_element>
        }
        token jsx_attribute_value:sym<EXPR> {
            '{' <.ws> <EXPR> '}'
        }


        token jsx_attribute_name {
            \w+
        }

        token jsx_element_name {
            \w+
        }
    }

    my role JSX::Actions {
        method term:sym<jsx>(Mu $/) {
            $/.make(atkeyish($/, 'jsx_element').ast);
        }

        method jsx_element(Mu $/) {
            if atkeyish($/, 'jsx_self_closing_element') {
               $/.make(atkeyish($/, 'jsx_self_closing_element').ast);
            } elsif atkeyish($/, 'jsx_closed_element') {
               $/.make(atkeyish($/, 'jsx_closed_element').ast);
            }
        }

        method jsx_child(Mu $/) {
            if atkeyish($/, 'jsx_element') {
              $/.make(atkeyish($/, 'jsx_element').ast);
            } elsif atkeyish($/, 'jsx_text') {
              $/.make(atkeyish($/, 'jsx_text').ast);
            } elsif atkeyish($/, 'EXPR') {
              $/.make(atkeyish($/, 'EXPR').ast);
            }
        }

        method jsx_text(Mu $/) {
            $/.make(QAST::SVal.new(:value($/.Str)));
        }

        method jsx_opening_element(Mu $/) {
            my $element-name = atkeyish($/, 'jsx_element_name').Str;
            my $type = QAST::SVal.new(:value($element-name));
            my $attributes = nqp::hllize(atkeyish($/, 'jsx_attribute')).map(*.ast);

            $/.make(QAST::Op.new(:op<call>, :name('&create-element'), nqp::decont($type), |$attributes));
        }

        method jsx_closed_element(Mu $/) {
            my $element = atkeyish($/, 'jsx_opening_element').ast;

            my $args = nqp::hllize(atkeyish($/, 'jsx_child')).map(*.ast);

            for @$args -> $arg {
                $element.push(nqp::decont($arg));
            }

            $/.make(atkeyish($/, 'jsx_opening_element').ast);
        }

        method jsx_self_closing_element(Mu $/) {
            my $element-name = atkeyish($/, 'jsx_element_name').Str;
            my $type = QAST::SVal.new(:value($element-name));

            my $attributes = nqp::hllize(atkeyish($/, 'jsx_attribute')).map(*.ast);

            $/.make(QAST::Op.new(:op<call>, :name('&create-element'), nqp::decont($type), |$attributes));
        }

        method jsx_attribute(Mu $/) {
            my $value = atkeyish($/, 'jsx_attribute_value').ast;
            my $name = atkeyish($/, 'jsx_attribute_name').Str;
            $value.named($name);
            $/.make(nqp::decont($value));
        }

        method jsx_attribute_value:sym<''>(Mu $/) {
            $/.make(QAST::SVal.new(:value(atposish($/, 0))));
        }

        method jsx_attribute_value:sym<"">(Mu $/) {
            $/.make(QAST::SVal.new(:value(atposish($/, 0))));
        }

        method jsx_attribute_value:sym<jsx_element>(Mu $/) {
            $/.make(atkeyish($/, 'jsx_element').ast);
        }

        method jsx_attribute_value:sym<EXPR>(Mu $/) {
            $/.make(atkeyish($/, 'EXPR').ast);
        }
    }

    my Mu $MAIN-grammar := nqp::atkey(%*LANG, 'MAIN');
    my Mu $MAIN-actions := nqp::atkey(%*LANG, 'MAIN-actions');

    my $grammar := $MAIN-grammar.HOW.mixin($MAIN-grammar, JSX::Grammar);
    my $actions := $MAIN-grammar.HOW.mixin($MAIN-actions, JSX::Actions);

    # new way
    try $*LANG.define_slang('MAIN', $grammar, $actions);

    {}
}
