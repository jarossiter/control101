%
%            Control 101 toolbox files
% 
%  For a more detailed overview, see the website:
%  https://controleducation.sites.sheffield.ac.uk/matlabresources/section-6-11-community-control-toolbox
%
%  Alternatively for documentation click <a href="matlab: doc Control101 Toolbox">here</a>.
%  
%  or type directly in the command window:     doc Control101 Toolbox
% There is a bug in 2024a: Try doc ("Control101 Toolbox")  or doc control101_toolbox. 
%  
%  NOTE: "help control101" should also work, but only if the toolbox is installed
%
%
% Virtual Laboratories/MATLAB apps: Assuming the toolbox has been installed,
% the apps should appear under the apps tab so you can open from there or using the links below.
%
%   <a href="matlab: aeroplanelanding_behaviour">aeroplanelanding_behaviour</a>
%   <a href="matlab: carmodel_and_behaviour">carmodel_and_behaviour</a>     
%   <a href="matlab: cruisecontrol">cruisecontrol</a>                                      
%   <a href="matlab: dcservo_and_position_control">dcservo_and_position_control</a>                       
%   <a href="matlab: firstordermodel_behaviour">firstordermodel_behaviour</a>                       
%   <a href="matlab: firstordermodels_response_characterisation">firstordermodels_response_characterisation</a> 
%   <a href="matlab: HeatExchanger">HeatExchanger</a>                     
%   <a href="matlab: housetemperature_and_behaviour">housetemperature_and_behaviour</a>                     
%   <a href="matlab: housetemperature_story">housetemperature_story</a>                     
%   <a href="matlab: invertedpendulum">invertedpendulum</a>         
%   <a href="matlab: mixingtank_and_behaviour">mixingtank_and_behaviour</a>                           
%   <a href="matlab: tanklevel_and_PIcontrol">tanklevel_and_PIcontrol</a>                            
%   <a href="matlab: tanklevelbehaviour">tanklevelbehaviour</a>
%   <a href="matlab: tanklevel_story">tanklevel_story</a>
%   <a href="matlab: behaviours">behaviours</a>
%   <a href="matlab: Predator_prey_model">Predator_prey_model</a>
%   <a href="matlab: pi_tuning">pi_tuning</a>
%   <a href="matlab: pidtuningrules">pidtuningrules</a>
%  
%   FREQUENCY RESPONSE METHODS
%   <a href="matlab: frequency_response_time_behaviour">frequency_response_time_behaviour</a> 
%   <a href="matlab: proportional_design_phase_margin">proportional_design_phase_margin</a>
%   <a href="matlab: lag_design_phase_margin">lag_design_phase_margin</a>
%   <a href="matlab: lead_design_phase_margin">lead_design_phase_margin</a>
%   <a href="matlab: lead_lag_design_phase_margin">lead_lag_design_phase_margin</a>
%   <a href="matlab: lead_lag_design_criteria">lead_lag_design_criteria</a>
%   <a href="matlab: aeroplane_roll_control">aeroplane_roll_control</a>
%
%
% Livescript files for learning control basics alongside simple MATLAB code
% for analysis and evaluation. These files open a duplicate livescript file
% in the pwd directly so the user can make edits and save these. You can
% open by typing the name or selecting the links below.
%
%   <a href="matlab: plotting_with_matlab">plotting_with_matlab</a>                                      
%   <a href="matlab: ODEs_with_matlab">ODEs_with_matlab</a>                                                                                                 
%   <a href="matlab: firstordermodels_in_matlab">firstordermodels_in_matlab</a>                                
%   <a href="matlab: firstordermodels_responses_analysis_and_feedback">firstordermodels_responses_analysis_and_feedback</a>          
%   <a href="matlab: secondordermodels_and_underdamping">secondordermodels_and_underdamping</a>                        
%   <a href="matlab: secondordermodels_in_matlab">secondordermodels_in_matlab</a>                               
%   <a href="matlab: laplace_transforms_with_matlab">laplace_transforms_with_matlab</a>                            
%   <a href="matlab: partial_fractions_with_matlab">partial_fractions_with_matlab</a>                                                                   
%   <a href="matlab: step_responses_with_matlab">step_responses_with_matlab</a>                                
%   <a href="matlab: transferfunctions_and_behaviours">transferfunctions_and_behaviours</a>    
%   <a href="matlab: transferfunctions_and_poles">transferfunctions_and_poles</a>   
%   <a href="matlab: closedloop_transferfunctions_with_feedback">closedloop_transferfunctions_with_feedback</a>                
%   <a href="matlab: closedloop_offset_and_poles">closedloop_offset_and_poles</a>                               
%   <a href="matlab: closed_loop_compare_multiple_compensators">closed_loop_compare_multiple_compensators</a>         
%   <a href="matlab: closed_vs_openloop_overlay">closed_vs_openloop_overlay</a>                                
%   <a href="matlab: PID_tuning_methods">PID_tuning_methods</a>
%   <a href="matlab: PID_Cont_Controller_Design_with_Pole_Cancellation">PID_Cont_Controller_Design_with_Pole_Cancellation</a>
%
% 
%  FREQUENCY RESPONSE METHODS
%   <a href="matlab: freq_responses_with_matlab">freq_responses_with_matlab</a>                                
%   <a href="matlab: bode_asymptotes">bode_asymptotes</a> 
%   <a href="matlab: proportional_design_with_bode">proportional_design_with_bode</a>                             
%   <a href="matlab: Stability_Continuous">Stability_Continuous</a>    
%   <a href="matlab: lag_design_with_bode">lag_design_with_bode</a>   
%   <a href="matlab: lead_design_with_bode">lead_design_with_bode</a>                                     
%   <a href="matlab: lead_lag_design_with_bode">lead_lag_design_with_bode</a>  
%   <a href="matlab: lead_lag_design_with_criteria">lead_lag_design_with_criteria</a>
%
%  DISCRETE MODELS AND ADVANCED METHODS
%   <a href="matlab: time_series_models">time_series_models</a>                                        
%   <a href="matlab: time_series_models_and_recursion">time_series_models_and_recursion</a>  
%   <a href="matlab: delays_and_bode">delays_and_bode</a>                                                                          
%   <a href="matlab: discrete_models_and_usage">discrete_models_and_usage</a>                                 
%   <a href="matlab: discretisation_and_bode">discretisation_and_bode</a>
%   <a href="matlab: Stability_Discrete">Stability_Discrete</a>
%   <a href="matlab: discrete_models_and_discrete_PID_controller_design">discrete_models_and_discrete_PID_controller_design</a>
%   <a href="matlab: Youla_continuous_controller_design">Youla_continuous_controller_design</a>
%   <a href="matlab: PID_Cont_Controller_Design_with_Pole_Cancellation">PID_Cont_Controller_Design_with_Pole_Cancellation</a>
%
%
%  SIMULINK FILES AND THEIR USE FOR MODELLING, SIMULATION AND CONTROL AND
%  NONLINEARITY
%
%   <a href="matlab: myfirstsimulink_control101 ">myfirstsimulink_control101</a>
%   <a href="matlab: intro_to_simulink_for_system_behaviour">intro_to_simulink_for_system_behaviour</a>
%   <a href="matlab: hydraulic_system_simulink_control101 ">hydraulic_system_simulink_control101</a>
%   <a href="matlab: car_suspension_simulink_control101">car_suspension_simulink_control101</a>
%   <a href="matlab: heating_system_simulink_control101">heating_system_simulink_control101</a>
%   <a href="matlab: submersible_system_simulink_control101">submersible_system_simulink_control101</a>
%   <a href="matlab: position_system_simulink_control101">position_system_simulink_control101</a>
%   <a href="matlab: nonlinear_position_control">nonlinear_position_control</a>
%   <a href="matlab: nonlinear_tank_behaviour_control101">nonlinear_tank_behaviour_control101</a>
%   <a href="matlab: nonlinear_tank_control_control101">nonlinear_tank_control_control101</a>
%
% STATE SPACE SYSTEMS AND INTRODUCTORY ANALYSIS
%
%   <a href="matlab: statespace_models_control101">statespace_models_control101</a>
%   <a href="matlab: statespace_models_from_tf_control101">statespace_models_from_tf_control101</a>
%   <a href="matlab: tf_models_from_statespace_control101">tf_models_from_statespace_control101</a>
%   <a href="matlab: discrete_time_state_space_models_control101">discrete_time_state_space_models_control101</a>   
%   <a href="matlab: openloop_behaviour_statespace_control101">openloop_behaviour_statespace_control101</a>   
%   <a href="matlab: phaseplane_behaviour_statespace_control101">phaseplane_behaviour_statespace_control101</a>  
%   <a href="matlab: equivalent_state_space_formulations_control101">equivalent_state_space_formulations_control101</a>   
%   <a href="matlab: controllability_and_observability_control101">controllability_and_observability_control101</a>   
%   <a href="matlab: state_feedback_control101">state_feedback_control101</a>
%   <a href="matlab: optimal_state_feedback_control101">optimal_state_feedback_control101</a>
%   <a href="matlab: observer_design_control101">observer_design_control101</a>
%   <a href="matlab: tracking_with_statespace_control101">tracking_with_statespace_control101</a>
%   <a href="matlab: state_feedback_and_estimation_cont_case_study">state_feedback_and_estimation_cont_case_study</a>
%   <a href="matlab: state_feedback_and_state_estimation_discrete_case_study">state_feedback_and_state_estimation_discrete_case_study</a>
%          SIMULINK FILES SUPPORTING STATE SPACE SYSTEMS
%   <a href="matlab: state_space_and_simulinkfile1_control101">state_space_and_simulinkfile1_control101</a>
%   <a href="matlab: state_space_and_simulinkfile2_control101">state_space_and_simulinkfile2_control101</a>
%   <a href="matlab: state_space_and_simulinkfile3_control101">state_space_and_simulinkfile3_control101</a>