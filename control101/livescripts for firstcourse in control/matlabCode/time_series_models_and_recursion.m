% Opens the mlx file in toolbox and saves a copy to student working
% directory so the source is not corrupted

%   Return the full path for desired mlx file


if exist('time_series_models_and_recursion_mycopy.mlx','file')
    disp('Opening existing copy - delete or rename this copy to access toolbox orginal')
    open time_series_models_and_recursion_mycopy.mlx
else
p1 = which('time_series_models_and_recursion_toolbox.mlx');
p2 = strcat(pwd,'/time_series_models_and_recursion_mycopy.mlx');
copyfile(p1,p2)
open time_series_models_and_recursion_mycopy.mlx
clear p1 p2
end