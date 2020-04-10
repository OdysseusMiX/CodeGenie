classdef Refactor
    
    methods (Static)
        
        function extractFunction(filename)
            
            tokens = Parser.parseFile(filename);
            indStart = find(strncmp('%<extract>', {tokens.string}, 10));
            indStop = find(strcmp('%<\extract>', {tokens.string}));
            
            index = indStart(1):indStop(1);
            
            functionCall = tokens(indStart(1)).string(11:end);
            
            nTokens = length(tokens);
            txt_before = [tokens(1:(index(1)-1)).string];
            txt_replacement = [functionCall ';'];
            txt_after = [tokens((index(end)+1):nTokens).string];
            txt_extracted = ['function ' functionCall tokens(index(2:end-1)).string 'end' newline];
            txtOut = [txt_before, txt_replacement, txt_after, newline, txt_extracted ];
            
            fid = fopen(filename,'w');
            fprintf(fid,'%s', txtOut);
            fclose(fid);
            
        end
    end
    
end