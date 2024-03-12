% Opens the mlx file in toolbox and saves a copy to student working
% directory so the source is not corrupted

%   Return the full path for desired mlx file


if exist('intro_to_simulink_for_system_behaviour_mycopy.mlx','file')
    disp('Opening existing copy - delete or rename this copy to access toolbox orginal')
    open intro_to_simulink_for_system_behaviour_mycopy.mlx
else
    
                p1 = which('intro_to_simulink_for_system_behaviour_toolbox.mlx');
                try copyfile(p1,pwd)
                system("rename " + "intro_to_simulink_for_system_behaviour_toolbox.mlx" + " " + "intro_to_simulink_for_system_behaviour_mycopy.mlx");
                open intro_to_simulink_for_system_behaviour_mycopy.mlx
                catch
                   system("copy " + "intro_to_simulink_for_system_behaviour_toolbox.mlx" + " " + "intro_to_simulink_for_system_behaviour_mycopy.mlx");
                   open intro_to_simulink_for_system_behaviour_mycopy.mlx
                   disp('***********************************************************************************')
                   disp('WARNING - YOU ARE IN THE SAME FOLDER AS THE SOURCES FILES SO MAY BE CORRUPTING THEM')
                   disp('***********************************************************************************')
                end
                clear p1
end

