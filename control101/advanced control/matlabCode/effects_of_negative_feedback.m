% Opens the mlx file in toolbox and saves a copy to student working
% directory so the source is not corrupted

%   Return the full path for desired mlx file


if exist('effects_of_negative_feedback_mycopy.mlx','file')
    disp('Opening existing copy - delete or rename this copy to access toolbox orginal')
    open effects_of_negative_feedback_mycopy.mlx
else
p1 = which('effects_of_negative_feedback_toolbox.mlx');
p2 = strcat(pwd,'/effects_of_negative_feedback_mycopy.mlx');
copyfile(p1,p2)
open effects_of_negative_feedback_mycopy.mlx
clear p1 p2
end