% Opens the mlx file in toolbox and saves a copy to student working
% directory so the source is not corrupted

%   Return the full path for desired mlx file


if exist('heating_system_simulink_control101_mycopy.mlx','file')
    disp('Opening existing copy - delete or rename this copy to access toolbox orginal')
    open heating_system_simulink_control101_mycopy.mlx
else
    
                p1 = which('heating_system_simulink_control101_toolbox.mlx');
                try copyfile(p1,pwd)
                system("rename " + "heating_system_simulink_control101_toolbox.mlx" + " " + "heating_system_simulink_control101_mycopy.mlx");
                open heating_system_simulink_control101_mycopy.mlx
                catch
                   system("copy " + "heating_system_simulink_control101_toolbox.mlx" + " " + "heating_system_simulink_control101_mycopy.mlx");
                   open heating_system_simulink_control101_mycopy.mlx
                   disp('***********************************************************************************')
                   disp('WARNING - YOU ARE IN THE SAME FOLDER AS THE SOURCES FILES SO MAY BE CORRUPTING THEM')
                   disp('***********************************************************************************')
                end
                clear p1
end

