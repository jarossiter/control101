% Opens the mlx file in toolbox and saves a copy to student working
% directory so the source is not corrupted

%   Return the full path for desired mlx file


if exist('PID_Cont_Controller_Design_with_Pole_Cancellation_mycopy.mlx','file')
    disp('Opening existing copy - delete or rename this copy to access toolbox orginal')
    open PID_Cont_Controller_Design_with_Pole_Cancellation_mycopy.mlx
else
p1 = which('PID_Cont_Controller_Design_with_Pole_Cancellation_toolbox.mlx');
p2 = strcat(pwd,'/PID_Cont_Controller_Design_with_Pole_Cancellation_mycopy.mlx');
copyfile(p1,p2)
open PID_Cont_Controller_Design_with_Pole_Cancellation_mycopy.mlx
clear p1 p2
end