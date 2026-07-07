function packageToolbox()
% Specify the toolbox name and version
toolboxFolder = fileparts(fileparts(mfilename("fullpath"))); 
toolboxRoot = fullfile(toolboxFolder,'control101');


uuid = "Control101Uuid";
opts = matlab.addons.toolbox.ToolboxOptions(toolboxRoot, uuid);

opts.ToolboxName = "Control101";
opts.ToolboxVersion = "1.1";

%Which systems do we support
opts.SupportedPlatforms.Win64 = true;
opts.SupportedPlatforms.Maci64 = false;
opts.SupportedPlatforms.Glnxa64 = true;
opts.SupportedPlatforms.MatlabOnline = true;

%which matlab versions 
opts.MinimumMatlabRelease = "R2017b";
opts.MaximumMatlabRelease = "";

%Author details 
opts.AuthorName = "Dr J Anthony Rossiter";
opts.AuthorCompany = "University of Sheffield";
opts.AuthorEmail = "j.a.rossiter@sheffield.ac.uk";

%Toolbox image 
opts.ToolboxImageFile = fullfile(toolboxFolder,'images/toolboxImage.png');
opts.ToolboxGettingStartedGuide = fullfile(toolboxRoot, 'doc/gettingstarted.mlx');

%Where to put the mltbx file
opts.OutputFile = fullfile(toolboxFolder,'deploy/Control101.mltbx');

%make the mltbx
matlab.addons.toolbox.packageToolbox(opts);

end