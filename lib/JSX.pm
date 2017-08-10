use nqp;
use NQPHLL:from<NQP>;

use QAST:from<NQP>;

sub EXPORT(|) {
    sub atkeyish(Mu \h, \k) {
        nqp::atkey(nqp::findmethod(h, 'hash')(h), k)
    }

    my role JSX::Grammar {
        rule term:sym<jsx> {
            jsx <jsx_element>
        }

        token jsx_element {
#            <jsx_opening_element> <jsx_children>? <jsx_closing_element> 
            <jsx_self_closing_element>
        }

        token jsx_self_closing_element {
          '<' <jsx_element_name> '/>'
        }

        token jsx_opening_element {
          '<' <jsx_element_name> '>'
        }

        token jsx_closing_element {
          '<' <jsx_element_name> '>'
        }

#
#        token jsx_attributes {
#          <jsx_attribute>+
#        }
#
#
#        token jsx_attribute_value {
#          \" JSXDoubleStringCharacters<sub>opt</sub> \"
#          \' JSXSingleStringCharacters<sub>opt</sub> \`
#          `{` AssignmentExpression `}`
#- JSXElement
#        

        token jsx_element_name {
            \w+
        }
    }

    my role JSX::Actions {
        method term:sym<jsx>(Mu $/) {
            $/.make(atkeyish($/, 'jsx_element').ast);
        }

        method jsx_element(Mu $/) {
            $/.make(atkeyish($/, 'jsx_self_closing_element').ast);
        }

        method jsx_self_closing_element(Mu $/) {
            my $element-name = atkeyish($/, 'jsx_element_name').Str;
            my $type = QAST::SVal.new(:value($element-name));
            $/.make(QAST::Op.new(:op<call>, :name('&create-element'), $type));
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
