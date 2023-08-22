function addFoldersToProject()
% Specify the root directory of your toolbox
toolboxFolder = fileparts(fileparts(mfilename("fullpath"))); % two folders up from THIS .m file
toolboxRoot = fullfile(toolboxFolder,'control101');

%Getting the folder names currently in the src path
folders= dir(toolboxRoot);
folders = {folders.name};
folders = strcat(toolboxRoot,'\',folders);
folders = folders(~contains(folders,[".","LICENSE"]));

%Getting folders currently in the project
proj = openProject(fullfile(toolboxFolder,"Control101_MATLABProject.prj"));
projFiles = [proj.Files.Path];
[projFolders, ~, ~] = fileparts(projFiles);
PF = unique(projFolders);
PF = PF(contains(PF,["control101","deploy"]) & ~contains(PF,["data","matlabCode"])); % only getting top level of folders 

%identify which folders are not currenly in the project 
notInProject = folders(~ismember(string(folders),PF))';

for q = 1:length(notInProject)
    addFolderIncludingChildFiles(proj, char(notInProject(q)));
end
