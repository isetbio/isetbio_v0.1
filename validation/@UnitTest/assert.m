% Ask whether passed expression is true.
function assert(expression,msgString)
    
if (~expression)
    UnitTest.validationRecord('FAILED', ['Assertion ' msgString ' is false ']);
else
    UnitTest.validationRecord('PASSED', ['Assertion ' msgString ' is true ']);
end

end

