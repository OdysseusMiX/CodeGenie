function runAll

test = {
    Tests.TestSyntax
    Tests.TestLexer
    Tests.TestInspector
    Tests.TestRefactor
    };
for i=1:length(test)
run(test{i});
end


    