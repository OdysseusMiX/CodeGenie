classdef FileManager
    
    methods (Static)
        function txt = readFile(file)
            fid = fopen(file);
            if fid<3
                txt = '';
            else
                txt = fread(fid,'*char');
                fclose(fid);
                txt = txt';
            end
        end
        
        function overwriteFile(filename, txt)
            fid = fopen(filename,'w');
            fprintf(fid,'%s', txt);
            fclose(fid);
        end
    end
end
        