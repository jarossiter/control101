% Opens the mlx file in toolbox and saves a copy to student working
% directory so the source is not corrupted

%   Return the full path for desired mlx file


if exist('PID_tuning_methods_mycopy.mlx','file')
    disp('Opening existing copy - delete or rename this copy to access toolbox orginal')
    open PID_tuning_methods_mycopy.mlx
else
p1 = which('PID_tuning_methods_toolbox.mlx');
p2 = strcat(pwd,'/PID_tuning_methods_mycopy.mlx');
copyfile(p1,p2)
open PID_tuning_methods_mycopy.mlx
clear p1 p2
end