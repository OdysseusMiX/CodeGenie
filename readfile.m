function txt = readfile(file)
fid = fopen(file);
if fid<3
    txt = '';
else
    txt = fread(fid,'*char');
    fclose(fid);
    txt = txt';
end
end