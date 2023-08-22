% Opens the mlx file in toolbox and saves a copy to student working
% directory so the source is not corrupted

%   Return the full path for desired mlx file


if exist('bode_asymptotes_mycopy.mlx','file')
    disp('Opening existing copy - delete or rename this copy to access toolbox orginal')
    open bode_asymptotes_mycopy.mlx
else
p1 = which('bode_asymptotes_toolbox.mlx');
copyfile(p1,pwd);
system("rename " + "bode_asymptotes_toolbox.mlx" + " " + "bode_asymptotes_mycopy.mlx");
open bode_asymptotes_mycopy.mlx
clear p1
end