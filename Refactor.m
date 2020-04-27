classdef Refactor
    
    methods (Static)
        
        function file(filename)
            
            tokens = Parser.parseFile(filename);
            
            indStart = find(strncmp('%<extract>', {tokens.string}, 10));
            indStop = find(strcmp('%</extract>', {tokens.string}));
            if ~isempty(indStart)
                index = indStart(1):indStop(1);
                ExtractFunction.execute(tokens, index, filename);
                return;
            end
            
            indStart = find(strncmp('%<nest>', {tokens.string}, 7));
            indStop = find(strcmp('%</nest>', {tokens.string}));
            if ~isempty(indStart)
                index = indStart(1):indStop(1);
                NestFunction.execute(tokens, index, filename);
            end
            
            indStart = find(strncmp('%<inline>', {tokens.string}, 7));
            if ~isempty(indStart)
                index = indStart(1);
                InlineFunction.execute(tokens, index, filename);
            end
            
            indStart = find(strncmp('%<renameFunc>', {tokens.string}, 13));
            if ~isempty(indStart)
                index = indStart(1);
                RenameFunction.execute(tokens, index, filename);
            end
            
            indStart = find(strncmp('%<addInput>', {tokens.string}, 11));
            if ~isempty(indStart)
                index = indStart(1);
                AddInputToFunction.execute(tokens, index, filename);
            end
            
        end
    end
end
