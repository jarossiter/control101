% Opens the mlx file in toolbox and saves a copy to student working
% directory so the source is not corrupted

%   Return the full path for desired mlx file


if exist('secondordermodels_and_underdamping_mycopy.mlx','file')
    disp('Opening existing copy - delete or rename this copy to access toolbox orginal')
    open secondordermodels_and_underdamping_mycopy.mlx
else
p1 = which('secondordermodels_and_underdamping_toolbox.mlx');
p2 = strcat(pwd,'/secondordermodels_and_underdamping_mycopy.mlx');
copyfile(p1,p2)
open secondordermodels_and_underdamping_mycopy.mlx
clear p1 p2
end