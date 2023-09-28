% Opens the mlx file in toolbox and saves a copy to student working
% directory so the source is not corrupted

%   Return the full path for desired mlx file


if exist('discretisation_and_bode_mycopy.mlx','file')
    disp('Opening existing copy - delete or rename this copy to access toolbox orginal')
    open discretisation_and_bode_mycopy.mlx
else
p1 = which('discretisation_and_bode_toolbox.mlx');
p2 = strcat(pwd,'/discretisation_and_bode_mycopy.mlx');
copyfile(p1,p2)
open discretisation_and_bode_mycopy.mlx
clear p1 p2
end