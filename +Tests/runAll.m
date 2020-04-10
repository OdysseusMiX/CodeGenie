function runAll

test = {
    Tests.TestLexer
    Tests.TestParser
    Tests.TestInspector
    Tests.TestRefactor
    };
for i=1:length(test)
run(test{i});
end


    