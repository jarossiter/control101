% Opens the mlx file in toolbox and saves a copy to student working
% directory so the source is not corrupted

%   Return the full path for desired mlx file


if exist('closed_loop_compare_multiple_compensators_mycopy.mlx','file')
    disp('Opening existing copy - delete or rename this copy to access toolbox orginal')
    open closed_loop_compare_multiple_compensators_mycopy.mlx
else
p1 = which('closed_loop_compare_multiple_compensators_toolbox.mlx');
copyfile(p1,pwd);
system("rename " + "closed_loop_compare_multiple_compensators_toolbox.mlx" + " " + "closed_loop_compare_multiple_compensators_mycopy.mlx");
open closed_loop_compare_multiple_compensators_mycopy.mlx
clear p1
end