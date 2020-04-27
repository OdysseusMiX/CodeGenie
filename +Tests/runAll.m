function runAll

test = {
    Tests.TestFileManager
    Tests.TestLexer
    Tests.TestParser
    Tests.TestRefactor_extract
    Tests.TestRefactor_inline
    Tests.TestRefactor_renameFunc
    Tests.TestRefactor_addInput
    Tests.TestRefactor_replaceInput
    };
for i=1:length(test)
run(test{i});
end


    