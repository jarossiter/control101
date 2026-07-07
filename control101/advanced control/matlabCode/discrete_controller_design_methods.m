% Opens the mlx file in toolbox and saves a copy to student working
% directory so the source is not corrupted

%   Return the full path for desired mlx file


if exist('discrete_controller_design_methods_mycopy.mlx','file')
    disp('Opening existing copy - delete or rename this copy to access toolbox orginal')
    open discrete_controller_design_methods_mycopy.mlx
else
p1 = which('discrete_controller_design_methods_toolbox.mlx');
p2 = strcat(pwd,'/discrete_controller_design_methods_mycopy.mlx');
copyfile(p1,p2)
open discrete_controller_design_methods_mycopy.mlx
clear p1 p2
end