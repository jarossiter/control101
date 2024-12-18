% Opens the mlx file in toolbox and saves a copy to student working
% directory so the source is not corrupted

%   Return the full path for desired mlx file


if exist('Stability_Discrete_mycopy.mlx','file')
    disp('Opening existing copy - delete or rename this copy to access toolbox orginal')
    open Stability_Discrete_mycopy.mlx
else
p1 = which('Stability_Discrete_tool.mlx');
p2 = strcat(pwd,'/Stability_Discrete_mycopy.mlx');
copyfile(p1,p2)
open Stability_Discrete_mycopy.mlx
clear p1 p2
end