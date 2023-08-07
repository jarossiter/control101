% Opens the mlx file in toolbox and saves a copy to student working
% directory so the source is not corrupted

%   Return the full path for desired mlx file


if exist('closedloop_offset_and_poles_mycopy.mlx','file')
    disp('Opening existing copy - delete or rename this copy to access toolbox orginal')
    open closedloop_offset_and_poles_mycopy.mlx
else
p1 = which('closedloop_offset_and_poles_toolbox.mlx');
copyfile(p1,pwd);
system("rename " + "closedloop_offset_and_poles_toolbox.mlx" + " " + "closedloop_offset_and_poles_mycopy.mlx");
open closedloop_offset_and_poles_mycopy.mlx
clear p1
end