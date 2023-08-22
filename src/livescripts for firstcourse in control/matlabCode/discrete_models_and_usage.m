% Opens the mlx file in toolbox and saves a copy to student working
% directory so the source is not corrupted

%   Return the full path for desired mlx file


if exist('discrete_models_and_usage_mycopy.mlx','file')
    disp('Opening existing copy - delete or rename this copy to access toolbox orginal')
    open discrete_models_and_usage_mycopy.mlx
else
p1 = which('discrete_models_and_usage_toolbox.mlx');
copyfile(p1,pwd);
system("rename " + "discrete_models_and_usage_toolbox.mlx" + " " + "discrete_models_and_usage_mycopy.mlx");
open discrete_models_and_usage_mycopy.mlx
clear p1
end