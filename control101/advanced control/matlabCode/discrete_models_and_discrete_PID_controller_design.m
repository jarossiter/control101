% Opens the mlx file in toolbox and saves a copy to student working
% directory so the source is not corrupted
%   Return the full path for desired mlx file
if exist('discrete_models_and_discrete_PID_controller_design_mycopy.mlx','file')
    disp('Opening existing copy - delete or rename this copy to access toolbox orginal')
    open discrete_models_and_discrete_PID_controller_design_mycopy.mlx
else
    p1 = which('discrete_models_and_discrete_PID_controller_design_toolbox.mlx');
    p2 = strcat(pwd,'/discrete_models_and_discrete_PID_controller_design_mycopy.mlx');
    copyfile(p1,p2)
    open discrete_models_and_discrete_PID_controller_design_mycopy.mlx
    clear p1 p2
end