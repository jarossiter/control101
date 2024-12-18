% Opens the mlx file in toolbox and saves a copy to student working
% directory so the source is not corrupted

%   Return the full path for desired mlx file


if exist('Smith_predictor_controller_design_mycopy.mlx','file')
    disp('Opening existing copy - delete or rename this copy to access toolbox orginal')
    open Smith_predictor_controller_design_mycopy.mlx
else
p1 = which('Smith_predictor_controller_design_toolbox.mlx');
p2 = strcat(pwd,'/Smith_predictor_controller_design_mycopy.mlx');
copyfile(p1,p2)
open Smith_predictor_controller_design_mycopy.mlx
clear p1 p2
end