% Opens the mlx file in toolbox and saves a copy to student working
% directory so the source is not corrupted

%   Return the full path for desired mlx file


if exist('delays_and_bode_mycopy.mlx','file')
    disp('Opening existing copy - delete or rename this copy to access toolbox orginal')
    open delays_and_bode_mycopy.mlx
else
p1 = which('delays_and_bode_toolbox.mlx');
copyfile(p1,pwd);
system("rename " + "delays_and_bode_toolbox.mlx" + " " + "delays_and_bode_mycopy.mlx");
open delays_and_bode_mycopy.mlx
clear p1
end