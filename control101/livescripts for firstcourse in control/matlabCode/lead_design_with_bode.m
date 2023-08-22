% Opens the mlx file in toolbox and saves a copy to student working
% directory so the source is not corrupted

%   Return the full path for desired mlx file


if exist('lead_design_with_bode_mycopy.mlx','file')
    disp('Opening existing copy - delete or rename this copy to access toolbox orginal')
    open lead_design_with_bode_mycopy.mlx
else
p1 = which('lead_design_with_bode_toolbox.mlx');
copyfile(p1,pwd);
system("rename " + "lead_design_with_bode_toolbox.mlx" + " " + "lead_design_with_bode_mycopy.mlx");
open lead_design_with_bode_mycopy.mlx
clear p1
end