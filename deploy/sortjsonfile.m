cd ..
currentfolder = cd;
filePath = [currentfolder,'\control1\doc\custom_toolbox.json']
if exist(filePath, 'file') == 2    % File exists, delete it    
    delete(filePath);
end

folderPath = [currentfolder,'\control1\doc\control101\doc\helpsearch-v4_en'];
if exist(folderPath, 'dir') == 2    % File exists, delete it    
    rmdir(folderPath,'s');
end
cd \control101\doc

builddocsearchdb('G:\Other computers\Office desktop 2024\Documents\matlab project\control101\control101\doc')

cd deploy