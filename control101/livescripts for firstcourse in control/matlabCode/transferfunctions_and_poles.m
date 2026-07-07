% Opens the mlx file in toolbox and saves a copy to student working
% directory so the source is not corrupted

%   Return the full path for desired mlx file


if exist('transferfunctions_and_poles_mycopy.mlx','file')
    disp('Opening existing copy - delete or rename this copy to access toolbox orginal')
    open transferfunctions_and_poles_mycopy.mlx
else
p1 = which('transferfunctions_and_poles_toolbox.mlx');
p2 = strcat(pwd,'/transferfunctions_and_poles_mycopy.mlx');
copyfile(p1,p2)
open transferfunctions_and_poles_mycopy.mlx
clear p1 p2
end