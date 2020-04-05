classdef Refactor
    
    methods (Static)
        
        function extractFunction(filename)
            
            fid = fopen(filename);
            lines = textscan(fid, '%s','Delimiter','\n','WhiteSpace','');
            fclose(fid);
            lines = lines{1};
            
            foundStart = false;
            foundStop = false;
            nest = false;
            endStr = '%<\extract>';
            for i = 1:length(lines)
                line = lines{i};
                
                if strncmp(line, '%<extract>', 10)
                    start = i;
                    foundStart = true;
                    functionStr = line(11:end);
                elseif strncmp(line, '%<nest>', 7)
                    start = i;
                    foundStart = true;
                    functionStr = line(8:end);
                    nest = true;
                    endStr = '%</nest>';
                elseif foundStart && strncmp(line, endStr, length(endStr))
                    stop = i;
                    foundStop = true;
                    break;
                end
            end
            if ~foundStop
                return;
            end
            
            lines = [lines; {''}];
            
            lines = [lines; { ['function ' functionStr] }];
            lines = [lines; lines((start+1):(stop-1)) ];
            lines = [lines; {'end'}];
            
            lines(start) = {[functionStr ';']};
            lines(start+1:stop) = [];
            
            fid = fopen(filename,'w');
            fprintf(fid,'%s\n', lines{:});
            fclose(fid);
        end
        
    end
    
end