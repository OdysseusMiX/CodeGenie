function runAll

test = {
    Tests.TestLexer
    Tests.TestParser
    Tests.TestRefactor_extract
    Tests.TestRefactor_inline
    };
for i=1:length(test)
run(test{i});
end


    