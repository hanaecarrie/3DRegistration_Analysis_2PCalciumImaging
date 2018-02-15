%for nbz = 5:29
nbz = 5;
    if nbz < 10
        nbplane = strcat('0', num2str(nbz));
    else
        nbplane = num2str(nbz);
    end
    
    oldfile = strcat('plane', num2str(nbz), '_reg.sbx');
    newfile = strcat('DL_171122_1', nbplane, '_reg.sbxreg');
    movefile(newfile, oldfile);
    
%end