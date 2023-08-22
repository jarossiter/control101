% Opens the mlx file in toolbox and saves a copy to student working
% directory so the source is not corrupted

%   Return the full path for desired mlx file


if exist('closedloop_transferfunctions_with_feedback_mycopy.mlx','file')
    disp('Opening existing copy - delete or rename this copy to access toolbox orginal')
    open closedloop_transferfunctions_with_feedback_mycopy.mlx
else
p1 = which('closedloop_transferfunctions_with_feedback_toolbox.mlx');
copyfile(p1,pwd);
system("rename " + "closedloop_transferfunctions_with_feedback_toolbox.mlx" + " " + "closedloop_transferfunctions_with_feedback_mycopy.mlx");
open closedloop_transferfunctions_with_feedback_mycopy.mlx
clear p1
end