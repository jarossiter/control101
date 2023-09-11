% Opens the mlx file in toolbox and saves a copy to student working
% directory so the source is not corrupted

%   Return the full path for desired mlx file


if exist('secondordermodels_in_matlab_mycopy.mlx','file')
    disp('Opening existing copy - delete or rename this copy to access toolbox orginal')
    open secondordermodels_in_matlab_mycopy.mlx
else
p1 = which('secondordermodels_in_matlab_toolbox.mlx');
copyfile(p1,pwd);
system("rename " + "secondordermodels_in_matlab_toolbox.mlx" + " " + "secondordermodels_in_matlab_mycopy.mlx");
open secondordermodels_in_matlab_mycopy.mlx
clear p1
end