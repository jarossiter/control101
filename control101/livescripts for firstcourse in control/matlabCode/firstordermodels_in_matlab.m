% Opens the mlx file in toolbox and saves a copy to student working
% directory so the source is not corrupted

%   Return the full path for desired mlx file


if exist('firstordermodels_in_matlab_mycopy.mlx','file')
    disp('Opening existing copy - delete or rename this copy to access toolbox orginal')
    open firstordermodels_in_matlab_mycopy.mlx
else
p1 = which('firstordermodels_in_matlab_toolbox.mlx');
copyfile(p1,pwd);
system("rename " + "firstordermodels_in_matlab_toolbox.mlx" + " " + "firstordermodels_in_matlab_mycopy.mlx");
open firstordermodels_in_matlab_mycopy.mlx
clear p1
end