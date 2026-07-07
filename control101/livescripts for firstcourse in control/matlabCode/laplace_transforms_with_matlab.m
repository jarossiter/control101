% Opens the mlx file in toolbox and saves a copy to student working
% directory so the source is not corrupted

%   Return the full path for desired mlx file


if exist('laplace_transforms_with_matlab_mycopy.mlx','file')
    disp('Opening existing copy - delete or rename this copy to access toolbox orginal')
    open laplace_transforms_with_matlab_mycopy.mlx
else
p1 = which('laplace_transforms_with_matlab_toolbox.mlx');
p2 = strcat(pwd,'/laplace_transforms_with_matlab_mycopy.mlx');
copyfile(p1,p2)
open laplace_transforms_with_matlab_mycopy.mlx
clear p1
end