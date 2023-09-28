% Opens the mlx file in toolbox and saves a copy to student working
% directory so the source is not corrupted

%   Return the full path for desired mlx file


if exist('lag_design_with_bode_mycopy.mlx','file')
    disp('Opening existing copy - delete or rename this copy to access toolbox orginal')
    open lag_design_with_bode_mycopy.mlx
else
p1 = which('lag_design_with_bode_toolbox.mlx');
p2 = strcat(pwd,'/lag_design_with_bode_mycopy.mlx');
copyfile(p1,p2)
open lag_design_with_bode_mycopy.mlx
clear p1
end