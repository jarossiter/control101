% Opens the mlx file in toolbox and saves a copy to student working
% directory so the source is not corrupted

%   Return the full path for desired mlx file


if exist('Stability_Continuous_mycopy.mlx','file')
    disp('Opening existing copy - delete or rename this copy to access toolbox orginal')
    open Stability_Continuous_mycopy.mlx
else
p1 = which('Stability_Continuous_tool.mlx');
p2 = strcat(pwd,'/Stability_Continuous_mycopy.mlx');
copyfile(p1,p2)
open Stability_Continuous_mycopy.mlx
clear p1 p2
end