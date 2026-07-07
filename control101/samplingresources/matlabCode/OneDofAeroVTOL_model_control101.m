% Dervies model for the fan and plate system at a specified operating point
function sys=OneDofAeroVTOL_model_control101(x0)

% Parameter set
Rm_P = 8.4; 
Lm_P = 0.00538; 
Kb_P = 0.0577; 
Kt_P = 0.0577; 
Jm_P = 0.000184; 
Bm_P = 0.001;
Kpl_P = 0.00001; 
Kf_P = 0.0002; 
l1_P = 0.0156; 
l2_P = 0.0056;
l3_P = 0.0035;
Bl_P = 0.002; 
Jl_P = 0.00017; 
m1_P = 0.068; 
m2_P = 0.27;
m3_P = 0.048;
g_P = 9.81;


% Define symbolic variables
syms x1 x2 x3 x4 u d Rm Lm Kb Kt Jm Bmm Kpl Kf l1 l2 l3 Bl Jl m1 m2 m3 g real
x = [ x1; x2; x3; x4 ];

% Define the nonlinear state equations
f = [-Rm/Lm*x1 - Kb/Lm*x2 + u/Lm ;
      Kt/Jm*x1 - Bmm/Jm*x2 - Kpl/Jm*x2^2 ;
      (Kf*l1/Jl)*x2^2-(Bl/Jl)*x3+((m2*g*l2-m1*g*l1-m3*g*l3)/Jl)*cos(x4) ;
      x3];  % Example: Simple nonlinear system
h = x4;        % Example: Output equations

% Compute the Jacobian matrices
A = jacobian(f, x);  % Jacobian of f with respect to x
B = jacobian(f, u);  % Jacobian of f with respect to u
C = jacobian(h, x);  % Jacobian of h with respect to x
D = jacobian(h, u);  % Jacobian of h with respect to u

% Substitute the system parameters into the Jacobians
A = subs(   A, ...
        [ Rm; Lm; Kb; Kt; Jm; Bmm; Kpl; Kf; l1; l2; l3; Bl; Jl; m1; m2; m3; g ], ...
        [ Rm_P; Lm_P; Kb_P; Kt_P; Jm_P; Bm_P; Kpl_P; Kf_P; l1_P; l2_P; l3_P; Bl_P; Jl_P; m1_P; m2_P; m3_P; g_P ]);
B = subs(   B, ...
        [ Rm; Lm; Kb; Kt; Jm; Bmm; Kpl; Kf; l1; l2; l3; Bl; Jl; m1; m2; m3; g ], ...
        [ Rm_P; Lm_P; Kb_P; Kt_P; Jm_P; Bm_P; Kpl_P; Kf_P; l1_P; l2_P; l3_P; Bl_P; Jl_P; m1_P; m2_P; m3_P; g_P ]);

% Substitute the operating point into the Jacobians
A_lin = subs(A, x, x0 );
B_lin = subs(B, x, x0);
C_lin = subs(C, x, x0);
D_lin = subs(D, x, x0);

% Convert symbolic matrices to numeric values
A_lin = double(A_lin);
B_lin = double(B_lin);
C_lin = double(C_lin);
D_lin = double(D_lin);
  
% Create the state-space system
sys = ss(A_lin, B_lin, C_lin, D_lin);