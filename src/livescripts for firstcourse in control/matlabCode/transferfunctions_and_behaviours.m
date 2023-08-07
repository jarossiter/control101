% Opens the mlx file in toolbox and saves a copy to student working
% directory so the source is not corrupted

%   Return the full path for desired mlx file


if exist('transferfunctions_and_behaviours_mycopy.mlx','file')
    disp('Opening existing copy - delete or rename this copy to access toolbox orginal')
    open transferfunctions_and_behaviours_mycopy.mlx
else
p1 = which('transferfunctions_and_behaviours_toolbox.mlx');
copyfile(p1,pwd);
system("rename " + "transferfunctions_and_behaviours_toolbox.mlx" + " " + "transferfunctions_and_behaviours_mycopy.mlx");
open transferfunctions_and_behaviours_mycopy.mlx
clear p1
end