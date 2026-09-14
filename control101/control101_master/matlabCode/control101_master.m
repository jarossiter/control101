classdef control101_master < matlab.apps.AppBase

    % Properties that correspond to app components
    properties (Access = public)
        UIFigure                        matlab.ui.Figure
        GridLayout                      matlab.ui.container.GridLayout
        TabGroup                        matlab.ui.container.TabGroup
        ControlfundamentalsTab          matlab.ui.container.Tab
        GridLayout7                     matlab.ui.container.GridLayout
        SimulationwithuncertaintyButton  matlab.ui.control.Button
        ThesefilescombineMATLABexamplesandabel  matlab.ui.control.Label
        IntroductiontoPIDtuningButton   matlab.ui.control.Button
        OverlayplotsfrommultiplescenariosButton  matlab.ui.control.Button
        ComparemultiplecompensatorsButton  matlab.ui.control.Button
        ClosedloopoffsetandpolesButton  matlab.ui.control.Button
        ClosedlooptransferfunctionsButton  matlab.ui.control.Button
        EffectsoffeedbackButton         matlab.ui.control.Button
        TransferfunctionsandpolesButton  matlab.ui.control.Button
        TransferfunctionsandbehaviourButton  matlab.ui.control.Button
        StepresponsesButton             matlab.ui.control.Button
        PartialfractionsButton          matlab.ui.control.Button
        LaplaceTransformsButton         matlab.ui.control.Button
        SecondorderresponsesButton      matlab.ui.control.Button
        SecondordermodelsButton         matlab.ui.control.Button
        FirstorderresponsesButton       matlab.ui.control.Button
        FirstordermodelsinmatlabButton  matlab.ui.control.Button
        ODEswithMATLABButton            matlab.ui.control.Button
        ControlfundamentalspleaseuseintheorderpresentedLabel  matlab.ui.control.Label
        PlottingwithmatlabButton        matlab.ui.control.Button
        VirtuallaboratoriesTab          matlab.ui.container.Tab
        GridLayout8                     matlab.ui.container.GridLayout
        RacecaronatrackwithPIButton     matlab.ui.control.Button
        TwotankscontrolButton           matlab.ui.control.Button
        RCcircuitbehaviourButton        matlab.ui.control.Button
        SystembehavioursButton          matlab.ui.control.Button
        TankleveldesignstepsButton      matlab.ui.control.Button
        NonlineartankcontrolButton      matlab.ui.control.Button
        PIDtuningButton                 matlab.ui.control.Button
        PItuningButton                  matlab.ui.control.Button
        ConicaltankcontrolButton        matlab.ui.control.Button
        OpenloopvsclosedloopButton      matlab.ui.control.Button
        DCmotorcontrolButton            matlab.ui.control.Button
        InvertedpendulumcontrolButton   matlab.ui.control.Button
        HousetemperaturecontrolButton   matlab.ui.control.Button
        TanklevelcontrolButton          matlab.ui.control.Button
        CruisecontrolwithPIButton       matlab.ui.control.Button
        storderbehavioursButton         matlab.ui.control.Button
        stordermodellingButton          matlab.ui.control.Button
        ManualcontroloftanklevelButton  matlab.ui.control.Button
        ConicaltanksButton              matlab.ui.control.Button
        NonlineartanksButton            matlab.ui.control.Button
        PredatorpreysystemsButton       matlab.ui.control.Button
        DiabetesButton                  matlab.ui.control.Button
        AeroplanelandingButton          matlab.ui.control.Button
        HousetemperatureButton          matlab.ui.control.Button
        MixingtankButton                matlab.ui.control.Button
        HeatexchangerButton             matlab.ui.control.Button
        TankLevelButton                 matlab.ui.control.Button
        CarvelocityButton               matlab.ui.control.Button
        VirtualLaboratoriesbehavioursandcontrolLabel  matlab.ui.control.Label
        StatespacemethodsTab            matlab.ui.container.Tab
        GridLayout9                     matlab.ui.container.GridLayout
        ThesefilescombineMATLABexampLabel  matlab.ui.control.Label
        ImplementationonSIMULINK3Button  matlab.ui.control.Button
        ImplementationonSIMULINK2Button  matlab.ui.control.Button
        ImplementationonSIMULINK1Button  matlab.ui.control.Button
        DiscreteimplementationsButton   matlab.ui.control.Button
        FeedbackwithestimationButton    matlab.ui.control.Button
        TrackingdesignButton            matlab.ui.control.Button
        ObserverdesignButton            matlab.ui.control.Button
        OptimalstatefeedbackButton      matlab.ui.control.Button
        StatefeedbackButton             matlab.ui.control.Button
        EigenvaluesButton               matlab.ui.control.Button
        StabilityanalysisButton         matlab.ui.control.Button
        ControllabilityObservabilityButton  matlab.ui.control.Button
        EquivalentSSmodelsButton        matlab.ui.control.Button
        PhaseplanebehaviourButton       matlab.ui.control.Button
        BehaviourofSSmodelsButton       matlab.ui.control.Button
        DiscreteSSmodelsButton          matlab.ui.control.Button
        TFfromstatespaceButton          matlab.ui.control.Button
        StatespacefromTFButton          matlab.ui.control.Button
        StatespacemodelsButton          matlab.ui.control.Button
        StatespacemethodslivescriptfilesLabel  matlab.ui.control.Label
        FrequencyresponseTab            matlab.ui.container.Tab
        GridLayout12                    matlab.ui.container.GridLayout
        Label_2                         matlab.ui.control.Label
        DesignfromcriteriaButton        matlab.ui.control.Button
        ThedesignmethodsgivenhereareformulaicLabel  matlab.ui.control.Label
        AeroplanerollexampleButton      matlab.ui.control.Button
        DesignfromcriteriatheoryButton  matlab.ui.control.Button
        LeadlagdesignButton             matlab.ui.control.Button
        LeaddesignButton                matlab.ui.control.Button
        LagdesignButton                 matlab.ui.control.Button
        ProportionaldesignButton        matlab.ui.control.Button
        WhatisfrequencyresponseButton   matlab.ui.control.Button
        StabilityanalysisButton_2       matlab.ui.control.Button
        ImpactofdelaysButton            matlab.ui.control.Button
        LeadlagdesignwithBodeButton     matlab.ui.control.Button
        LeaddesignwithBodeButton        matlab.ui.control.Button
        LagdesignwithBodeButton         matlab.ui.control.Button
        ProportionaldesignBodeButton    matlab.ui.control.Button
        BodeasymptotesButton            matlab.ui.control.Button
        FrequencyresponsebasicsButton   matlab.ui.control.Button
        FrequencyresponsevirtuallaboratoriesLabel  matlab.ui.control.Label
        FrequencyresponselivescriptfilesLabel  matlab.ui.control.Label
        SimulinkTab                     matlab.ui.container.Tab
        GridLayout10                    matlab.ui.container.GridLayout
        TwotankssystemButton            matlab.ui.control.Button
        SimpleexamplesButton            matlab.ui.control.Button
        LinearisationButton             matlab.ui.control.Button
        ThesimulinkfilesLabel           matlab.ui.control.Label
        SeeseveralmorefilesinthevirtuallaboratoriesTABLabel  matlab.ui.control.Label
        SeethefileswithinthestatespaceTABformoreexamplesLabel  matlab.ui.control.Label
        NonlineartankcontrolButton_2    matlab.ui.control.Button
        NonlineartankbehaviourButton    matlab.ui.control.Button
        NonlinearpositioncontrolButton  matlab.ui.control.Button
        IntroductiontosimulinkmodelsButton  matlab.ui.control.Button
        MyfirstsimulinkmodelButton      matlab.ui.control.Button
        PositioncontrolButton           matlab.ui.control.Button
        SubmersibleButton               matlab.ui.control.Button
        HeatingsystemButton             matlab.ui.control.Button
        CarsuspensionButton             matlab.ui.control.Button
        HydraulicsystemButton           matlab.ui.control.Button
        SimulinkfilesandnonlinearsystemsvirtuallaboratoriesLabel  matlab.ui.control.Label
        SimulinkfilesandnonlinearsystemslivescriptfilesLabel  matlab.ui.control.Label
        SampleddatasystemsTab           matlab.ui.container.Tab
        GridLayout11                    matlab.ui.container.GridLayout
        SignaltypesincomputercontrolButton  matlab.ui.control.Button
        SamplingoperationButton         matlab.ui.control.Button
        SampleddatasystemsButton        matlab.ui.control.Button
        SignalreconstructionButton      matlab.ui.control.Button
        SignaltypeswithsamplingButton   matlab.ui.control.Button
        ClosedloopundersamplingButton   matlab.ui.control.Button
        ContinuousanddiscretemappingButton  matlab.ui.control.Button
        DigitaltoanalogueconvertorButton  matlab.ui.control.Button
        AnaloguetodigitalconvertorButton  matlab.ui.control.Button
        Manyofthesefilesgofarbeyonda1sLabel  matlab.ui.control.Label
        DiscretemethodsButton           matlab.ui.control.Button
        DiscreteYouladesignButton       matlab.ui.control.Button
        YouladesignButton               matlab.ui.control.Button
        PIDviapolecancellationButton    matlab.ui.control.Button
        SmithpredictorButton            matlab.ui.control.Button
        DeadbeatcontrolButton           matlab.ui.control.Button
        DiscretePIDButton               matlab.ui.control.Button
        ControlstructuresButton         matlab.ui.control.Button
        AntiresetwindupButton           matlab.ui.control.Button
        StabilityofdiscreteButton       matlab.ui.control.Button
        DiscretisationandBodeButton     matlab.ui.control.Button
        DiscretemodelsButton            matlab.ui.control.Button
        TimeseriesandrecursionButton    matlab.ui.control.Button
        TimeseriesmodelsButton          matlab.ui.control.Button
        AdvancedcontrolanddiscretesystemsappsinlightercolourLabel  matlab.ui.control.Label
        ModelPredictiveControlTab       matlab.ui.container.Tab
        GridLayout13                    matlab.ui.container.GridLayout
        MPCandfeedforwardButton         matlab.ui.control.Button
        MPCandconstrainthandlingButton  matlab.ui.control.Button
        MPCwithaTfilterButton           matlab.ui.control.Button
        MPCfailingButton                matlab.ui.control.Button
        MPCtuningButton                 matlab.ui.control.Button
        ConceptsofpredictionButton      matlab.ui.control.Button
        SourcefilesButton               matlab.ui.control.Button
        ModelpredictivecontrolanintroductionLabel  matlab.ui.control.Label
        Label                           matlab.ui.control.Label
        Hyperlink                       matlab.ui.control.Hyperlink
        GridLayout3                     matlab.ui.container.GridLayout
        Image                           matlab.ui.control.Image
        CONTROL101toolboxLabel          matlab.ui.control.Label
        GridLayout2                     matlab.ui.container.GridLayout
        SelectTABthemeandpressbuttontoselectfileLabel  matlab.ui.control.Label
        Thisisalauncherforthefilesincontrol101Label  matlab.ui.control.Label
    end

    % Callbacks that handle component events
    methods (Access = private)

        % Button pushed function: PlottingwithmatlabButton
        function PlottingwithmatlabButtonPushed(app, event)
            plotting_with_matlab
        end

        % Button pushed function: ODEswithMATLABButton
        function ODEswithMATLABButtonPushed(app, event)
            ODEs_with_matlab
        end

        % Button pushed function: FirstordermodelsinmatlabButton
        function FirstordermodelsinmatlabButtonPushed(app, event)
            firstordermodels_in_matlab
        end

        % Button pushed function: FirstorderresponsesButton
        function FirstorderresponsesButtonPushed(app, event)
            firstordermodels_responses_analysis_and_feedback
        end

        % Button pushed function: SecondordermodelsButton
        function SecondordermodelsButtonPushed(app, event)
            secondordermodels_in_matlab
        end

        % Button pushed function: SecondorderresponsesButton
        function SecondorderresponsesButtonPushed(app, event)
            secondordermodels_and_underdamping
        end

        % Button pushed function: LaplaceTransformsButton
        function LaplaceTransformsButtonPushed(app, event)
            laplace_transforms_with_matlab
        end

        % Button pushed function: PartialfractionsButton
        function PartialfractionsButtonPushed(app, event)
            partial_fractions_with_matlab
        end

        % Button pushed function: StepresponsesButton
        function StepresponsesButtonPushed(app, event)
            step_responses_with_matlab
        end

        % Button pushed function: TransferfunctionsandbehaviourButton
        function TransferfunctionsandbehaviourButtonPushed(app, event)
            transferfunctions_and_behaviours
        end

        % Button pushed function: TransferfunctionsandpolesButton
        function TransferfunctionsandpolesButtonPushed(app, event)
            transferfunctions_and_poles
        end

        % Button pushed function: EffectsoffeedbackButton
        function EffectsoffeedbackButtonPushed(app, event)
            effects_of_negative_feedback
        end

        % Button pushed function: ClosedlooptransferfunctionsButton
        function ClosedlooptransferfunctionsButtonPushed(app, event)
            closedloop_transferfunctions_with_feedback
        end

        % Button pushed function: ClosedloopoffsetandpolesButton
        function ClosedloopoffsetandpolesButtonPushed(app, event)
            closedloop_offset_and_poles
        end

        % Button pushed function: ComparemultiplecompensatorsButton
        function ComparemultiplecompensatorsButtonPushed(app, event)
            closed_loop_compare_multiple_compensators
        end

        % Button pushed function: OverlayplotsfrommultiplescenariosButton
        function OverlayplotsfrommultiplescenariosButtonPushed(app, event)
            closed_vs_openloop_overlay
        end

        % Button pushed function: IntroductiontoPIDtuningButton
        function IntroductiontoPIDtuningButtonPushed(app, event)
            PID_tuning_methods
        end

        % Button pushed function: SimulationwithuncertaintyButton
        function SimulationwithuncertaintyButtonPushed(app, event)
            uncertainty_simulations_control101_tool
        end

        % Button pushed function: CarvelocityButton
        function CarvelocityButtonPushed(app, event)
            carmodel_and_behaviour
        end

        % Button pushed function: TankLevelButton
        function TankLevelButtonPushed(app, event)
            tanklevelbehaviour
        end

        % Button pushed function: HeatexchangerButton
        function HeatexchangerButtonPushed(app, event)
            HeatExchanger
        end

        % Button pushed function: HousetemperatureButton
        function HousetemperatureButtonPushed(app, event)
            housetemperature_and_behaviour
        end

        % Button pushed function: MixingtankButton
        function MixingtankButtonPushed(app, event)
            mixingtank_and_behaviour
        end

        % Button pushed function: RCcircuitbehaviourButton
        function RCcircuitbehaviourButtonPushed(app, event)
            rc_circuit_behaviour_control101
        end

        % Button pushed function: AeroplanelandingButton
        function AeroplanelandingButtonPushed(app, event)
            aeroplanelanding_behaviour
        end

        % Button pushed function: DiabetesButton
        function DiabetesButtonPushed(app, event)
            diabetes_control101
        end

        % Button pushed function: PredatorpreysystemsButton
        function PredatorpreysystemsButtonPushed(app, event)
            Predator_prey_model
        end

        % Button pushed function: NonlineartanksButton
        function NonlineartanksButtonPushed(app, event)
            nonlinear_tank_behaviour_control101
        end

        % Button pushed function: ConicaltanksButton
        function ConicaltanksButtonPushed(app, event)
            conical_tank_behaviour_control101
        end

        % Button pushed function: ConicaltankcontrolButton
        function ConicaltankcontrolButtonPushed(app, event)
            conical_tank_control_control101
        end

        % Button pushed function: storderbehavioursButton
        function storderbehavioursButtonPushed(app, event)
            firstordermodel_behaviour
        end

        % Button pushed function: stordermodellingButton
        function stordermodellingButtonPushed(app, event)
            firstordermodel_response_characterisation
        end

        % Button pushed function: ManualcontroloftanklevelButton
        function ManualcontroloftanklevelButtonPushed(app, event)
            tank_and_manual_vs_PIcontrol_delay
        end

        % Button pushed function: CruisecontrolwithPIButton
        function CruisecontrolwithPIButtonPushed(app, event)
            cruisecontrol
        end

        % Button pushed function: TanklevelcontrolButton
        function TanklevelcontrolButtonPushed(app, event)
            tanklevel_and_PIcontrol
        end

        % Button pushed function: TankleveldesignstepsButton
        function TankleveldesignstepsButtonPushed(app, event)
            tanklevel_story
        end

        % Button pushed function: SystembehavioursButton
        function SystembehavioursButtonPushed(app, event)
            behaviours
        end

        % Button pushed function: InvertedpendulumcontrolButton
        function InvertedpendulumcontrolButtonPushed(app, event)
            invertedpendulum
        end

        % Button pushed function: DCmotorcontrolButton
        function DCmotorcontrolButtonPushed(app, event)
            dcservo_and_position_control
        end

        % Button pushed function: OpenloopvsclosedloopButton
        function OpenloopvsclosedloopButtonPushed(app, event)
            open_vs_closed_control101
        end

        % Button pushed function: HousetemperaturecontrolButton
        function HousetemperaturecontrolButtonPushed(app, event)
            housetemperature_story
        end

        % Button pushed function: PItuningButton
        function PItuningButtonPushed(app, event)
            pi_tuning
        end

        % Button pushed function: PIDtuningButton
        function PIDtuningButtonPushed(app, event)
            pidtuningrules
        end

        % Button pushed function: NonlineartankcontrolButton
        function NonlineartankcontrolButtonPushed(app, event)
            nonlinear_tank_control_control101
        end

        % Button pushed function: StatespacemodelsButton
        function StatespacemodelsButtonPushed(app, event)
            statespace_models_control101
        end

        % Button pushed function: StatespacefromTFButton
        function StatespacefromTFButtonPushed(app, event)
            statespace_models_from_tf_control101
        end

        % Button pushed function: TFfromstatespaceButton
        function TFfromstatespaceButtonPushed(app, event)
            tf_models_from_statespace_control101
        end

        % Button pushed function: DiscreteSSmodelsButton
        function DiscreteSSmodelsButtonPushed(app, event)
            discrete_time_state_space_models_control101
        end

        % Button pushed function: BehaviourofSSmodelsButton
        function BehaviourofSSmodelsButtonPushed(app, event)
            openloop_behaviour_statespace_control101
        end

        % Button pushed function: PhaseplanebehaviourButton
        function PhaseplanebehaviourButtonPushed(app, event)
            phaseplane_behaviour_statespace_control101
        end

        % Button pushed function: EquivalentSSmodelsButton
        function EquivalentSSmodelsButtonPushed(app, event)
            equivalent_state_space_formulations_control101
        end

        % Button pushed function: ControllabilityObservabilityButton
        function ControllabilityObservabilityButtonPushed(app, event)
            controllability_and_observability_control101
        end

        % Button pushed function: StabilityanalysisButton
        function StabilityanalysisButtonPushed(app, event)
            stability_analysis_control101
        end

        % Button pushed function: EigenvaluesButton
        function EigenvaluesButtonPushed(app, event)
            stability_eigenvalues_control101
        end

        % Button pushed function: StatefeedbackButton
        function StatefeedbackButtonPushed(app, event)
            state_feedback_control101
        end

        % Button pushed function: OptimalstatefeedbackButton
        function OptimalstatefeedbackButtonPushed(app, event)
            optimal_state_feedback_control101
        end

        % Button pushed function: ObserverdesignButton
        function ObserverdesignButtonPushed(app, event)
            observer_design_control101
        end

        % Button pushed function: TrackingdesignButton
        function TrackingdesignButtonPushed(app, event)
            tracking_with_statespace_control101
        end

        % Button pushed function: FeedbackwithestimationButton
        function FeedbackwithestimationButtonPushed(app, event)
            state_feedback_and_estimation_cont_case_study
        end

        % Button pushed function: DiscreteimplementationsButton
        function DiscreteimplementationsButtonPushed(app, event)
            state_feedback_and_state_estimation_discrete_case_study
        end

        % Button pushed function: ImplementationonSIMULINK1Button
        function ImplementationonSIMULINK1ButtonPushed(app, event)
            state_space_and_simulinkfile1_control101
        end

        % Button pushed function: ImplementationonSIMULINK2Button
        function ImplementationonSIMULINK2ButtonPushed(app, event)
            state_space_and_simulinkfile2_control101
        end

        % Button pushed function: ImplementationonSIMULINK3Button
        function ImplementationonSIMULINK3ButtonPushed(app, event)
            state_space_and_simulinkfile3_control101
        end

        % Button pushed function: FrequencyresponsebasicsButton
        function FrequencyresponsebasicsButtonPushed(app, event)
            freq_responses_with_matlab
        end

        % Button pushed function: BodeasymptotesButton
        function BodeasymptotesButtonPushed(app, event)
            bode_asymptotes
        end

        % Button pushed function: ProportionaldesignBodeButton
        function ProportionaldesignBodeButtonPushed(app, event)
            proportional_design_with_bode
        end

        % Button pushed function: LagdesignwithBodeButton
        function LagdesignwithBodeButtonPushed(app, event)
            lag_design_with_bode
        end

        % Button pushed function: LeaddesignwithBodeButton
        function LeaddesignwithBodeButtonPushed(app, event)
            lead_design_with_bode
        end

        % Button pushed function: LeadlagdesignwithBodeButton
        function LeadlagdesignwithBodeButtonPushed(app, event)
            lead_lag_design_with_bode
        end

        % Button pushed function: ImpactofdelaysButton
        function ImpactofdelaysButtonPushed(app, event)
            delays_and_bode
        end

        % Button pushed function: StabilityanalysisButton_2
        function StabilityanalysisButton_2Pushed(app, event)
            Stability_Continuous
        end

        % Button pushed function: WhatisfrequencyresponseButton
        function WhatisfrequencyresponseButtonPushed(app, event)
            frequency_response_time_behaviour
        end

        % Button pushed function: ProportionaldesignButton
        function ProportionaldesignButtonPushed(app, event)
            proportional_design_phase_margin
        end

        % Button pushed function: LagdesignButton
        function LagdesignButtonPushed(app, event)
            lag_design_phase_margin
        end

        % Button pushed function: LeaddesignButton
        function LeaddesignButtonPushed(app, event)
            lead_design_phase_margin
        end

        % Button pushed function: DesignfromcriteriatheoryButton
        function DesignfromcriteriatheoryButtonPushed(app, event)
            lead_lag_design_with_criteria
        end

        % Button pushed function: DesignfromcriteriaButton
        function DesignfromcriteriaButtonPushed(app, event)
            lead_lag_design_criteria
        end

        % Button pushed function: AeroplanerollexampleButton
        function AeroplanerollexampleButtonPushed(app, event)
            aeroplane_roll_control
        end

        % Button pushed function: LeadlagdesignButton
        function LeadlagdesignButtonPushed(app, event)
            lead_lag_design_phase_margin
        end

        % Button pushed function: IntroductiontosimulinkmodelsButton
        function IntroductiontosimulinkmodelsButtonPushed(app, event)
            intro_to_simulink_for_system_behaviour
        end

        % Button pushed function: CarsuspensionButton
        function CarsuspensionButtonPushed(app, event)
            car_suspension_simulink_control101
        end

        % Button pushed function: HeatingsystemButton
        function HeatingsystemButtonPushed(app, event)
            heating_system_simulink_control101
        end

        % Button pushed function: SimpleexamplesButton
        function SimpleexamplesButtonPushed(app, event)
            uncertainty_simulations_control101_tool
        end

        % Button pushed function: HydraulicsystemButton
        function HydraulicsystemButtonPushed(app, event)
            hydraulic_system_simulink_control101
        end

        % Button pushed function: PositioncontrolButton
        function PositioncontrolButtonPushed(app, event)
            position_system_simulink_control101
        end

        % Button pushed function: SubmersibleButton
        function SubmersibleButtonPushed(app, event)
            submersible_system_simulink_control101
        end

        % Button pushed function: MyfirstsimulinkmodelButton
        function MyfirstsimulinkmodelButtonPushed(app, event)
            myfirstsimulink_control101
        end

        % Button pushed function: NonlineartankbehaviourButton
        function NonlineartankbehaviourButtonPushed(app, event)
            nonlinear_tank_behaviour_control101
        end

        % Button pushed function: LinearisationButton
        function LinearisationButtonPushed(app, event)
            linearisation_Benchmark_control101
        end

        % Button pushed function: NonlinearpositioncontrolButton
        function NonlinearpositioncontrolButtonPushed(app, event)
            nonlinear_position_control
        end

        % Button pushed function: NonlineartankcontrolButton_2
        function NonlineartankcontrolButton_2Pushed(app, event)
            nonlinear_tank_control_control101
        end

        % Button pushed function: TimeseriesmodelsButton
        function TimeseriesmodelsButtonPushed(app, event)
            time_series_models
        end

        % Button pushed function: TimeseriesandrecursionButton
        function TimeseriesandrecursionButtonPushed(app, event)
            time_series_models_and_recursion
        end

        % Button pushed function: DiscretemodelsButton
        function DiscretemodelsButtonPushed(app, event)
            discrete_models_and_usage
        end

        % Button pushed function: DiscretisationandBodeButton
        function DiscretisationandBodeButtonPushed(app, event)
            discretisation_and_bode
        end

        % Button pushed function: StabilityofdiscreteButton
        function StabilityofdiscreteButtonPushed(app, event)
            Stability_Discrete
        end

        % Button pushed function: AnaloguetodigitalconvertorButton
        function AnaloguetodigitalconvertorButtonPushed(app, event)
            Analog_to_Digital_Converter_Application_control101
        end

        % Button pushed function: DigitaltoanalogueconvertorButton
        function DigitaltoanalogueconvertorButtonPushed(app, event)
            Digital_to_Analog_Converter_Application_control101
        end

        % Button pushed function: ContinuousanddiscretemappingButton
        function ContinuousanddiscretemappingButtonPushed(app, event)
            Continuous_and_Discrete_time_Mapping_control101
        end

        % Button pushed function: ClosedloopundersamplingButton
        function ClosedloopundersamplingButtonPushed(app, event)
            Closed_Loop_Under_Sampling_control101
        end

        % Button pushed function: SignaltypeswithsamplingButton
        function SignaltypeswithsamplingButtonPushed(app, event)
            Signal_Types_in_Comp_Control_application_control101
        end

        % Button pushed function: SignalreconstructionButton
        function SignalreconstructionButtonPushed(app, event)
            Reconstruction_and_Signal_Holders_control101
        end

        % Button pushed function: SampleddatasystemsButton
        function SampleddatasystemsButtonPushed(app, event)
            Sampled_Data_Systems_control101
        end

        % Button pushed function: SamplingoperationButton
        function SamplingoperationButtonPushed(app, event)
            Sampling_Operation_control101
        end

        % Button pushed function: SignaltypesincomputercontrolButton
        function SignaltypesincomputercontrolButtonPushed(app, event)
            Signal_Types_in_Computer_Controlled_Systems_control101
        end

        % Button pushed function: PIDviapolecancellationButton
        function PIDviapolecancellationButtonPushed(app, event)
            PID_Cont_Controller_Design_with_Pole_Cancellation
        end

        % Button pushed function: YouladesignButton
        function YouladesignButtonPushed(app, event)
            Youla_continuous_controller_design
        end

        % Button pushed function: DiscreteYouladesignButton
        function DiscreteYouladesignButtonPushed(app, event)
            Youla_discrete_controller_design
        end

        % Button pushed function: DiscretemethodsButton
        function DiscretemethodsButtonPushed(app, event)
            discrete_controller_design_methods
        end

        % Button pushed function: SmithpredictorButton
        function SmithpredictorButtonPushed(app, event)
            Smith_predictor_controller_design
        end

        % Button pushed function: AntiresetwindupButton
        function AntiresetwindupButtonPushed(app, event)
            antireset_windup_control101
        end

        % Button pushed function: ControlstructuresButton
        function ControlstructuresButtonPushed(app, event)
            control_structures_control101
        end

        % Button pushed function: DiscretePIDButton
        function DiscretePIDButtonPushed(app, event)
            discrete_models_and_discrete_PID_controller_design
        end

        % Button pushed function: DeadbeatcontrolButton
        function DeadbeatcontrolButtonPushed(app, event)
            Dead_beat_controller_design_control101
        end

        % Button pushed function: SourcefilesButton
        function SourcefilesButtonPushed(app, event)
            mpcsourcecode_control101_tool
        end

        % Button pushed function: ConceptsofpredictionButton
        function ConceptsofpredictionButtonPushed(app, event)
           predictionconcepts_control101
        end

        % Button pushed function: MPCtuningButton
        function MPCtuningButtonPushed(app, event)
            mpctuning_control101   
        end

        % Button pushed function: MPCfailingButton
        function MPCfailingButtonPushed(app, event)
            mpcfailing_control101  
        end

        % Button pushed function: MPCwithaTfilterButton
        function MPCwithaTfilterButtonPushed(app, event)
            mpctfilter_control101   
        end

        % Button pushed function: MPCandconstrainthandlingButton
        function MPCandconstrainthandlingButtonPushed(app, event)
            mpcconstraints_lab_control101  
        end

        % Button pushed function: MPCandfeedforwardButton
        function MPCandfeedforwardButtonPushed(app, event)
            mpcfeedforward_control101
        end

        % Button pushed function: TwotankscontrolButton
        function TwotankscontrolButtonPushed(app, event)
            TwoTanks
        end

        % Button pushed function: TwotankssystemButton
        function TwotankssystemButtonPushed(app, event)
            twotanks_control101_run
        end

        % Button pushed function: RacecaronatrackwithPIButton
        function RacecaronatrackwithPIButtonPushed(app, event)
            racingcar_control101
        end
    end

    % Component initialization
    methods (Access = private)

        % Create UIFigure and components
        function createComponents(app)

            % Get the file path for locating images
            pathToMLAPP = fileparts(mfilename('fullpath'));

            % Create UIFigure and hide until all components are created
            app.UIFigure = uifigure('Visible', 'off');
            app.UIFigure.Position = [100 100 1061 740];
            app.UIFigure.Name = 'MATLAB App';

            % Create GridLayout
            app.GridLayout = uigridlayout(app.UIFigure);
            app.GridLayout.RowHeight = {'1x', '0.4x', '5x'};

            % Create GridLayout2
            app.GridLayout2 = uigridlayout(app.GridLayout);
            app.GridLayout2.RowHeight = {'1x'};
            app.GridLayout2.Layout.Row = 1;
            app.GridLayout2.Layout.Column = 1;
            app.GridLayout2.BackgroundColor = [0.6588 0.9608 0.6588];

            % Create Thisisalauncherforthefilesincontrol101Label
            app.Thisisalauncherforthefilesincontrol101Label = uilabel(app.GridLayout2);
            app.Thisisalauncherforthefilesincontrol101Label.WordWrap = 'on';
            app.Thisisalauncherforthefilesincontrol101Label.FontSize = 18;
            app.Thisisalauncherforthefilesincontrol101Label.FontWeight = 'bold';
            app.Thisisalauncherforthefilesincontrol101Label.Layout.Row = 1;
            app.Thisisalauncherforthefilesincontrol101Label.Layout.Column = 1;
            app.Thisisalauncherforthefilesincontrol101Label.Text = 'This is a launcher for the files in control101.';

            % Create SelectTABthemeandpressbuttontoselectfileLabel
            app.SelectTABthemeandpressbuttontoselectfileLabel = uilabel(app.GridLayout2);
            app.SelectTABthemeandpressbuttontoselectfileLabel.WordWrap = 'on';
            app.SelectTABthemeandpressbuttontoselectfileLabel.FontSize = 18;
            app.SelectTABthemeandpressbuttontoselectfileLabel.FontWeight = 'bold';
            app.SelectTABthemeandpressbuttontoselectfileLabel.Layout.Row = 1;
            app.SelectTABthemeandpressbuttontoselectfileLabel.Layout.Column = 2;
            app.SelectTABthemeandpressbuttontoselectfileLabel.Text = 'Select TAB/theme and press button to select file.';

            % Create GridLayout3
            app.GridLayout3 = uigridlayout(app.GridLayout);
            app.GridLayout3.ColumnWidth = {'2x', '1x'};
            app.GridLayout3.RowHeight = {'1x'};
            app.GridLayout3.Layout.Row = 1;
            app.GridLayout3.Layout.Column = 2;
            app.GridLayout3.BackgroundColor = [0.6 0.9608 0.9608];

            % Create CONTROL101toolboxLabel
            app.CONTROL101toolboxLabel = uilabel(app.GridLayout3);
            app.CONTROL101toolboxLabel.BackgroundColor = [0 1 1];
            app.CONTROL101toolboxLabel.HorizontalAlignment = 'center';
            app.CONTROL101toolboxLabel.FontSize = 24;
            app.CONTROL101toolboxLabel.FontWeight = 'bold';
            app.CONTROL101toolboxLabel.Layout.Row = 1;
            app.CONTROL101toolboxLabel.Layout.Column = 1;
            app.CONTROL101toolboxLabel.Text = 'CONTROL101 toolbox';

            % Create Image
            app.Image = uiimage(app.GridLayout3);
            app.Image.Layout.Row = 1;
            app.Image.Layout.Column = 2;
            app.Image.ImageSource = fullfile(pathToMLAPP, 'UoSlogo.png');

            % Create Hyperlink
            app.Hyperlink = uihyperlink(app.GridLayout);
            app.Hyperlink.WordWrap = 'on';
            app.Hyperlink.FontSize = 14;
            app.Hyperlink.Layout.Row = 2;
            app.Hyperlink.Layout.Column = 1;
            app.Hyperlink.URL = 'https://sites.google.com/sheffield.ac.uk/controleducation/matlabresources/section-6-11-community-control-toolbox';
            app.Hyperlink.Text = ' For more detailed summaries  view the webpage and documentation.';

            % Create Label
            app.Label = uilabel(app.GridLayout);
            app.Label.FontSize = 18;
            app.Label.Layout.Row = 2;
            app.Label.Layout.Column = 2;
            app.Label.Text = 'This interface provides only the links to run the files.';

            % Create TabGroup
            app.TabGroup = uitabgroup(app.GridLayout);
            app.TabGroup.Layout.Row = 3;
            app.TabGroup.Layout.Column = [1 2];

            % Create ControlfundamentalsTab
            app.ControlfundamentalsTab = uitab(app.TabGroup);
            app.ControlfundamentalsTab.Title = 'Control fundamentals';

            % Create GridLayout7
            app.GridLayout7 = uigridlayout(app.ControlfundamentalsTab);
            app.GridLayout7.ColumnWidth = {'1x', '1x', '1x', '1x', '1x'};
            app.GridLayout7.RowHeight = {'0.4x', '1x', '1x', '1x', '1x'};
            app.GridLayout7.BackgroundColor = [0.9804 0.5882 0.8549];

            % Create PlottingwithmatlabButton
            app.PlottingwithmatlabButton = uibutton(app.GridLayout7, 'push');
            app.PlottingwithmatlabButton.ButtonPushedFcn = createCallbackFcn(app, @PlottingwithmatlabButtonPushed, true);
            app.PlottingwithmatlabButton.WordWrap = 'on';
            app.PlottingwithmatlabButton.BackgroundColor = [1 0 1];
            app.PlottingwithmatlabButton.FontSize = 24;
            app.PlottingwithmatlabButton.Layout.Row = 2;
            app.PlottingwithmatlabButton.Layout.Column = 1;
            app.PlottingwithmatlabButton.Text = 'Plotting with matlab';

            % Create ControlfundamentalspleaseuseintheorderpresentedLabel
            app.ControlfundamentalspleaseuseintheorderpresentedLabel = uilabel(app.GridLayout7);
            app.ControlfundamentalspleaseuseintheorderpresentedLabel.BackgroundColor = [0.902 0.902 0.902];
            app.ControlfundamentalspleaseuseintheorderpresentedLabel.HorizontalAlignment = 'center';
            app.ControlfundamentalspleaseuseintheorderpresentedLabel.FontSize = 24;
            app.ControlfundamentalspleaseuseintheorderpresentedLabel.Layout.Row = 1;
            app.ControlfundamentalspleaseuseintheorderpresentedLabel.Layout.Column = [1 5];
            app.ControlfundamentalspleaseuseintheorderpresentedLabel.Text = 'Control fundamentals (please use in the order presented)';

            % Create ODEswithMATLABButton
            app.ODEswithMATLABButton = uibutton(app.GridLayout7, 'push');
            app.ODEswithMATLABButton.ButtonPushedFcn = createCallbackFcn(app, @ODEswithMATLABButtonPushed, true);
            app.ODEswithMATLABButton.WordWrap = 'on';
            app.ODEswithMATLABButton.BackgroundColor = [1 0 1];
            app.ODEswithMATLABButton.FontSize = 24;
            app.ODEswithMATLABButton.Layout.Row = 2;
            app.ODEswithMATLABButton.Layout.Column = 2;
            app.ODEswithMATLABButton.Text = 'ODEs with MATLAB';

            % Create FirstordermodelsinmatlabButton
            app.FirstordermodelsinmatlabButton = uibutton(app.GridLayout7, 'push');
            app.FirstordermodelsinmatlabButton.ButtonPushedFcn = createCallbackFcn(app, @FirstordermodelsinmatlabButtonPushed, true);
            app.FirstordermodelsinmatlabButton.WordWrap = 'on';
            app.FirstordermodelsinmatlabButton.BackgroundColor = [1 0 1];
            app.FirstordermodelsinmatlabButton.FontSize = 24;
            app.FirstordermodelsinmatlabButton.Layout.Row = 2;
            app.FirstordermodelsinmatlabButton.Layout.Column = 3;
            app.FirstordermodelsinmatlabButton.Text = {'First order models in '; 'matlab'};

            % Create FirstorderresponsesButton
            app.FirstorderresponsesButton = uibutton(app.GridLayout7, 'push');
            app.FirstorderresponsesButton.ButtonPushedFcn = createCallbackFcn(app, @FirstorderresponsesButtonPushed, true);
            app.FirstorderresponsesButton.WordWrap = 'on';
            app.FirstorderresponsesButton.BackgroundColor = [1 0 1];
            app.FirstorderresponsesButton.FontSize = 24;
            app.FirstorderresponsesButton.Layout.Row = 2;
            app.FirstorderresponsesButton.Layout.Column = 4;
            app.FirstorderresponsesButton.Text = 'First order responses';

            % Create SecondordermodelsButton
            app.SecondordermodelsButton = uibutton(app.GridLayout7, 'push');
            app.SecondordermodelsButton.ButtonPushedFcn = createCallbackFcn(app, @SecondordermodelsButtonPushed, true);
            app.SecondordermodelsButton.WordWrap = 'on';
            app.SecondordermodelsButton.BackgroundColor = [1 0 1];
            app.SecondordermodelsButton.FontSize = 24;
            app.SecondordermodelsButton.Layout.Row = 2;
            app.SecondordermodelsButton.Layout.Column = 5;
            app.SecondordermodelsButton.Text = 'Second order models';

            % Create SecondorderresponsesButton
            app.SecondorderresponsesButton = uibutton(app.GridLayout7, 'push');
            app.SecondorderresponsesButton.ButtonPushedFcn = createCallbackFcn(app, @SecondorderresponsesButtonPushed, true);
            app.SecondorderresponsesButton.WordWrap = 'on';
            app.SecondorderresponsesButton.BackgroundColor = [1 0 1];
            app.SecondorderresponsesButton.FontSize = 24;
            app.SecondorderresponsesButton.Layout.Row = 3;
            app.SecondorderresponsesButton.Layout.Column = 1;
            app.SecondorderresponsesButton.Text = 'Second order responses';

            % Create LaplaceTransformsButton
            app.LaplaceTransformsButton = uibutton(app.GridLayout7, 'push');
            app.LaplaceTransformsButton.ButtonPushedFcn = createCallbackFcn(app, @LaplaceTransformsButtonPushed, true);
            app.LaplaceTransformsButton.WordWrap = 'on';
            app.LaplaceTransformsButton.BackgroundColor = [1 0 1];
            app.LaplaceTransformsButton.FontSize = 24;
            app.LaplaceTransformsButton.Layout.Row = 3;
            app.LaplaceTransformsButton.Layout.Column = 2;
            app.LaplaceTransformsButton.Text = 'Laplace Transforms';

            % Create PartialfractionsButton
            app.PartialfractionsButton = uibutton(app.GridLayout7, 'push');
            app.PartialfractionsButton.ButtonPushedFcn = createCallbackFcn(app, @PartialfractionsButtonPushed, true);
            app.PartialfractionsButton.WordWrap = 'on';
            app.PartialfractionsButton.BackgroundColor = [1 0 1];
            app.PartialfractionsButton.FontSize = 24;
            app.PartialfractionsButton.Layout.Row = 3;
            app.PartialfractionsButton.Layout.Column = 3;
            app.PartialfractionsButton.Text = 'Partial fractions';

            % Create StepresponsesButton
            app.StepresponsesButton = uibutton(app.GridLayout7, 'push');
            app.StepresponsesButton.ButtonPushedFcn = createCallbackFcn(app, @StepresponsesButtonPushed, true);
            app.StepresponsesButton.WordWrap = 'on';
            app.StepresponsesButton.BackgroundColor = [1 0 1];
            app.StepresponsesButton.FontSize = 24;
            app.StepresponsesButton.Layout.Row = 3;
            app.StepresponsesButton.Layout.Column = 4;
            app.StepresponsesButton.Text = 'Step responses';

            % Create TransferfunctionsandbehaviourButton
            app.TransferfunctionsandbehaviourButton = uibutton(app.GridLayout7, 'push');
            app.TransferfunctionsandbehaviourButton.ButtonPushedFcn = createCallbackFcn(app, @TransferfunctionsandbehaviourButtonPushed, true);
            app.TransferfunctionsandbehaviourButton.WordWrap = 'on';
            app.TransferfunctionsandbehaviourButton.BackgroundColor = [1 0 1];
            app.TransferfunctionsandbehaviourButton.FontSize = 24;
            app.TransferfunctionsandbehaviourButton.Layout.Row = 3;
            app.TransferfunctionsandbehaviourButton.Layout.Column = 5;
            app.TransferfunctionsandbehaviourButton.Text = 'Transfer functions and behaviour';

            % Create TransferfunctionsandpolesButton
            app.TransferfunctionsandpolesButton = uibutton(app.GridLayout7, 'push');
            app.TransferfunctionsandpolesButton.ButtonPushedFcn = createCallbackFcn(app, @TransferfunctionsandpolesButtonPushed, true);
            app.TransferfunctionsandpolesButton.WordWrap = 'on';
            app.TransferfunctionsandpolesButton.BackgroundColor = [1 0 1];
            app.TransferfunctionsandpolesButton.FontSize = 24;
            app.TransferfunctionsandpolesButton.Layout.Row = 4;
            app.TransferfunctionsandpolesButton.Layout.Column = 1;
            app.TransferfunctionsandpolesButton.Text = 'Transfer functions and poles';

            % Create EffectsoffeedbackButton
            app.EffectsoffeedbackButton = uibutton(app.GridLayout7, 'push');
            app.EffectsoffeedbackButton.ButtonPushedFcn = createCallbackFcn(app, @EffectsoffeedbackButtonPushed, true);
            app.EffectsoffeedbackButton.WordWrap = 'on';
            app.EffectsoffeedbackButton.BackgroundColor = [1 0 1];
            app.EffectsoffeedbackButton.FontSize = 24;
            app.EffectsoffeedbackButton.Layout.Row = 4;
            app.EffectsoffeedbackButton.Layout.Column = 2;
            app.EffectsoffeedbackButton.Text = 'Effects of feedback';

            % Create ClosedlooptransferfunctionsButton
            app.ClosedlooptransferfunctionsButton = uibutton(app.GridLayout7, 'push');
            app.ClosedlooptransferfunctionsButton.ButtonPushedFcn = createCallbackFcn(app, @ClosedlooptransferfunctionsButtonPushed, true);
            app.ClosedlooptransferfunctionsButton.WordWrap = 'on';
            app.ClosedlooptransferfunctionsButton.BackgroundColor = [1 0 1];
            app.ClosedlooptransferfunctionsButton.FontSize = 24;
            app.ClosedlooptransferfunctionsButton.Layout.Row = 4;
            app.ClosedlooptransferfunctionsButton.Layout.Column = 3;
            app.ClosedlooptransferfunctionsButton.Text = 'Closed-loop transfer functions';

            % Create ClosedloopoffsetandpolesButton
            app.ClosedloopoffsetandpolesButton = uibutton(app.GridLayout7, 'push');
            app.ClosedloopoffsetandpolesButton.ButtonPushedFcn = createCallbackFcn(app, @ClosedloopoffsetandpolesButtonPushed, true);
            app.ClosedloopoffsetandpolesButton.WordWrap = 'on';
            app.ClosedloopoffsetandpolesButton.BackgroundColor = [1 0 1];
            app.ClosedloopoffsetandpolesButton.FontSize = 24;
            app.ClosedloopoffsetandpolesButton.Layout.Row = 4;
            app.ClosedloopoffsetandpolesButton.Layout.Column = 4;
            app.ClosedloopoffsetandpolesButton.Text = 'Closed-loop offset and poles';

            % Create ComparemultiplecompensatorsButton
            app.ComparemultiplecompensatorsButton = uibutton(app.GridLayout7, 'push');
            app.ComparemultiplecompensatorsButton.ButtonPushedFcn = createCallbackFcn(app, @ComparemultiplecompensatorsButtonPushed, true);
            app.ComparemultiplecompensatorsButton.WordWrap = 'on';
            app.ComparemultiplecompensatorsButton.BackgroundColor = [1 0 1];
            app.ComparemultiplecompensatorsButton.FontSize = 24;
            app.ComparemultiplecompensatorsButton.Layout.Row = 4;
            app.ComparemultiplecompensatorsButton.Layout.Column = 5;
            app.ComparemultiplecompensatorsButton.Text = 'Compare multiple compensators';

            % Create OverlayplotsfrommultiplescenariosButton
            app.OverlayplotsfrommultiplescenariosButton = uibutton(app.GridLayout7, 'push');
            app.OverlayplotsfrommultiplescenariosButton.ButtonPushedFcn = createCallbackFcn(app, @OverlayplotsfrommultiplescenariosButtonPushed, true);
            app.OverlayplotsfrommultiplescenariosButton.WordWrap = 'on';
            app.OverlayplotsfrommultiplescenariosButton.BackgroundColor = [1 0 1];
            app.OverlayplotsfrommultiplescenariosButton.FontSize = 24;
            app.OverlayplotsfrommultiplescenariosButton.Layout.Row = 5;
            app.OverlayplotsfrommultiplescenariosButton.Layout.Column = 1;
            app.OverlayplotsfrommultiplescenariosButton.Text = 'Overlay plots from multiple scenarios';

            % Create IntroductiontoPIDtuningButton
            app.IntroductiontoPIDtuningButton = uibutton(app.GridLayout7, 'push');
            app.IntroductiontoPIDtuningButton.ButtonPushedFcn = createCallbackFcn(app, @IntroductiontoPIDtuningButtonPushed, true);
            app.IntroductiontoPIDtuningButton.WordWrap = 'on';
            app.IntroductiontoPIDtuningButton.BackgroundColor = [1 0 1];
            app.IntroductiontoPIDtuningButton.FontSize = 24;
            app.IntroductiontoPIDtuningButton.Layout.Row = 5;
            app.IntroductiontoPIDtuningButton.Layout.Column = 2;
            app.IntroductiontoPIDtuningButton.Text = 'Introduction to PID tuning';

            % Create ThesefilescombineMATLABexamplesandabel
            app.ThesefilescombineMATLABexamplesandabel = uilabel(app.GridLayout7);
            app.ThesefilescombineMATLABexamplesandabel.BackgroundColor = [0.6706 0.6392 0.0275];
            app.ThesefilescombineMATLABexamplesandabel.HorizontalAlignment = 'center';
            app.ThesefilescombineMATLABexamplesandabel.WordWrap = 'on';
            app.ThesefilescombineMATLABexamplesandabel.FontSize = 24;
            app.ThesefilescombineMATLABexamplesandabel.Layout.Row = 5;
            app.ThesefilescombineMATLABexamplesandabel.Layout.Column = [4 5];
            app.ThesefilescombineMATLABexamplesandabel.Text = 'These files combine MATLAB examples and exemplar code with explanations.';

            % Create SimulationwithuncertaintyButton
            app.SimulationwithuncertaintyButton = uibutton(app.GridLayout7, 'push');
            app.SimulationwithuncertaintyButton.ButtonPushedFcn = createCallbackFcn(app, @SimulationwithuncertaintyButtonPushed, true);
            app.SimulationwithuncertaintyButton.WordWrap = 'on';
            app.SimulationwithuncertaintyButton.BackgroundColor = [1 0 1];
            app.SimulationwithuncertaintyButton.FontSize = 24;
            app.SimulationwithuncertaintyButton.Layout.Row = 5;
            app.SimulationwithuncertaintyButton.Layout.Column = 3;
            app.SimulationwithuncertaintyButton.Text = 'Simulation with uncertainty';

            % Create VirtuallaboratoriesTab
            app.VirtuallaboratoriesTab = uitab(app.TabGroup);
            app.VirtuallaboratoriesTab.Title = 'Virtual laboratories';

            % Create GridLayout8
            app.GridLayout8 = uigridlayout(app.VirtuallaboratoriesTab);
            app.GridLayout8.ColumnWidth = {'1x', '1x', '1x', '1x', '1x', '1x'};
            app.GridLayout8.RowHeight = {'0.4x', '1x', '1x', '1x', '1x', '1x'};
            app.GridLayout8.BackgroundColor = [0.902 1 0.502];

            % Create VirtualLaboratoriesbehavioursandcontrolLabel
            app.VirtualLaboratoriesbehavioursandcontrolLabel = uilabel(app.GridLayout8);
            app.VirtualLaboratoriesbehavioursandcontrolLabel.BackgroundColor = [0.902 0.902 0.902];
            app.VirtualLaboratoriesbehavioursandcontrolLabel.HorizontalAlignment = 'center';
            app.VirtualLaboratoriesbehavioursandcontrolLabel.FontSize = 24;
            app.VirtualLaboratoriesbehavioursandcontrolLabel.Layout.Row = 1;
            app.VirtualLaboratoriesbehavioursandcontrolLabel.Layout.Column = [1 6];
            app.VirtualLaboratoriesbehavioursandcontrolLabel.Text = 'Virtual Laboratories (behaviours and control)';

            % Create CarvelocityButton
            app.CarvelocityButton = uibutton(app.GridLayout8, 'push');
            app.CarvelocityButton.ButtonPushedFcn = createCallbackFcn(app, @CarvelocityButtonPushed, true);
            app.CarvelocityButton.WordWrap = 'on';
            app.CarvelocityButton.BackgroundColor = [1 1 0];
            app.CarvelocityButton.FontSize = 24;
            app.CarvelocityButton.Layout.Row = 2;
            app.CarvelocityButton.Layout.Column = 1;
            app.CarvelocityButton.Text = 'Car velocity';

            % Create TankLevelButton
            app.TankLevelButton = uibutton(app.GridLayout8, 'push');
            app.TankLevelButton.ButtonPushedFcn = createCallbackFcn(app, @TankLevelButtonPushed, true);
            app.TankLevelButton.WordWrap = 'on';
            app.TankLevelButton.BackgroundColor = [1 1 0];
            app.TankLevelButton.FontSize = 24;
            app.TankLevelButton.Layout.Row = 2;
            app.TankLevelButton.Layout.Column = 2;
            app.TankLevelButton.Text = 'Tank Level';

            % Create HeatexchangerButton
            app.HeatexchangerButton = uibutton(app.GridLayout8, 'push');
            app.HeatexchangerButton.ButtonPushedFcn = createCallbackFcn(app, @HeatexchangerButtonPushed, true);
            app.HeatexchangerButton.WordWrap = 'on';
            app.HeatexchangerButton.BackgroundColor = [1 1 0];
            app.HeatexchangerButton.FontSize = 24;
            app.HeatexchangerButton.Layout.Row = 2;
            app.HeatexchangerButton.Layout.Column = 3;
            app.HeatexchangerButton.Text = 'Heat exchanger';

            % Create MixingtankButton
            app.MixingtankButton = uibutton(app.GridLayout8, 'push');
            app.MixingtankButton.ButtonPushedFcn = createCallbackFcn(app, @MixingtankButtonPushed, true);
            app.MixingtankButton.WordWrap = 'on';
            app.MixingtankButton.BackgroundColor = [1 1 0];
            app.MixingtankButton.FontSize = 24;
            app.MixingtankButton.Layout.Row = 2;
            app.MixingtankButton.Layout.Column = 4;
            app.MixingtankButton.Text = 'Mixing tank';

            % Create HousetemperatureButton
            app.HousetemperatureButton = uibutton(app.GridLayout8, 'push');
            app.HousetemperatureButton.ButtonPushedFcn = createCallbackFcn(app, @HousetemperatureButtonPushed, true);
            app.HousetemperatureButton.WordWrap = 'on';
            app.HousetemperatureButton.BackgroundColor = [1 1 0];
            app.HousetemperatureButton.FontSize = 24;
            app.HousetemperatureButton.Layout.Row = 2;
            app.HousetemperatureButton.Layout.Column = 5;
            app.HousetemperatureButton.Text = 'House temperature';

            % Create AeroplanelandingButton
            app.AeroplanelandingButton = uibutton(app.GridLayout8, 'push');
            app.AeroplanelandingButton.ButtonPushedFcn = createCallbackFcn(app, @AeroplanelandingButtonPushed, true);
            app.AeroplanelandingButton.WordWrap = 'on';
            app.AeroplanelandingButton.BackgroundColor = [1 1 0];
            app.AeroplanelandingButton.FontSize = 24;
            app.AeroplanelandingButton.Layout.Row = 3;
            app.AeroplanelandingButton.Layout.Column = 1;
            app.AeroplanelandingButton.Text = 'Aeroplane landing';

            % Create DiabetesButton
            app.DiabetesButton = uibutton(app.GridLayout8, 'push');
            app.DiabetesButton.ButtonPushedFcn = createCallbackFcn(app, @DiabetesButtonPushed, true);
            app.DiabetesButton.WordWrap = 'on';
            app.DiabetesButton.BackgroundColor = [1 1 0];
            app.DiabetesButton.FontSize = 24;
            app.DiabetesButton.Layout.Row = 3;
            app.DiabetesButton.Layout.Column = 2;
            app.DiabetesButton.Text = 'Diabetes';

            % Create PredatorpreysystemsButton
            app.PredatorpreysystemsButton = uibutton(app.GridLayout8, 'push');
            app.PredatorpreysystemsButton.ButtonPushedFcn = createCallbackFcn(app, @PredatorpreysystemsButtonPushed, true);
            app.PredatorpreysystemsButton.WordWrap = 'on';
            app.PredatorpreysystemsButton.BackgroundColor = [1 1 0];
            app.PredatorpreysystemsButton.FontSize = 24;
            app.PredatorpreysystemsButton.Layout.Row = 3;
            app.PredatorpreysystemsButton.Layout.Column = 3;
            app.PredatorpreysystemsButton.Text = 'Predator-prey systems';

            % Create NonlineartanksButton
            app.NonlineartanksButton = uibutton(app.GridLayout8, 'push');
            app.NonlineartanksButton.ButtonPushedFcn = createCallbackFcn(app, @NonlineartanksButtonPushed, true);
            app.NonlineartanksButton.WordWrap = 'on';
            app.NonlineartanksButton.BackgroundColor = [1 1 0];
            app.NonlineartanksButton.FontSize = 24;
            app.NonlineartanksButton.Layout.Row = 3;
            app.NonlineartanksButton.Layout.Column = 4;
            app.NonlineartanksButton.Text = 'Non-linear tanks';

            % Create ConicaltanksButton
            app.ConicaltanksButton = uibutton(app.GridLayout8, 'push');
            app.ConicaltanksButton.ButtonPushedFcn = createCallbackFcn(app, @ConicaltanksButtonPushed, true);
            app.ConicaltanksButton.WordWrap = 'on';
            app.ConicaltanksButton.BackgroundColor = [1 1 0];
            app.ConicaltanksButton.FontSize = 24;
            app.ConicaltanksButton.Layout.Row = 3;
            app.ConicaltanksButton.Layout.Column = 5;
            app.ConicaltanksButton.Text = 'Conical tanks';

            % Create ManualcontroloftanklevelButton
            app.ManualcontroloftanklevelButton = uibutton(app.GridLayout8, 'push');
            app.ManualcontroloftanklevelButton.ButtonPushedFcn = createCallbackFcn(app, @ManualcontroloftanklevelButtonPushed, true);
            app.ManualcontroloftanklevelButton.WordWrap = 'on';
            app.ManualcontroloftanklevelButton.BackgroundColor = [1 1 0];
            app.ManualcontroloftanklevelButton.FontSize = 18;
            app.ManualcontroloftanklevelButton.Layout.Row = 4;
            app.ManualcontroloftanklevelButton.Layout.Column = 3;
            app.ManualcontroloftanklevelButton.Text = 'Manual control of tank level';

            % Create stordermodellingButton
            app.stordermodellingButton = uibutton(app.GridLayout8, 'push');
            app.stordermodellingButton.ButtonPushedFcn = createCallbackFcn(app, @stordermodellingButtonPushed, true);
            app.stordermodellingButton.WordWrap = 'on';
            app.stordermodellingButton.BackgroundColor = [1 1 0];
            app.stordermodellingButton.FontSize = 24;
            app.stordermodellingButton.Layout.Row = 4;
            app.stordermodellingButton.Layout.Column = 2;
            app.stordermodellingButton.Text = '1st order modelling ';

            % Create storderbehavioursButton
            app.storderbehavioursButton = uibutton(app.GridLayout8, 'push');
            app.storderbehavioursButton.ButtonPushedFcn = createCallbackFcn(app, @storderbehavioursButtonPushed, true);
            app.storderbehavioursButton.WordWrap = 'on';
            app.storderbehavioursButton.BackgroundColor = [1 1 0];
            app.storderbehavioursButton.FontSize = 24;
            app.storderbehavioursButton.Layout.Row = 4;
            app.storderbehavioursButton.Layout.Column = 1;
            app.storderbehavioursButton.Text = '1st order behaviours';

            % Create CruisecontrolwithPIButton
            app.CruisecontrolwithPIButton = uibutton(app.GridLayout8, 'push');
            app.CruisecontrolwithPIButton.ButtonPushedFcn = createCallbackFcn(app, @CruisecontrolwithPIButtonPushed, true);
            app.CruisecontrolwithPIButton.WordWrap = 'on';
            app.CruisecontrolwithPIButton.BackgroundColor = [1 1 0];
            app.CruisecontrolwithPIButton.FontSize = 18;
            app.CruisecontrolwithPIButton.Layout.Row = 4;
            app.CruisecontrolwithPIButton.Layout.Column = 4;
            app.CruisecontrolwithPIButton.Text = 'Cruise control with PI';

            % Create TanklevelcontrolButton
            app.TanklevelcontrolButton = uibutton(app.GridLayout8, 'push');
            app.TanklevelcontrolButton.ButtonPushedFcn = createCallbackFcn(app, @TanklevelcontrolButtonPushed, true);
            app.TanklevelcontrolButton.WordWrap = 'on';
            app.TanklevelcontrolButton.BackgroundColor = [1 1 0];
            app.TanklevelcontrolButton.FontSize = 24;
            app.TanklevelcontrolButton.Layout.Row = 4;
            app.TanklevelcontrolButton.Layout.Column = 5;
            app.TanklevelcontrolButton.Text = 'Tank level control';

            % Create HousetemperaturecontrolButton
            app.HousetemperaturecontrolButton = uibutton(app.GridLayout8, 'push');
            app.HousetemperaturecontrolButton.ButtonPushedFcn = createCallbackFcn(app, @HousetemperaturecontrolButtonPushed, true);
            app.HousetemperaturecontrolButton.WordWrap = 'on';
            app.HousetemperaturecontrolButton.BackgroundColor = [1 1 0];
            app.HousetemperaturecontrolButton.FontSize = 18;
            app.HousetemperaturecontrolButton.Layout.Row = 5;
            app.HousetemperaturecontrolButton.Layout.Column = 5;
            app.HousetemperaturecontrolButton.Text = 'House temperature control';

            % Create InvertedpendulumcontrolButton
            app.InvertedpendulumcontrolButton = uibutton(app.GridLayout8, 'push');
            app.InvertedpendulumcontrolButton.ButtonPushedFcn = createCallbackFcn(app, @InvertedpendulumcontrolButtonPushed, true);
            app.InvertedpendulumcontrolButton.WordWrap = 'on';
            app.InvertedpendulumcontrolButton.BackgroundColor = [1 1 0];
            app.InvertedpendulumcontrolButton.FontSize = 18;
            app.InvertedpendulumcontrolButton.Layout.Row = 5;
            app.InvertedpendulumcontrolButton.Layout.Column = 2;
            app.InvertedpendulumcontrolButton.Text = 'Inverted pendulum control';

            % Create DCmotorcontrolButton
            app.DCmotorcontrolButton = uibutton(app.GridLayout8, 'push');
            app.DCmotorcontrolButton.ButtonPushedFcn = createCallbackFcn(app, @DCmotorcontrolButtonPushed, true);
            app.DCmotorcontrolButton.WordWrap = 'on';
            app.DCmotorcontrolButton.BackgroundColor = [1 1 0];
            app.DCmotorcontrolButton.FontSize = 24;
            app.DCmotorcontrolButton.Layout.Row = 5;
            app.DCmotorcontrolButton.Layout.Column = 3;
            app.DCmotorcontrolButton.Text = 'DC motor control';

            % Create OpenloopvsclosedloopButton
            app.OpenloopvsclosedloopButton = uibutton(app.GridLayout8, 'push');
            app.OpenloopvsclosedloopButton.ButtonPushedFcn = createCallbackFcn(app, @OpenloopvsclosedloopButtonPushed, true);
            app.OpenloopvsclosedloopButton.WordWrap = 'on';
            app.OpenloopvsclosedloopButton.BackgroundColor = [1 1 0];
            app.OpenloopvsclosedloopButton.FontSize = 24;
            app.OpenloopvsclosedloopButton.Layout.Row = 5;
            app.OpenloopvsclosedloopButton.Layout.Column = 4;
            app.OpenloopvsclosedloopButton.Text = 'Open-loop vs closed-loop';

            % Create ConicaltankcontrolButton
            app.ConicaltankcontrolButton = uibutton(app.GridLayout8, 'push');
            app.ConicaltankcontrolButton.ButtonPushedFcn = createCallbackFcn(app, @ConicaltankcontrolButtonPushed, true);
            app.ConicaltankcontrolButton.WordWrap = 'on';
            app.ConicaltankcontrolButton.BackgroundColor = [1 1 0];
            app.ConicaltankcontrolButton.FontSize = 24;
            app.ConicaltankcontrolButton.Layout.Row = 3;
            app.ConicaltankcontrolButton.Layout.Column = 6;
            app.ConicaltankcontrolButton.Text = 'Conical tank control';

            % Create PItuningButton
            app.PItuningButton = uibutton(app.GridLayout8, 'push');
            app.PItuningButton.ButtonPushedFcn = createCallbackFcn(app, @PItuningButtonPushed, true);
            app.PItuningButton.WordWrap = 'on';
            app.PItuningButton.BackgroundColor = [1 1 0];
            app.PItuningButton.FontSize = 24;
            app.PItuningButton.Layout.Row = 6;
            app.PItuningButton.Layout.Column = 1;
            app.PItuningButton.Text = 'PI tuning';

            % Create PIDtuningButton
            app.PIDtuningButton = uibutton(app.GridLayout8, 'push');
            app.PIDtuningButton.ButtonPushedFcn = createCallbackFcn(app, @PIDtuningButtonPushed, true);
            app.PIDtuningButton.WordWrap = 'on';
            app.PIDtuningButton.BackgroundColor = [1 1 0];
            app.PIDtuningButton.FontSize = 24;
            app.PIDtuningButton.Layout.Row = 6;
            app.PIDtuningButton.Layout.Column = 2;
            app.PIDtuningButton.Text = 'PID tuning';

            % Create NonlineartankcontrolButton
            app.NonlineartankcontrolButton = uibutton(app.GridLayout8, 'push');
            app.NonlineartankcontrolButton.ButtonPushedFcn = createCallbackFcn(app, @NonlineartankcontrolButtonPushed, true);
            app.NonlineartankcontrolButton.WordWrap = 'on';
            app.NonlineartankcontrolButton.BackgroundColor = [1 1 0];
            app.NonlineartankcontrolButton.FontSize = 24;
            app.NonlineartankcontrolButton.Layout.Row = 6;
            app.NonlineartankcontrolButton.Layout.Column = 4;
            app.NonlineartankcontrolButton.Text = 'Non-linear tank control';

            % Create TankleveldesignstepsButton
            app.TankleveldesignstepsButton = uibutton(app.GridLayout8, 'push');
            app.TankleveldesignstepsButton.ButtonPushedFcn = createCallbackFcn(app, @TankleveldesignstepsButtonPushed, true);
            app.TankleveldesignstepsButton.WordWrap = 'on';
            app.TankleveldesignstepsButton.BackgroundColor = [1 1 0];
            app.TankleveldesignstepsButton.FontSize = 24;
            app.TankleveldesignstepsButton.Layout.Row = 4;
            app.TankleveldesignstepsButton.Layout.Column = 6;
            app.TankleveldesignstepsButton.Text = 'Tank level design steps';

            % Create SystembehavioursButton
            app.SystembehavioursButton = uibutton(app.GridLayout8, 'push');
            app.SystembehavioursButton.ButtonPushedFcn = createCallbackFcn(app, @SystembehavioursButtonPushed, true);
            app.SystembehavioursButton.WordWrap = 'on';
            app.SystembehavioursButton.BackgroundColor = [1 1 0];
            app.SystembehavioursButton.FontSize = 24;
            app.SystembehavioursButton.Layout.Row = 5;
            app.SystembehavioursButton.Layout.Column = 1;
            app.SystembehavioursButton.Text = 'System behaviours';

            % Create RCcircuitbehaviourButton
            app.RCcircuitbehaviourButton = uibutton(app.GridLayout8, 'push');
            app.RCcircuitbehaviourButton.ButtonPushedFcn = createCallbackFcn(app, @RCcircuitbehaviourButtonPushed, true);
            app.RCcircuitbehaviourButton.WordWrap = 'on';
            app.RCcircuitbehaviourButton.BackgroundColor = [1 1 0];
            app.RCcircuitbehaviourButton.FontSize = 24;
            app.RCcircuitbehaviourButton.Layout.Row = 2;
            app.RCcircuitbehaviourButton.Layout.Column = 6;
            app.RCcircuitbehaviourButton.Text = 'RC circuit behaviour';

            % Create TwotankscontrolButton
            app.TwotankscontrolButton = uibutton(app.GridLayout8, 'push');
            app.TwotankscontrolButton.ButtonPushedFcn = createCallbackFcn(app, @TwotankscontrolButtonPushed, true);
            app.TwotankscontrolButton.WordWrap = 'on';
            app.TwotankscontrolButton.BackgroundColor = [1 1 0];
            app.TwotankscontrolButton.FontSize = 24;
            app.TwotankscontrolButton.Layout.Row = 6;
            app.TwotankscontrolButton.Layout.Column = 5;
            app.TwotankscontrolButton.Text = 'Two tanks control';

            % Create RacecaronatrackwithPIButton
            app.RacecaronatrackwithPIButton = uibutton(app.GridLayout8, 'push');
            app.RacecaronatrackwithPIButton.ButtonPushedFcn = createCallbackFcn(app, @RacecaronatrackwithPIButtonPushed, true);
            app.RacecaronatrackwithPIButton.WordWrap = 'on';
            app.RacecaronatrackwithPIButton.BackgroundColor = [1 1 0];
            app.RacecaronatrackwithPIButton.FontSize = 24;
            app.RacecaronatrackwithPIButton.Layout.Row = 6;
            app.RacecaronatrackwithPIButton.Layout.Column = 3;
            app.RacecaronatrackwithPIButton.Text = 'Race car on a track with PI';

            % Create StatespacemethodsTab
            app.StatespacemethodsTab = uitab(app.TabGroup);
            app.StatespacemethodsTab.AutoResizeChildren = 'off';
            app.StatespacemethodsTab.Title = 'State space methods';

            % Create GridLayout9
            app.GridLayout9 = uigridlayout(app.StatespacemethodsTab);
            app.GridLayout9.ColumnWidth = {'1x', '1x', '1x', '1x', '1x'};
            app.GridLayout9.RowHeight = {'0.4x', '1x', '1x', '1x', '1x', '1x'};
            app.GridLayout9.BackgroundColor = [1 0.8 0.6];

            % Create StatespacemethodslivescriptfilesLabel
            app.StatespacemethodslivescriptfilesLabel = uilabel(app.GridLayout9);
            app.StatespacemethodslivescriptfilesLabel.BackgroundColor = [0.902 0.902 0.902];
            app.StatespacemethodslivescriptfilesLabel.HorizontalAlignment = 'center';
            app.StatespacemethodslivescriptfilesLabel.FontSize = 24;
            app.StatespacemethodslivescriptfilesLabel.Layout.Row = 1;
            app.StatespacemethodslivescriptfilesLabel.Layout.Column = [1 5];
            app.StatespacemethodslivescriptfilesLabel.Text = 'State space methods (livescript files)';

            % Create StatespacemodelsButton
            app.StatespacemodelsButton = uibutton(app.GridLayout9, 'push');
            app.StatespacemodelsButton.ButtonPushedFcn = createCallbackFcn(app, @StatespacemodelsButtonPushed, true);
            app.StatespacemodelsButton.WordWrap = 'on';
            app.StatespacemodelsButton.BackgroundColor = [0.9608 0.4667 0.1608];
            app.StatespacemodelsButton.FontSize = 24;
            app.StatespacemodelsButton.Layout.Row = 2;
            app.StatespacemodelsButton.Layout.Column = 1;
            app.StatespacemodelsButton.Text = 'State space models';

            % Create StatespacefromTFButton
            app.StatespacefromTFButton = uibutton(app.GridLayout9, 'push');
            app.StatespacefromTFButton.ButtonPushedFcn = createCallbackFcn(app, @StatespacefromTFButtonPushed, true);
            app.StatespacefromTFButton.WordWrap = 'on';
            app.StatespacefromTFButton.BackgroundColor = [0.9608 0.4667 0.1608];
            app.StatespacefromTFButton.FontSize = 24;
            app.StatespacefromTFButton.Layout.Row = 2;
            app.StatespacefromTFButton.Layout.Column = 2;
            app.StatespacefromTFButton.Text = 'State space from TF';

            % Create TFfromstatespaceButton
            app.TFfromstatespaceButton = uibutton(app.GridLayout9, 'push');
            app.TFfromstatespaceButton.ButtonPushedFcn = createCallbackFcn(app, @TFfromstatespaceButtonPushed, true);
            app.TFfromstatespaceButton.WordWrap = 'on';
            app.TFfromstatespaceButton.BackgroundColor = [0.9608 0.4667 0.1608];
            app.TFfromstatespaceButton.FontSize = 24;
            app.TFfromstatespaceButton.Layout.Row = 2;
            app.TFfromstatespaceButton.Layout.Column = 3;
            app.TFfromstatespaceButton.Text = 'TF from state space';

            % Create DiscreteSSmodelsButton
            app.DiscreteSSmodelsButton = uibutton(app.GridLayout9, 'push');
            app.DiscreteSSmodelsButton.ButtonPushedFcn = createCallbackFcn(app, @DiscreteSSmodelsButtonPushed, true);
            app.DiscreteSSmodelsButton.WordWrap = 'on';
            app.DiscreteSSmodelsButton.BackgroundColor = [0.9608 0.4667 0.1608];
            app.DiscreteSSmodelsButton.FontSize = 24;
            app.DiscreteSSmodelsButton.Layout.Row = 2;
            app.DiscreteSSmodelsButton.Layout.Column = 4;
            app.DiscreteSSmodelsButton.Text = 'Discrete SS models';

            % Create BehaviourofSSmodelsButton
            app.BehaviourofSSmodelsButton = uibutton(app.GridLayout9, 'push');
            app.BehaviourofSSmodelsButton.ButtonPushedFcn = createCallbackFcn(app, @BehaviourofSSmodelsButtonPushed, true);
            app.BehaviourofSSmodelsButton.WordWrap = 'on';
            app.BehaviourofSSmodelsButton.BackgroundColor = [0.9608 0.4667 0.1608];
            app.BehaviourofSSmodelsButton.FontSize = 24;
            app.BehaviourofSSmodelsButton.Layout.Row = 2;
            app.BehaviourofSSmodelsButton.Layout.Column = 5;
            app.BehaviourofSSmodelsButton.Text = 'Behaviour of SS models';

            % Create PhaseplanebehaviourButton
            app.PhaseplanebehaviourButton = uibutton(app.GridLayout9, 'push');
            app.PhaseplanebehaviourButton.ButtonPushedFcn = createCallbackFcn(app, @PhaseplanebehaviourButtonPushed, true);
            app.PhaseplanebehaviourButton.WordWrap = 'on';
            app.PhaseplanebehaviourButton.BackgroundColor = [0.9608 0.4667 0.1608];
            app.PhaseplanebehaviourButton.FontSize = 24;
            app.PhaseplanebehaviourButton.Layout.Row = 3;
            app.PhaseplanebehaviourButton.Layout.Column = 1;
            app.PhaseplanebehaviourButton.Text = 'Phase plane behaviour';

            % Create EquivalentSSmodelsButton
            app.EquivalentSSmodelsButton = uibutton(app.GridLayout9, 'push');
            app.EquivalentSSmodelsButton.ButtonPushedFcn = createCallbackFcn(app, @EquivalentSSmodelsButtonPushed, true);
            app.EquivalentSSmodelsButton.WordWrap = 'on';
            app.EquivalentSSmodelsButton.BackgroundColor = [0.9608 0.4667 0.1608];
            app.EquivalentSSmodelsButton.FontSize = 24;
            app.EquivalentSSmodelsButton.Layout.Row = 3;
            app.EquivalentSSmodelsButton.Layout.Column = 2;
            app.EquivalentSSmodelsButton.Text = 'Equivalent SS models';

            % Create ControllabilityObservabilityButton
            app.ControllabilityObservabilityButton = uibutton(app.GridLayout9, 'push');
            app.ControllabilityObservabilityButton.ButtonPushedFcn = createCallbackFcn(app, @ControllabilityObservabilityButtonPushed, true);
            app.ControllabilityObservabilityButton.WordWrap = 'on';
            app.ControllabilityObservabilityButton.BackgroundColor = [0.9608 0.4667 0.1608];
            app.ControllabilityObservabilityButton.FontSize = 24;
            app.ControllabilityObservabilityButton.Layout.Row = 3;
            app.ControllabilityObservabilityButton.Layout.Column = 3;
            app.ControllabilityObservabilityButton.Text = 'Controllability & Observability';

            % Create StabilityanalysisButton
            app.StabilityanalysisButton = uibutton(app.GridLayout9, 'push');
            app.StabilityanalysisButton.ButtonPushedFcn = createCallbackFcn(app, @StabilityanalysisButtonPushed, true);
            app.StabilityanalysisButton.WordWrap = 'on';
            app.StabilityanalysisButton.BackgroundColor = [0.9608 0.4667 0.1608];
            app.StabilityanalysisButton.FontSize = 24;
            app.StabilityanalysisButton.Layout.Row = 3;
            app.StabilityanalysisButton.Layout.Column = 4;
            app.StabilityanalysisButton.Text = 'Stability analysis';

            % Create EigenvaluesButton
            app.EigenvaluesButton = uibutton(app.GridLayout9, 'push');
            app.EigenvaluesButton.ButtonPushedFcn = createCallbackFcn(app, @EigenvaluesButtonPushed, true);
            app.EigenvaluesButton.WordWrap = 'on';
            app.EigenvaluesButton.BackgroundColor = [0.9608 0.4667 0.1608];
            app.EigenvaluesButton.FontSize = 24;
            app.EigenvaluesButton.Layout.Row = 3;
            app.EigenvaluesButton.Layout.Column = 5;
            app.EigenvaluesButton.Text = 'Eigenvalues';

            % Create StatefeedbackButton
            app.StatefeedbackButton = uibutton(app.GridLayout9, 'push');
            app.StatefeedbackButton.ButtonPushedFcn = createCallbackFcn(app, @StatefeedbackButtonPushed, true);
            app.StatefeedbackButton.WordWrap = 'on';
            app.StatefeedbackButton.BackgroundColor = [0.9608 0.4667 0.1608];
            app.StatefeedbackButton.FontSize = 24;
            app.StatefeedbackButton.Layout.Row = 4;
            app.StatefeedbackButton.Layout.Column = 1;
            app.StatefeedbackButton.Text = 'State feedback';

            % Create OptimalstatefeedbackButton
            app.OptimalstatefeedbackButton = uibutton(app.GridLayout9, 'push');
            app.OptimalstatefeedbackButton.ButtonPushedFcn = createCallbackFcn(app, @OptimalstatefeedbackButtonPushed, true);
            app.OptimalstatefeedbackButton.WordWrap = 'on';
            app.OptimalstatefeedbackButton.BackgroundColor = [0.9608 0.4667 0.1608];
            app.OptimalstatefeedbackButton.FontSize = 24;
            app.OptimalstatefeedbackButton.Layout.Row = 4;
            app.OptimalstatefeedbackButton.Layout.Column = 2;
            app.OptimalstatefeedbackButton.Text = 'Optimal state feedback';

            % Create ObserverdesignButton
            app.ObserverdesignButton = uibutton(app.GridLayout9, 'push');
            app.ObserverdesignButton.ButtonPushedFcn = createCallbackFcn(app, @ObserverdesignButtonPushed, true);
            app.ObserverdesignButton.WordWrap = 'on';
            app.ObserverdesignButton.BackgroundColor = [0.9608 0.4667 0.1608];
            app.ObserverdesignButton.FontSize = 24;
            app.ObserverdesignButton.Layout.Row = 4;
            app.ObserverdesignButton.Layout.Column = 3;
            app.ObserverdesignButton.Text = 'Observer design';

            % Create TrackingdesignButton
            app.TrackingdesignButton = uibutton(app.GridLayout9, 'push');
            app.TrackingdesignButton.ButtonPushedFcn = createCallbackFcn(app, @TrackingdesignButtonPushed, true);
            app.TrackingdesignButton.WordWrap = 'on';
            app.TrackingdesignButton.BackgroundColor = [0.9608 0.4667 0.1608];
            app.TrackingdesignButton.FontSize = 24;
            app.TrackingdesignButton.Layout.Row = 4;
            app.TrackingdesignButton.Layout.Column = 4;
            app.TrackingdesignButton.Text = 'Tracking design';

            % Create FeedbackwithestimationButton
            app.FeedbackwithestimationButton = uibutton(app.GridLayout9, 'push');
            app.FeedbackwithestimationButton.ButtonPushedFcn = createCallbackFcn(app, @FeedbackwithestimationButtonPushed, true);
            app.FeedbackwithestimationButton.WordWrap = 'on';
            app.FeedbackwithestimationButton.BackgroundColor = [0.9608 0.4667 0.1608];
            app.FeedbackwithestimationButton.FontSize = 24;
            app.FeedbackwithestimationButton.Layout.Row = 4;
            app.FeedbackwithestimationButton.Layout.Column = 5;
            app.FeedbackwithestimationButton.Text = {'Feedback with '; 'estimation'};

            % Create DiscreteimplementationsButton
            app.DiscreteimplementationsButton = uibutton(app.GridLayout9, 'push');
            app.DiscreteimplementationsButton.ButtonPushedFcn = createCallbackFcn(app, @DiscreteimplementationsButtonPushed, true);
            app.DiscreteimplementationsButton.WordWrap = 'on';
            app.DiscreteimplementationsButton.BackgroundColor = [0.9608 0.4667 0.1608];
            app.DiscreteimplementationsButton.FontSize = 24;
            app.DiscreteimplementationsButton.Layout.Row = 5;
            app.DiscreteimplementationsButton.Layout.Column = 1;
            app.DiscreteimplementationsButton.Text = 'Discrete implementations';

            % Create ImplementationonSIMULINK1Button
            app.ImplementationonSIMULINK1Button = uibutton(app.GridLayout9, 'push');
            app.ImplementationonSIMULINK1Button.ButtonPushedFcn = createCallbackFcn(app, @ImplementationonSIMULINK1ButtonPushed, true);
            app.ImplementationonSIMULINK1Button.WordWrap = 'on';
            app.ImplementationonSIMULINK1Button.BackgroundColor = [0.9608 0.4667 0.1608];
            app.ImplementationonSIMULINK1Button.FontSize = 24;
            app.ImplementationonSIMULINK1Button.Layout.Row = 5;
            app.ImplementationonSIMULINK1Button.Layout.Column = 2;
            app.ImplementationonSIMULINK1Button.Text = 'Implementation on SIMULINK 1';

            % Create ImplementationonSIMULINK2Button
            app.ImplementationonSIMULINK2Button = uibutton(app.GridLayout9, 'push');
            app.ImplementationonSIMULINK2Button.ButtonPushedFcn = createCallbackFcn(app, @ImplementationonSIMULINK2ButtonPushed, true);
            app.ImplementationonSIMULINK2Button.WordWrap = 'on';
            app.ImplementationonSIMULINK2Button.BackgroundColor = [0.9608 0.4667 0.1608];
            app.ImplementationonSIMULINK2Button.FontSize = 24;
            app.ImplementationonSIMULINK2Button.Layout.Row = 5;
            app.ImplementationonSIMULINK2Button.Layout.Column = 3;
            app.ImplementationonSIMULINK2Button.Text = 'Implementation on SIMULINK 2';

            % Create ImplementationonSIMULINK3Button
            app.ImplementationonSIMULINK3Button = uibutton(app.GridLayout9, 'push');
            app.ImplementationonSIMULINK3Button.ButtonPushedFcn = createCallbackFcn(app, @ImplementationonSIMULINK3ButtonPushed, true);
            app.ImplementationonSIMULINK3Button.WordWrap = 'on';
            app.ImplementationonSIMULINK3Button.BackgroundColor = [0.9608 0.4667 0.1608];
            app.ImplementationonSIMULINK3Button.FontSize = 24;
            app.ImplementationonSIMULINK3Button.Layout.Row = 5;
            app.ImplementationonSIMULINK3Button.Layout.Column = 4;
            app.ImplementationonSIMULINK3Button.Text = 'Implementation on SIMULINK 3';

            % Create ThesefilescombineMATLABexampLabel
            app.ThesefilescombineMATLABexampLabel = uilabel(app.GridLayout9);
            app.ThesefilescombineMATLABexampLabel.BackgroundColor = [0.6706 0.6392 0.0275];
            app.ThesefilescombineMATLABexampLabel.HorizontalAlignment = 'center';
            app.ThesefilescombineMATLABexampLabel.WordWrap = 'on';
            app.ThesefilescombineMATLABexampLabel.FontSize = 24;
            app.ThesefilescombineMATLABexampLabel.Layout.Row = 6;
            app.ThesefilescombineMATLABexampLabel.Layout.Column = [1 5];
            app.ThesefilescombineMATLABexampLabel.Text = 'These files combine MATLAB examples and exemplar code with explanations of the state space theory. ';

            % Create FrequencyresponseTab
            app.FrequencyresponseTab = uitab(app.TabGroup);
            app.FrequencyresponseTab.AutoResizeChildren = 'off';
            app.FrequencyresponseTab.Title = 'Frequency response';

            % Create GridLayout12
            app.GridLayout12 = uigridlayout(app.FrequencyresponseTab);
            app.GridLayout12.ColumnWidth = {'1x', '1x', '1x', '1x', '1x'};
            app.GridLayout12.RowHeight = {'0.4x', '1x', '1x', '0.4x', '1x', '1x'};

            % Create FrequencyresponselivescriptfilesLabel
            app.FrequencyresponselivescriptfilesLabel = uilabel(app.GridLayout12);
            app.FrequencyresponselivescriptfilesLabel.BackgroundColor = [0.902 0.902 0.902];
            app.FrequencyresponselivescriptfilesLabel.HorizontalAlignment = 'center';
            app.FrequencyresponselivescriptfilesLabel.FontSize = 24;
            app.FrequencyresponselivescriptfilesLabel.Layout.Row = 1;
            app.FrequencyresponselivescriptfilesLabel.Layout.Column = [1 5];
            app.FrequencyresponselivescriptfilesLabel.Text = 'Frequency response (livescript files)';

            % Create FrequencyresponsevirtuallaboratoriesLabel
            app.FrequencyresponsevirtuallaboratoriesLabel = uilabel(app.GridLayout12);
            app.FrequencyresponsevirtuallaboratoriesLabel.BackgroundColor = [0.902 0.902 0.902];
            app.FrequencyresponsevirtuallaboratoriesLabel.HorizontalAlignment = 'center';
            app.FrequencyresponsevirtuallaboratoriesLabel.FontSize = 24;
            app.FrequencyresponsevirtuallaboratoriesLabel.Layout.Row = 4;
            app.FrequencyresponsevirtuallaboratoriesLabel.Layout.Column = [1 4];
            app.FrequencyresponsevirtuallaboratoriesLabel.Text = 'Frequency response (virtual laboratories)';

            % Create FrequencyresponsebasicsButton
            app.FrequencyresponsebasicsButton = uibutton(app.GridLayout12, 'push');
            app.FrequencyresponsebasicsButton.ButtonPushedFcn = createCallbackFcn(app, @FrequencyresponsebasicsButtonPushed, true);
            app.FrequencyresponsebasicsButton.WordWrap = 'on';
            app.FrequencyresponsebasicsButton.BackgroundColor = [0.8 0.8 0.8];
            app.FrequencyresponsebasicsButton.FontSize = 24;
            app.FrequencyresponsebasicsButton.Layout.Row = 2;
            app.FrequencyresponsebasicsButton.Layout.Column = 1;
            app.FrequencyresponsebasicsButton.Text = 'Frequency response basics';

            % Create BodeasymptotesButton
            app.BodeasymptotesButton = uibutton(app.GridLayout12, 'push');
            app.BodeasymptotesButton.ButtonPushedFcn = createCallbackFcn(app, @BodeasymptotesButtonPushed, true);
            app.BodeasymptotesButton.WordWrap = 'on';
            app.BodeasymptotesButton.BackgroundColor = [0.8 0.8 0.8];
            app.BodeasymptotesButton.FontSize = 24;
            app.BodeasymptotesButton.Layout.Row = 2;
            app.BodeasymptotesButton.Layout.Column = 2;
            app.BodeasymptotesButton.Text = 'Bode asymptotes';

            % Create ProportionaldesignBodeButton
            app.ProportionaldesignBodeButton = uibutton(app.GridLayout12, 'push');
            app.ProportionaldesignBodeButton.ButtonPushedFcn = createCallbackFcn(app, @ProportionaldesignBodeButtonPushed, true);
            app.ProportionaldesignBodeButton.WordWrap = 'on';
            app.ProportionaldesignBodeButton.BackgroundColor = [0.8 0.8 0.8];
            app.ProportionaldesignBodeButton.FontSize = 24;
            app.ProportionaldesignBodeButton.Layout.Row = 2;
            app.ProportionaldesignBodeButton.Layout.Column = 3;
            app.ProportionaldesignBodeButton.Text = 'Proportional design & Bode';

            % Create LagdesignwithBodeButton
            app.LagdesignwithBodeButton = uibutton(app.GridLayout12, 'push');
            app.LagdesignwithBodeButton.ButtonPushedFcn = createCallbackFcn(app, @LagdesignwithBodeButtonPushed, true);
            app.LagdesignwithBodeButton.WordWrap = 'on';
            app.LagdesignwithBodeButton.BackgroundColor = [0.8 0.8 0.8];
            app.LagdesignwithBodeButton.FontSize = 24;
            app.LagdesignwithBodeButton.Layout.Row = 2;
            app.LagdesignwithBodeButton.Layout.Column = 4;
            app.LagdesignwithBodeButton.Text = 'Lag design with Bode';

            % Create LeaddesignwithBodeButton
            app.LeaddesignwithBodeButton = uibutton(app.GridLayout12, 'push');
            app.LeaddesignwithBodeButton.ButtonPushedFcn = createCallbackFcn(app, @LeaddesignwithBodeButtonPushed, true);
            app.LeaddesignwithBodeButton.WordWrap = 'on';
            app.LeaddesignwithBodeButton.BackgroundColor = [0.8 0.8 0.8];
            app.LeaddesignwithBodeButton.FontSize = 24;
            app.LeaddesignwithBodeButton.Layout.Row = 3;
            app.LeaddesignwithBodeButton.Layout.Column = 1;
            app.LeaddesignwithBodeButton.Text = 'Lead design with Bode';

            % Create LeadlagdesignwithBodeButton
            app.LeadlagdesignwithBodeButton = uibutton(app.GridLayout12, 'push');
            app.LeadlagdesignwithBodeButton.ButtonPushedFcn = createCallbackFcn(app, @LeadlagdesignwithBodeButtonPushed, true);
            app.LeadlagdesignwithBodeButton.WordWrap = 'on';
            app.LeadlagdesignwithBodeButton.BackgroundColor = [0.8 0.8 0.8];
            app.LeadlagdesignwithBodeButton.FontSize = 24;
            app.LeadlagdesignwithBodeButton.Layout.Row = 3;
            app.LeadlagdesignwithBodeButton.Layout.Column = 2;
            app.LeadlagdesignwithBodeButton.Text = 'Lead-lag design with Bode';

            % Create ImpactofdelaysButton
            app.ImpactofdelaysButton = uibutton(app.GridLayout12, 'push');
            app.ImpactofdelaysButton.ButtonPushedFcn = createCallbackFcn(app, @ImpactofdelaysButtonPushed, true);
            app.ImpactofdelaysButton.WordWrap = 'on';
            app.ImpactofdelaysButton.BackgroundColor = [0.8 0.8 0.8];
            app.ImpactofdelaysButton.FontSize = 24;
            app.ImpactofdelaysButton.Layout.Row = 3;
            app.ImpactofdelaysButton.Layout.Column = 3;
            app.ImpactofdelaysButton.Text = 'Impact of delays';

            % Create StabilityanalysisButton_2
            app.StabilityanalysisButton_2 = uibutton(app.GridLayout12, 'push');
            app.StabilityanalysisButton_2.ButtonPushedFcn = createCallbackFcn(app, @StabilityanalysisButton_2Pushed, true);
            app.StabilityanalysisButton_2.WordWrap = 'on';
            app.StabilityanalysisButton_2.BackgroundColor = [0.8 0.8 0.8];
            app.StabilityanalysisButton_2.FontSize = 24;
            app.StabilityanalysisButton_2.Layout.Row = 3;
            app.StabilityanalysisButton_2.Layout.Column = 4;
            app.StabilityanalysisButton_2.Text = 'Stability analysis';

            % Create WhatisfrequencyresponseButton
            app.WhatisfrequencyresponseButton = uibutton(app.GridLayout12, 'push');
            app.WhatisfrequencyresponseButton.ButtonPushedFcn = createCallbackFcn(app, @WhatisfrequencyresponseButtonPushed, true);
            app.WhatisfrequencyresponseButton.WordWrap = 'on';
            app.WhatisfrequencyresponseButton.BackgroundColor = [0.8 0.8 0.8];
            app.WhatisfrequencyresponseButton.FontSize = 20;
            app.WhatisfrequencyresponseButton.Layout.Row = 5;
            app.WhatisfrequencyresponseButton.Layout.Column = 1;
            app.WhatisfrequencyresponseButton.Text = 'What is frequency response?';

            % Create ProportionaldesignButton
            app.ProportionaldesignButton = uibutton(app.GridLayout12, 'push');
            app.ProportionaldesignButton.ButtonPushedFcn = createCallbackFcn(app, @ProportionaldesignButtonPushed, true);
            app.ProportionaldesignButton.WordWrap = 'on';
            app.ProportionaldesignButton.BackgroundColor = [0.8 0.8 0.8];
            app.ProportionaldesignButton.FontSize = 24;
            app.ProportionaldesignButton.Layout.Row = 5;
            app.ProportionaldesignButton.Layout.Column = 2;
            app.ProportionaldesignButton.Text = 'Proportional design';

            % Create LagdesignButton
            app.LagdesignButton = uibutton(app.GridLayout12, 'push');
            app.LagdesignButton.ButtonPushedFcn = createCallbackFcn(app, @LagdesignButtonPushed, true);
            app.LagdesignButton.WordWrap = 'on';
            app.LagdesignButton.BackgroundColor = [0.8 0.8 0.8];
            app.LagdesignButton.FontSize = 24;
            app.LagdesignButton.Layout.Row = 5;
            app.LagdesignButton.Layout.Column = 3;
            app.LagdesignButton.Text = 'Lag design';

            % Create LeaddesignButton
            app.LeaddesignButton = uibutton(app.GridLayout12, 'push');
            app.LeaddesignButton.ButtonPushedFcn = createCallbackFcn(app, @LeaddesignButtonPushed, true);
            app.LeaddesignButton.WordWrap = 'on';
            app.LeaddesignButton.BackgroundColor = [0.8 0.8 0.8];
            app.LeaddesignButton.FontSize = 24;
            app.LeaddesignButton.Layout.Row = 5;
            app.LeaddesignButton.Layout.Column = 4;
            app.LeaddesignButton.Text = 'Lead design';

            % Create LeadlagdesignButton
            app.LeadlagdesignButton = uibutton(app.GridLayout12, 'push');
            app.LeadlagdesignButton.ButtonPushedFcn = createCallbackFcn(app, @LeadlagdesignButtonPushed, true);
            app.LeadlagdesignButton.WordWrap = 'on';
            app.LeadlagdesignButton.BackgroundColor = [0.8 0.8 0.8];
            app.LeadlagdesignButton.FontSize = 24;
            app.LeadlagdesignButton.Layout.Row = 6;
            app.LeadlagdesignButton.Layout.Column = 4;
            app.LeadlagdesignButton.Text = 'Lead-lag design';

            % Create DesignfromcriteriatheoryButton
            app.DesignfromcriteriatheoryButton = uibutton(app.GridLayout12, 'push');
            app.DesignfromcriteriatheoryButton.ButtonPushedFcn = createCallbackFcn(app, @DesignfromcriteriatheoryButtonPushed, true);
            app.DesignfromcriteriatheoryButton.WordWrap = 'on';
            app.DesignfromcriteriatheoryButton.BackgroundColor = [0.8 0.8 0.8];
            app.DesignfromcriteriatheoryButton.FontSize = 24;
            app.DesignfromcriteriatheoryButton.Layout.Row = 6;
            app.DesignfromcriteriatheoryButton.Layout.Column = 1;
            app.DesignfromcriteriatheoryButton.Text = 'Design from criteria (theory)';

            % Create AeroplanerollexampleButton
            app.AeroplanerollexampleButton = uibutton(app.GridLayout12, 'push');
            app.AeroplanerollexampleButton.ButtonPushedFcn = createCallbackFcn(app, @AeroplanerollexampleButtonPushed, true);
            app.AeroplanerollexampleButton.WordWrap = 'on';
            app.AeroplanerollexampleButton.BackgroundColor = [0.8 0.8 0.8];
            app.AeroplanerollexampleButton.FontSize = 24;
            app.AeroplanerollexampleButton.Layout.Row = 6;
            app.AeroplanerollexampleButton.Layout.Column = 3;
            app.AeroplanerollexampleButton.Text = 'Aeroplane roll example';

            % Create ThedesignmethodsgivenhereareformulaicLabel
            app.ThedesignmethodsgivenhereareformulaicLabel = uilabel(app.GridLayout12);
            app.ThedesignmethodsgivenhereareformulaicLabel.BackgroundColor = [0.6706 0.6392 0.0275];
            app.ThedesignmethodsgivenhereareformulaicLabel.HorizontalAlignment = 'center';
            app.ThedesignmethodsgivenhereareformulaicLabel.WordWrap = 'on';
            app.ThedesignmethodsgivenhereareformulaicLabel.FontSize = 24;
            app.ThedesignmethodsgivenhereareformulaicLabel.Layout.Row = [2 3];
            app.ThedesignmethodsgivenhereareformulaicLabel.Layout.Column = 5;
            app.ThedesignmethodsgivenhereareformulaicLabel.Text = 'The design methods given here are formulaic.';

            % Create DesignfromcriteriaButton
            app.DesignfromcriteriaButton = uibutton(app.GridLayout12, 'push');
            app.DesignfromcriteriaButton.ButtonPushedFcn = createCallbackFcn(app, @DesignfromcriteriaButtonPushed, true);
            app.DesignfromcriteriaButton.WordWrap = 'on';
            app.DesignfromcriteriaButton.BackgroundColor = [0.8 0.8 0.8];
            app.DesignfromcriteriaButton.FontSize = 24;
            app.DesignfromcriteriaButton.Layout.Row = 6;
            app.DesignfromcriteriaButton.Layout.Column = 2;
            app.DesignfromcriteriaButton.Text = 'Design from criteria';

            % Create Label_2
            app.Label_2 = uilabel(app.GridLayout12);
            app.Label_2.BackgroundColor = [0.6706 0.6392 0.0275];
            app.Label_2.HorizontalAlignment = 'center';
            app.Label_2.WordWrap = 'on';
            app.Label_2.FontSize = 24;
            app.Label_2.Layout.Row = [4 6];
            app.Label_2.Layout.Column = 5;
            app.Label_2.Text = 'They help students understand how to use Bode to meet performance criteria.';

            % Create SimulinkTab
            app.SimulinkTab = uitab(app.TabGroup);
            app.SimulinkTab.AutoResizeChildren = 'off';
            app.SimulinkTab.Title = 'Simulink';

            % Create GridLayout10
            app.GridLayout10 = uigridlayout(app.SimulinkTab);
            app.GridLayout10.ColumnWidth = {'1x', '1x', '1x', '1x', '1x'};
            app.GridLayout10.RowHeight = {'0.4x', '1x', '1x', '0.4x', '1x', '1x'};
            app.GridLayout10.BackgroundColor = [0.702 1 0.702];

            % Create SimulinkfilesandnonlinearsystemslivescriptfilesLabel
            app.SimulinkfilesandnonlinearsystemslivescriptfilesLabel = uilabel(app.GridLayout10);
            app.SimulinkfilesandnonlinearsystemslivescriptfilesLabel.BackgroundColor = [0.902 0.902 0.902];
            app.SimulinkfilesandnonlinearsystemslivescriptfilesLabel.HorizontalAlignment = 'center';
            app.SimulinkfilesandnonlinearsystemslivescriptfilesLabel.FontSize = 24;
            app.SimulinkfilesandnonlinearsystemslivescriptfilesLabel.Layout.Row = 1;
            app.SimulinkfilesandnonlinearsystemslivescriptfilesLabel.Layout.Column = [1 5];
            app.SimulinkfilesandnonlinearsystemslivescriptfilesLabel.Text = 'Simulink files and non-linear systems (livescript files)';

            % Create SimulinkfilesandnonlinearsystemsvirtuallaboratoriesLabel
            app.SimulinkfilesandnonlinearsystemsvirtuallaboratoriesLabel = uilabel(app.GridLayout10);
            app.SimulinkfilesandnonlinearsystemsvirtuallaboratoriesLabel.BackgroundColor = [0.902 0.902 0.902];
            app.SimulinkfilesandnonlinearsystemsvirtuallaboratoriesLabel.HorizontalAlignment = 'center';
            app.SimulinkfilesandnonlinearsystemsvirtuallaboratoriesLabel.FontSize = 24;
            app.SimulinkfilesandnonlinearsystemsvirtuallaboratoriesLabel.Layout.Row = 4;
            app.SimulinkfilesandnonlinearsystemsvirtuallaboratoriesLabel.Layout.Column = [1 5];
            app.SimulinkfilesandnonlinearsystemsvirtuallaboratoriesLabel.Text = 'Simulink files and non-linear systems (virtual laboratories)';

            % Create HydraulicsystemButton
            app.HydraulicsystemButton = uibutton(app.GridLayout10, 'push');
            app.HydraulicsystemButton.ButtonPushedFcn = createCallbackFcn(app, @HydraulicsystemButtonPushed, true);
            app.HydraulicsystemButton.WordWrap = 'on';
            app.HydraulicsystemButton.BackgroundColor = [0.2863 0.8588 0.251];
            app.HydraulicsystemButton.FontSize = 24;
            app.HydraulicsystemButton.Layout.Row = 3;
            app.HydraulicsystemButton.Layout.Column = 1;
            app.HydraulicsystemButton.Text = 'Hydraulic system';

            % Create CarsuspensionButton
            app.CarsuspensionButton = uibutton(app.GridLayout10, 'push');
            app.CarsuspensionButton.ButtonPushedFcn = createCallbackFcn(app, @CarsuspensionButtonPushed, true);
            app.CarsuspensionButton.WordWrap = 'on';
            app.CarsuspensionButton.BackgroundColor = [0.2863 0.8588 0.251];
            app.CarsuspensionButton.FontSize = 24;
            app.CarsuspensionButton.Layout.Row = 2;
            app.CarsuspensionButton.Layout.Column = 2;
            app.CarsuspensionButton.Text = 'Car suspension';

            % Create HeatingsystemButton
            app.HeatingsystemButton = uibutton(app.GridLayout10, 'push');
            app.HeatingsystemButton.ButtonPushedFcn = createCallbackFcn(app, @HeatingsystemButtonPushed, true);
            app.HeatingsystemButton.WordWrap = 'on';
            app.HeatingsystemButton.BackgroundColor = [0.2863 0.8588 0.251];
            app.HeatingsystemButton.FontSize = 24;
            app.HeatingsystemButton.Layout.Row = 2;
            app.HeatingsystemButton.Layout.Column = 3;
            app.HeatingsystemButton.Text = 'Heating system';

            % Create SubmersibleButton
            app.SubmersibleButton = uibutton(app.GridLayout10, 'push');
            app.SubmersibleButton.ButtonPushedFcn = createCallbackFcn(app, @SubmersibleButtonPushed, true);
            app.SubmersibleButton.WordWrap = 'on';
            app.SubmersibleButton.BackgroundColor = [0.2902 0.8588 0.251];
            app.SubmersibleButton.FontSize = 24;
            app.SubmersibleButton.Layout.Row = 3;
            app.SubmersibleButton.Layout.Column = 3;
            app.SubmersibleButton.Text = 'Submersible';

            % Create PositioncontrolButton
            app.PositioncontrolButton = uibutton(app.GridLayout10, 'push');
            app.PositioncontrolButton.ButtonPushedFcn = createCallbackFcn(app, @PositioncontrolButtonPushed, true);
            app.PositioncontrolButton.WordWrap = 'on';
            app.PositioncontrolButton.BackgroundColor = [0.2863 0.8588 0.251];
            app.PositioncontrolButton.FontSize = 24;
            app.PositioncontrolButton.Layout.Row = 3;
            app.PositioncontrolButton.Layout.Column = 2;
            app.PositioncontrolButton.Text = 'Position control';

            % Create MyfirstsimulinkmodelButton
            app.MyfirstsimulinkmodelButton = uibutton(app.GridLayout10, 'push');
            app.MyfirstsimulinkmodelButton.ButtonPushedFcn = createCallbackFcn(app, @MyfirstsimulinkmodelButtonPushed, true);
            app.MyfirstsimulinkmodelButton.WordWrap = 'on';
            app.MyfirstsimulinkmodelButton.BackgroundColor = [0.2863 0.8588 0.251];
            app.MyfirstsimulinkmodelButton.FontSize = 24;
            app.MyfirstsimulinkmodelButton.Layout.Row = 5;
            app.MyfirstsimulinkmodelButton.Layout.Column = 1;
            app.MyfirstsimulinkmodelButton.Text = 'My first simulink model';

            % Create IntroductiontosimulinkmodelsButton
            app.IntroductiontosimulinkmodelsButton = uibutton(app.GridLayout10, 'push');
            app.IntroductiontosimulinkmodelsButton.ButtonPushedFcn = createCallbackFcn(app, @IntroductiontosimulinkmodelsButtonPushed, true);
            app.IntroductiontosimulinkmodelsButton.WordWrap = 'on';
            app.IntroductiontosimulinkmodelsButton.BackgroundColor = [0.2863 0.8588 0.251];
            app.IntroductiontosimulinkmodelsButton.FontSize = 24;
            app.IntroductiontosimulinkmodelsButton.Layout.Row = 2;
            app.IntroductiontosimulinkmodelsButton.Layout.Column = 1;
            app.IntroductiontosimulinkmodelsButton.Text = 'Introduction to simulink models';

            % Create NonlinearpositioncontrolButton
            app.NonlinearpositioncontrolButton = uibutton(app.GridLayout10, 'push');
            app.NonlinearpositioncontrolButton.ButtonPushedFcn = createCallbackFcn(app, @NonlinearpositioncontrolButtonPushed, true);
            app.NonlinearpositioncontrolButton.WordWrap = 'on';
            app.NonlinearpositioncontrolButton.BackgroundColor = [0.2863 0.8588 0.251];
            app.NonlinearpositioncontrolButton.FontSize = 24;
            app.NonlinearpositioncontrolButton.Layout.Row = 6;
            app.NonlinearpositioncontrolButton.Layout.Column = 1;
            app.NonlinearpositioncontrolButton.Text = 'Non-linear position control';

            % Create NonlineartankbehaviourButton
            app.NonlineartankbehaviourButton = uibutton(app.GridLayout10, 'push');
            app.NonlineartankbehaviourButton.ButtonPushedFcn = createCallbackFcn(app, @NonlineartankbehaviourButtonPushed, true);
            app.NonlineartankbehaviourButton.WordWrap = 'on';
            app.NonlineartankbehaviourButton.BackgroundColor = [0.2863 0.8588 0.251];
            app.NonlineartankbehaviourButton.FontSize = 24;
            app.NonlineartankbehaviourButton.Layout.Row = 5;
            app.NonlineartankbehaviourButton.Layout.Column = 2;
            app.NonlineartankbehaviourButton.Text = 'Non-linear tank behaviour';

            % Create NonlineartankcontrolButton_2
            app.NonlineartankcontrolButton_2 = uibutton(app.GridLayout10, 'push');
            app.NonlineartankcontrolButton_2.ButtonPushedFcn = createCallbackFcn(app, @NonlineartankcontrolButton_2Pushed, true);
            app.NonlineartankcontrolButton_2.WordWrap = 'on';
            app.NonlineartankcontrolButton_2.BackgroundColor = [0.2863 0.8588 0.251];
            app.NonlineartankcontrolButton_2.FontSize = 24;
            app.NonlineartankcontrolButton_2.Layout.Row = 6;
            app.NonlineartankcontrolButton_2.Layout.Column = 2;
            app.NonlineartankcontrolButton_2.Text = 'Non-linear tank control';

            % Create SeethefileswithinthestatespaceTABformoreexamplesLabel
            app.SeethefileswithinthestatespaceTABformoreexamplesLabel = uilabel(app.GridLayout10);
            app.SeethefileswithinthestatespaceTABformoreexamplesLabel.BackgroundColor = [0 1 0];
            app.SeethefileswithinthestatespaceTABformoreexamplesLabel.HorizontalAlignment = 'center';
            app.SeethefileswithinthestatespaceTABformoreexamplesLabel.WordWrap = 'on';
            app.SeethefileswithinthestatespaceTABformoreexamplesLabel.FontSize = 24;
            app.SeethefileswithinthestatespaceTABformoreexamplesLabel.Layout.Row = 5;
            app.SeethefileswithinthestatespaceTABformoreexamplesLabel.Layout.Column = [4 5];
            app.SeethefileswithinthestatespaceTABformoreexamplesLabel.Text = 'See the files within the state space TAB for more examples';

            % Create SeeseveralmorefilesinthevirtuallaboratoriesTABLabel
            app.SeeseveralmorefilesinthevirtuallaboratoriesTABLabel = uilabel(app.GridLayout10);
            app.SeeseveralmorefilesinthevirtuallaboratoriesTABLabel.BackgroundColor = [0 1 0];
            app.SeeseveralmorefilesinthevirtuallaboratoriesTABLabel.HorizontalAlignment = 'center';
            app.SeeseveralmorefilesinthevirtuallaboratoriesTABLabel.WordWrap = 'on';
            app.SeeseveralmorefilesinthevirtuallaboratoriesTABLabel.FontSize = 24;
            app.SeeseveralmorefilesinthevirtuallaboratoriesTABLabel.Layout.Row = 6;
            app.SeeseveralmorefilesinthevirtuallaboratoriesTABLabel.Layout.Column = [4 5];
            app.SeeseveralmorefilesinthevirtuallaboratoriesTABLabel.Text = {'See several more '; 'files in the virtual laboratories TAB'};

            % Create ThesimulinkfilesLabel
            app.ThesimulinkfilesLabel = uilabel(app.GridLayout10);
            app.ThesimulinkfilesLabel.BackgroundColor = [0.6706 0.6392 0.0275];
            app.ThesimulinkfilesLabel.HorizontalAlignment = 'center';
            app.ThesimulinkfilesLabel.WordWrap = 'on';
            app.ThesimulinkfilesLabel.FontSize = 24;
            app.ThesimulinkfilesLabel.Layout.Row = [2 3];
            app.ThesimulinkfilesLabel.Layout.Column = 5;
            app.ThesimulinkfilesLabel.Text = 'The simulink files and their usage are detailed within the livescripts.';

            % Create LinearisationButton
            app.LinearisationButton = uibutton(app.GridLayout10, 'push');
            app.LinearisationButton.ButtonPushedFcn = createCallbackFcn(app, @LinearisationButtonPushed, true);
            app.LinearisationButton.WordWrap = 'on';
            app.LinearisationButton.BackgroundColor = [0.2863 0.8588 0.251];
            app.LinearisationButton.FontSize = 24;
            app.LinearisationButton.Layout.Row = 5;
            app.LinearisationButton.Layout.Column = 3;
            app.LinearisationButton.Text = 'Linearisation';

            % Create SimpleexamplesButton
            app.SimpleexamplesButton = uibutton(app.GridLayout10, 'push');
            app.SimpleexamplesButton.ButtonPushedFcn = createCallbackFcn(app, @SimpleexamplesButtonPushed, true);
            app.SimpleexamplesButton.WordWrap = 'on';
            app.SimpleexamplesButton.BackgroundColor = [0.2863 0.8588 0.251];
            app.SimpleexamplesButton.FontSize = 24;
            app.SimpleexamplesButton.Layout.Row = 2;
            app.SimpleexamplesButton.Layout.Column = 4;
            app.SimpleexamplesButton.Text = 'Simple examples';

            % Create TwotankssystemButton
            app.TwotankssystemButton = uibutton(app.GridLayout10, 'push');
            app.TwotankssystemButton.ButtonPushedFcn = createCallbackFcn(app, @TwotankssystemButtonPushed, true);
            app.TwotankssystemButton.WordWrap = 'on';
            app.TwotankssystemButton.BackgroundColor = [0.2902 0.8588 0.251];
            app.TwotankssystemButton.FontSize = 24;
            app.TwotankssystemButton.Layout.Row = 3;
            app.TwotankssystemButton.Layout.Column = 4;
            app.TwotankssystemButton.Text = 'Two tanks system';

            % Create SampleddatasystemsTab
            app.SampleddatasystemsTab = uitab(app.TabGroup);
            app.SampleddatasystemsTab.AutoResizeChildren = 'off';
            app.SampleddatasystemsTab.Title = 'Sampled data systems';

            % Create GridLayout11
            app.GridLayout11 = uigridlayout(app.SampleddatasystemsTab);
            app.GridLayout11.ColumnWidth = {'1x', '1x', '1x', '1x', '1x'};
            app.GridLayout11.RowHeight = {'0.5x', '1x', '1x', '1x', '1x', '1x', '1x'};
            app.GridLayout11.BackgroundColor = [0.6 0.9725 1];

            % Create AdvancedcontrolanddiscretesystemsappsinlightercolourLabel
            app.AdvancedcontrolanddiscretesystemsappsinlightercolourLabel = uilabel(app.GridLayout11);
            app.AdvancedcontrolanddiscretesystemsappsinlightercolourLabel.BackgroundColor = [0.902 0.902 0.902];
            app.AdvancedcontrolanddiscretesystemsappsinlightercolourLabel.HorizontalAlignment = 'center';
            app.AdvancedcontrolanddiscretesystemsappsinlightercolourLabel.FontSize = 24;
            app.AdvancedcontrolanddiscretesystemsappsinlightercolourLabel.Layout.Row = 1;
            app.AdvancedcontrolanddiscretesystemsappsinlightercolourLabel.Layout.Column = [1 5];
            app.AdvancedcontrolanddiscretesystemsappsinlightercolourLabel.Text = 'Advanced control and discrete systems (apps in lighter colour)';

            % Create TimeseriesmodelsButton
            app.TimeseriesmodelsButton = uibutton(app.GridLayout11, 'push');
            app.TimeseriesmodelsButton.ButtonPushedFcn = createCallbackFcn(app, @TimeseriesmodelsButtonPushed, true);
            app.TimeseriesmodelsButton.WordWrap = 'on';
            app.TimeseriesmodelsButton.BackgroundColor = [0.3686 0.6706 0.9216];
            app.TimeseriesmodelsButton.FontSize = 24;
            app.TimeseriesmodelsButton.Layout.Row = 2;
            app.TimeseriesmodelsButton.Layout.Column = 1;
            app.TimeseriesmodelsButton.Text = 'Time series models';

            % Create TimeseriesandrecursionButton
            app.TimeseriesandrecursionButton = uibutton(app.GridLayout11, 'push');
            app.TimeseriesandrecursionButton.ButtonPushedFcn = createCallbackFcn(app, @TimeseriesandrecursionButtonPushed, true);
            app.TimeseriesandrecursionButton.WordWrap = 'on';
            app.TimeseriesandrecursionButton.BackgroundColor = [0.3686 0.6706 0.9216];
            app.TimeseriesandrecursionButton.FontSize = 24;
            app.TimeseriesandrecursionButton.Layout.Row = 2;
            app.TimeseriesandrecursionButton.Layout.Column = 2;
            app.TimeseriesandrecursionButton.Text = 'Time series and recursion';

            % Create DiscretemodelsButton
            app.DiscretemodelsButton = uibutton(app.GridLayout11, 'push');
            app.DiscretemodelsButton.ButtonPushedFcn = createCallbackFcn(app, @DiscretemodelsButtonPushed, true);
            app.DiscretemodelsButton.WordWrap = 'on';
            app.DiscretemodelsButton.BackgroundColor = [0.3686 0.6706 0.9216];
            app.DiscretemodelsButton.FontSize = 24;
            app.DiscretemodelsButton.Layout.Row = 2;
            app.DiscretemodelsButton.Layout.Column = 3;
            app.DiscretemodelsButton.Text = 'Discrete models';

            % Create DiscretisationandBodeButton
            app.DiscretisationandBodeButton = uibutton(app.GridLayout11, 'push');
            app.DiscretisationandBodeButton.ButtonPushedFcn = createCallbackFcn(app, @DiscretisationandBodeButtonPushed, true);
            app.DiscretisationandBodeButton.WordWrap = 'on';
            app.DiscretisationandBodeButton.BackgroundColor = [0.3686 0.6706 0.9216];
            app.DiscretisationandBodeButton.FontSize = 24;
            app.DiscretisationandBodeButton.Layout.Row = 2;
            app.DiscretisationandBodeButton.Layout.Column = 4;
            app.DiscretisationandBodeButton.Text = 'Discretisation and Bode';

            % Create StabilityofdiscreteButton
            app.StabilityofdiscreteButton = uibutton(app.GridLayout11, 'push');
            app.StabilityofdiscreteButton.ButtonPushedFcn = createCallbackFcn(app, @StabilityofdiscreteButtonPushed, true);
            app.StabilityofdiscreteButton.WordWrap = 'on';
            app.StabilityofdiscreteButton.BackgroundColor = [0.3686 0.6706 0.9216];
            app.StabilityofdiscreteButton.FontSize = 24;
            app.StabilityofdiscreteButton.Layout.Row = 2;
            app.StabilityofdiscreteButton.Layout.Column = 5;
            app.StabilityofdiscreteButton.Text = 'Stability of discrete';

            % Create AntiresetwindupButton
            app.AntiresetwindupButton = uibutton(app.GridLayout11, 'push');
            app.AntiresetwindupButton.ButtonPushedFcn = createCallbackFcn(app, @AntiresetwindupButtonPushed, true);
            app.AntiresetwindupButton.WordWrap = 'on';
            app.AntiresetwindupButton.BackgroundColor = [0.3686 0.6706 0.9216];
            app.AntiresetwindupButton.FontSize = 24;
            app.AntiresetwindupButton.Layout.Row = 7;
            app.AntiresetwindupButton.Layout.Column = 1;
            app.AntiresetwindupButton.Text = 'Anti-reset windup';

            % Create ControlstructuresButton
            app.ControlstructuresButton = uibutton(app.GridLayout11, 'push');
            app.ControlstructuresButton.ButtonPushedFcn = createCallbackFcn(app, @ControlstructuresButtonPushed, true);
            app.ControlstructuresButton.WordWrap = 'on';
            app.ControlstructuresButton.BackgroundColor = [0.3686 0.6706 0.9216];
            app.ControlstructuresButton.FontSize = 24;
            app.ControlstructuresButton.Layout.Row = 7;
            app.ControlstructuresButton.Layout.Column = 2;
            app.ControlstructuresButton.Text = 'Control structures';

            % Create DiscretePIDButton
            app.DiscretePIDButton = uibutton(app.GridLayout11, 'push');
            app.DiscretePIDButton.ButtonPushedFcn = createCallbackFcn(app, @DiscretePIDButtonPushed, true);
            app.DiscretePIDButton.WordWrap = 'on';
            app.DiscretePIDButton.BackgroundColor = [0.3686 0.6706 0.9216];
            app.DiscretePIDButton.FontSize = 24;
            app.DiscretePIDButton.Layout.Row = 7;
            app.DiscretePIDButton.Layout.Column = 3;
            app.DiscretePIDButton.Text = 'Discrete PID';

            % Create DeadbeatcontrolButton
            app.DeadbeatcontrolButton = uibutton(app.GridLayout11, 'push');
            app.DeadbeatcontrolButton.ButtonPushedFcn = createCallbackFcn(app, @DeadbeatcontrolButtonPushed, true);
            app.DeadbeatcontrolButton.WordWrap = 'on';
            app.DeadbeatcontrolButton.BackgroundColor = [0.3686 0.6706 0.9216];
            app.DeadbeatcontrolButton.FontSize = 24;
            app.DeadbeatcontrolButton.Layout.Row = 7;
            app.DeadbeatcontrolButton.Layout.Column = 4;
            app.DeadbeatcontrolButton.Text = 'Dead-beat control';

            % Create SmithpredictorButton
            app.SmithpredictorButton = uibutton(app.GridLayout11, 'push');
            app.SmithpredictorButton.ButtonPushedFcn = createCallbackFcn(app, @SmithpredictorButtonPushed, true);
            app.SmithpredictorButton.WordWrap = 'on';
            app.SmithpredictorButton.BackgroundColor = [0.3686 0.6706 0.9216];
            app.SmithpredictorButton.FontSize = 24;
            app.SmithpredictorButton.Layout.Row = 6;
            app.SmithpredictorButton.Layout.Column = 5;
            app.SmithpredictorButton.Text = 'Smith predictor';

            % Create PIDviapolecancellationButton
            app.PIDviapolecancellationButton = uibutton(app.GridLayout11, 'push');
            app.PIDviapolecancellationButton.ButtonPushedFcn = createCallbackFcn(app, @PIDviapolecancellationButtonPushed, true);
            app.PIDviapolecancellationButton.WordWrap = 'on';
            app.PIDviapolecancellationButton.BackgroundColor = [0.3686 0.6706 0.9216];
            app.PIDviapolecancellationButton.FontSize = 24;
            app.PIDviapolecancellationButton.Layout.Row = 6;
            app.PIDviapolecancellationButton.Layout.Column = 1;
            app.PIDviapolecancellationButton.Text = 'PID via pole cancellation';

            % Create YouladesignButton
            app.YouladesignButton = uibutton(app.GridLayout11, 'push');
            app.YouladesignButton.ButtonPushedFcn = createCallbackFcn(app, @YouladesignButtonPushed, true);
            app.YouladesignButton.WordWrap = 'on';
            app.YouladesignButton.BackgroundColor = [0.3686 0.6706 0.9216];
            app.YouladesignButton.FontSize = 24;
            app.YouladesignButton.Layout.Row = 6;
            app.YouladesignButton.Layout.Column = 2;
            app.YouladesignButton.Text = 'Youla design';

            % Create DiscreteYouladesignButton
            app.DiscreteYouladesignButton = uibutton(app.GridLayout11, 'push');
            app.DiscreteYouladesignButton.ButtonPushedFcn = createCallbackFcn(app, @DiscreteYouladesignButtonPushed, true);
            app.DiscreteYouladesignButton.WordWrap = 'on';
            app.DiscreteYouladesignButton.BackgroundColor = [0.3686 0.6706 0.9216];
            app.DiscreteYouladesignButton.FontSize = 24;
            app.DiscreteYouladesignButton.Layout.Row = 6;
            app.DiscreteYouladesignButton.Layout.Column = 3;
            app.DiscreteYouladesignButton.Text = 'Discrete Youla design';

            % Create DiscretemethodsButton
            app.DiscretemethodsButton = uibutton(app.GridLayout11, 'push');
            app.DiscretemethodsButton.ButtonPushedFcn = createCallbackFcn(app, @DiscretemethodsButtonPushed, true);
            app.DiscretemethodsButton.WordWrap = 'on';
            app.DiscretemethodsButton.BackgroundColor = [0.3686 0.6706 0.9216];
            app.DiscretemethodsButton.FontSize = 24;
            app.DiscretemethodsButton.Layout.Row = 6;
            app.DiscretemethodsButton.Layout.Column = 4;
            app.DiscretemethodsButton.Text = 'Discrete methods';

            % Create Manyofthesefilesgofarbeyonda1sLabel
            app.Manyofthesefilesgofarbeyonda1sLabel = uilabel(app.GridLayout11);
            app.Manyofthesefilesgofarbeyonda1sLabel.BackgroundColor = [0.6706 0.6392 0.0275];
            app.Manyofthesefilesgofarbeyonda1sLabel.HorizontalAlignment = 'center';
            app.Manyofthesefilesgofarbeyonda1sLabel.WordWrap = 'on';
            app.Manyofthesefilesgofarbeyonda1sLabel.FontSize = 24;
            app.Manyofthesefilesgofarbeyonda1sLabel.Layout.Row = 5;
            app.Manyofthesefilesgofarbeyonda1sLabel.Layout.Column = [1 5];
            app.Manyofthesefilesgofarbeyonda1sLabel.Text = 'Many of the files below go far beyond a 1st and 2nd course in control.';

            % Create AnaloguetodigitalconvertorButton
            app.AnaloguetodigitalconvertorButton = uibutton(app.GridLayout11, 'push');
            app.AnaloguetodigitalconvertorButton.ButtonPushedFcn = createCallbackFcn(app, @AnaloguetodigitalconvertorButtonPushed, true);
            app.AnaloguetodigitalconvertorButton.WordWrap = 'on';
            app.AnaloguetodigitalconvertorButton.BackgroundColor = [1 0.9098 0.6588];
            app.AnaloguetodigitalconvertorButton.FontSize = 18;
            app.AnaloguetodigitalconvertorButton.Layout.Row = 3;
            app.AnaloguetodigitalconvertorButton.Layout.Column = 1;
            app.AnaloguetodigitalconvertorButton.Text = 'Analogue to digital convertor';

            % Create DigitaltoanalogueconvertorButton
            app.DigitaltoanalogueconvertorButton = uibutton(app.GridLayout11, 'push');
            app.DigitaltoanalogueconvertorButton.ButtonPushedFcn = createCallbackFcn(app, @DigitaltoanalogueconvertorButtonPushed, true);
            app.DigitaltoanalogueconvertorButton.WordWrap = 'on';
            app.DigitaltoanalogueconvertorButton.BackgroundColor = [0.9294 0.9098 0.6588];
            app.DigitaltoanalogueconvertorButton.FontSize = 18;
            app.DigitaltoanalogueconvertorButton.Layout.Row = 3;
            app.DigitaltoanalogueconvertorButton.Layout.Column = 2;
            app.DigitaltoanalogueconvertorButton.Text = 'Digital to analogue convertor';

            % Create ContinuousanddiscretemappingButton
            app.ContinuousanddiscretemappingButton = uibutton(app.GridLayout11, 'push');
            app.ContinuousanddiscretemappingButton.ButtonPushedFcn = createCallbackFcn(app, @ContinuousanddiscretemappingButtonPushed, true);
            app.ContinuousanddiscretemappingButton.WordWrap = 'on';
            app.ContinuousanddiscretemappingButton.BackgroundColor = [1 0.9098 0.6588];
            app.ContinuousanddiscretemappingButton.FontSize = 18;
            app.ContinuousanddiscretemappingButton.Layout.Row = 3;
            app.ContinuousanddiscretemappingButton.Layout.Column = 3;
            app.ContinuousanddiscretemappingButton.Text = 'Continuous and discrete mapping';

            % Create ClosedloopundersamplingButton
            app.ClosedloopundersamplingButton = uibutton(app.GridLayout11, 'push');
            app.ClosedloopundersamplingButton.ButtonPushedFcn = createCallbackFcn(app, @ClosedloopundersamplingButtonPushed, true);
            app.ClosedloopundersamplingButton.WordWrap = 'on';
            app.ClosedloopundersamplingButton.BackgroundColor = [1 0.9098 0.6588];
            app.ClosedloopundersamplingButton.FontSize = 18;
            app.ClosedloopundersamplingButton.Layout.Row = 3;
            app.ClosedloopundersamplingButton.Layout.Column = 4;
            app.ClosedloopundersamplingButton.Text = 'Closed-loop under sampling';

            % Create SignaltypeswithsamplingButton
            app.SignaltypeswithsamplingButton = uibutton(app.GridLayout11, 'push');
            app.SignaltypeswithsamplingButton.ButtonPushedFcn = createCallbackFcn(app, @SignaltypeswithsamplingButtonPushed, true);
            app.SignaltypeswithsamplingButton.WordWrap = 'on';
            app.SignaltypeswithsamplingButton.BackgroundColor = [1 0.9098 0.6588];
            app.SignaltypeswithsamplingButton.FontSize = 18;
            app.SignaltypeswithsamplingButton.Layout.Row = 3;
            app.SignaltypeswithsamplingButton.Layout.Column = 5;
            app.SignaltypeswithsamplingButton.Text = 'Signal types with sampling';

            % Create SignalreconstructionButton
            app.SignalreconstructionButton = uibutton(app.GridLayout11, 'push');
            app.SignalreconstructionButton.ButtonPushedFcn = createCallbackFcn(app, @SignalreconstructionButtonPushed, true);
            app.SignalreconstructionButton.WordWrap = 'on';
            app.SignalreconstructionButton.BackgroundColor = [0.3686 0.6706 0.9216];
            app.SignalreconstructionButton.FontSize = 24;
            app.SignalreconstructionButton.Layout.Row = 4;
            app.SignalreconstructionButton.Layout.Column = 1;
            app.SignalreconstructionButton.Text = 'Signal reconstruction';

            % Create SampleddatasystemsButton
            app.SampleddatasystemsButton = uibutton(app.GridLayout11, 'push');
            app.SampleddatasystemsButton.ButtonPushedFcn = createCallbackFcn(app, @SampleddatasystemsButtonPushed, true);
            app.SampleddatasystemsButton.WordWrap = 'on';
            app.SampleddatasystemsButton.BackgroundColor = [0.3686 0.6706 0.9216];
            app.SampleddatasystemsButton.FontSize = 24;
            app.SampleddatasystemsButton.Layout.Row = 4;
            app.SampleddatasystemsButton.Layout.Column = 2;
            app.SampleddatasystemsButton.Text = 'Sampled data systems';

            % Create SamplingoperationButton
            app.SamplingoperationButton = uibutton(app.GridLayout11, 'push');
            app.SamplingoperationButton.ButtonPushedFcn = createCallbackFcn(app, @SamplingoperationButtonPushed, true);
            app.SamplingoperationButton.WordWrap = 'on';
            app.SamplingoperationButton.BackgroundColor = [0.3686 0.6706 0.9216];
            app.SamplingoperationButton.FontSize = 24;
            app.SamplingoperationButton.Layout.Row = 4;
            app.SamplingoperationButton.Layout.Column = 3;
            app.SamplingoperationButton.Text = 'Sampling operation';

            % Create SignaltypesincomputercontrolButton
            app.SignaltypesincomputercontrolButton = uibutton(app.GridLayout11, 'push');
            app.SignaltypesincomputercontrolButton.ButtonPushedFcn = createCallbackFcn(app, @SignaltypesincomputercontrolButtonPushed, true);
            app.SignaltypesincomputercontrolButton.WordWrap = 'on';
            app.SignaltypesincomputercontrolButton.BackgroundColor = [0.3686 0.6706 0.9216];
            app.SignaltypesincomputercontrolButton.FontSize = 18;
            app.SignaltypesincomputercontrolButton.Layout.Row = 4;
            app.SignaltypesincomputercontrolButton.Layout.Column = 4;
            app.SignaltypesincomputercontrolButton.Text = 'Signal types in computer control';

            % Create ModelPredictiveControlTab
            app.ModelPredictiveControlTab = uitab(app.TabGroup);
            app.ModelPredictiveControlTab.Title = 'Model Predictive Control';

            % Create GridLayout13
            app.GridLayout13 = uigridlayout(app.ModelPredictiveControlTab);
            app.GridLayout13.ColumnWidth = {'1x', '1x', '1x', '1x', '1x'};
            app.GridLayout13.RowHeight = {'1x', '1x', '1x', '1x', '1x'};
            app.GridLayout13.BackgroundColor = [0.9882 0.9882 0.5725];

            % Create ModelpredictivecontrolanintroductionLabel
            app.ModelpredictivecontrolanintroductionLabel = uilabel(app.GridLayout13);
            app.ModelpredictivecontrolanintroductionLabel.BackgroundColor = [0.9608 0.4667 0.1608];
            app.ModelpredictivecontrolanintroductionLabel.HorizontalAlignment = 'center';
            app.ModelpredictivecontrolanintroductionLabel.FontSize = 24;
            app.ModelpredictivecontrolanintroductionLabel.FontColor = [0 0 0];
            app.ModelpredictivecontrolanintroductionLabel.Layout.Row = 1;
            app.ModelpredictivecontrolanintroductionLabel.Layout.Column = [1 5];
            app.ModelpredictivecontrolanintroductionLabel.Text = 'Model predictive control (an introduction)';

            % Create SourcefilesButton
            app.SourcefilesButton = uibutton(app.GridLayout13, 'push');
            app.SourcefilesButton.ButtonPushedFcn = createCallbackFcn(app, @SourcefilesButtonPushed, true);
            app.SourcefilesButton.BackgroundColor = [0.9294 0.6941 0.1255];
            app.SourcefilesButton.FontSize = 24;
            app.SourcefilesButton.Layout.Row = 2;
            app.SourcefilesButton.Layout.Column = 1;
            app.SourcefilesButton.Text = 'Source files';

            % Create ConceptsofpredictionButton
            app.ConceptsofpredictionButton = uibutton(app.GridLayout13, 'push');
            app.ConceptsofpredictionButton.ButtonPushedFcn = createCallbackFcn(app, @ConceptsofpredictionButtonPushed, true);
            app.ConceptsofpredictionButton.WordWrap = 'on';
            app.ConceptsofpredictionButton.BackgroundColor = [0.9294 0.6941 0.1255];
            app.ConceptsofpredictionButton.FontSize = 24;
            app.ConceptsofpredictionButton.Layout.Row = 2;
            app.ConceptsofpredictionButton.Layout.Column = 2;
            app.ConceptsofpredictionButton.Text = 'Concepts of prediction';

            % Create MPCtuningButton
            app.MPCtuningButton = uibutton(app.GridLayout13, 'push');
            app.MPCtuningButton.ButtonPushedFcn = createCallbackFcn(app, @MPCtuningButtonPushed, true);
            app.MPCtuningButton.BackgroundColor = [0.9294 0.6941 0.1255];
            app.MPCtuningButton.FontSize = 24;
            app.MPCtuningButton.Layout.Row = 2;
            app.MPCtuningButton.Layout.Column = 3;
            app.MPCtuningButton.Text = 'MPC tuning';

            % Create MPCfailingButton
            app.MPCfailingButton = uibutton(app.GridLayout13, 'push');
            app.MPCfailingButton.ButtonPushedFcn = createCallbackFcn(app, @MPCfailingButtonPushed, true);
            app.MPCfailingButton.BackgroundColor = [0.9294 0.6941 0.1255];
            app.MPCfailingButton.FontSize = 24;
            app.MPCfailingButton.Layout.Row = 2;
            app.MPCfailingButton.Layout.Column = 4;
            app.MPCfailingButton.Text = 'MPC failing';

            % Create MPCwithaTfilterButton
            app.MPCwithaTfilterButton = uibutton(app.GridLayout13, 'push');
            app.MPCwithaTfilterButton.ButtonPushedFcn = createCallbackFcn(app, @MPCwithaTfilterButtonPushed, true);
            app.MPCwithaTfilterButton.WordWrap = 'on';
            app.MPCwithaTfilterButton.BackgroundColor = [0.9294 0.6941 0.1255];
            app.MPCwithaTfilterButton.FontSize = 24;
            app.MPCwithaTfilterButton.Layout.Row = 2;
            app.MPCwithaTfilterButton.Layout.Column = 5;
            app.MPCwithaTfilterButton.Text = 'MPC with a T-filter';

            % Create MPCandconstrainthandlingButton
            app.MPCandconstrainthandlingButton = uibutton(app.GridLayout13, 'push');
            app.MPCandconstrainthandlingButton.ButtonPushedFcn = createCallbackFcn(app, @MPCandconstrainthandlingButtonPushed, true);
            app.MPCandconstrainthandlingButton.WordWrap = 'on';
            app.MPCandconstrainthandlingButton.BackgroundColor = [0.9294 0.6941 0.1255];
            app.MPCandconstrainthandlingButton.FontSize = 24;
            app.MPCandconstrainthandlingButton.Layout.Row = 3;
            app.MPCandconstrainthandlingButton.Layout.Column = 1;
            app.MPCandconstrainthandlingButton.Text = 'MPC and constraint handling';

            % Create MPCandfeedforwardButton
            app.MPCandfeedforwardButton = uibutton(app.GridLayout13, 'push');
            app.MPCandfeedforwardButton.ButtonPushedFcn = createCallbackFcn(app, @MPCandfeedforwardButtonPushed, true);
            app.MPCandfeedforwardButton.WordWrap = 'on';
            app.MPCandfeedforwardButton.BackgroundColor = [0.9294 0.6941 0.1255];
            app.MPCandfeedforwardButton.FontSize = 24;
            app.MPCandfeedforwardButton.Layout.Row = 3;
            app.MPCandfeedforwardButton.Layout.Column = 2;
            app.MPCandfeedforwardButton.Text = 'MPC and feedforward';

            % Show the figure after all components are created
            app.UIFigure.Visible = 'on';
        end
    end

    % App creation and deletion
    methods (Access = public)

        % Construct app
        function app = control101_master

            % Create UIFigure and components
            createComponents(app)

            % Register the app with App Designer
            registerApp(app, app.UIFigure)

            if nargout == 0
                clear app
            end
        end

        % Code that executes before app deletion
        function delete(app)

            % Delete UIFigure when app is deleted
            delete(app.UIFigure)
        end
    end
end

