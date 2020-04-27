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
        
        function mfiles = getMFiles(fileDir)
            files = dir(fileDir);
            isMFile = false(size(files));
            for iFile=1:length(files)
                isMFile(iFile) =  ~files(iFile).isdir && strcmp(files(iFile).name(end-1:end), '.m');
            end
            mfiles = files(isMFile);
        end
    end
end
        