% Dervies model for the fan and plate system at a specified operating point
function sys=FanAndPlate_model_control101(x0)

%x0 = [ 1; 500*2*pi/60;60*2*pi/60; deg2rad(20)];  % Example operating point for x

% Parameter set
Rm_P = 0.0305; 
Lm_P = 0.0000177; 
Kb_P = 0.077; 
Kt_P = 0.077;
Jm_P = 0.0000536; 
Bm_P = 0.014293;
Kpl_P = 0.0001;
rho_P = 1.293;
r_P = 0.06;
Ap_P = 0.03;
lx_P = 0.02; 
Bp_P = 0.028586; 
Jp_P = 0.00536; 
mp_P = 0.270; 
g_P = 9.81;

syms x1 x2 x3 x4 u d Rm Lm Kb Kt Jm Bmm Kpl rho r Ap lx Bp Jp mp g real
x = [ x1; x2; x3; x4 ];

% Define the nonlinear state equations
f = [-Rm/Lm*x1 - Kb/Lm*x2 + u/Lm ;
      Kt/Jm*x1 - Bmm/Jm*x2 - Kpl/Jm*x2^2 ;
      -Bp/Jp*x3+((rho*Ap*(r^2)*lx)/(4*Jp))*(x2^2)*cos(x4)-mp*g*lx/(2*Jp)*sin(x4)+d/Jp ;
      x3];  % Example: Simple nonlinear system
h = x4;        % Example: Output equations

% Compute the Jacobian matrices
A = jacobian(f, x);  % Jacobian of f with respect to x
B = jacobian(f, u);  % Jacobian of f with respect to u
C = jacobian(h, x);  % Jacobian of h with respect to x
D = jacobian(h, u);  % Jacobian of h with respect to u

% Substitute the system parameters into the Jacobians
A = subs(   A, ...
        [ Rm; Lm; Kb; Kt; Jm; Bmm; Kpl; rho; r; Ap; lx; Bp; Jp; mp; g ], ...
        [ Rm_P; Lm_P; Kb_P; Kt_P; Jm_P; Bm_P; Kpl_P; rho_P; r_P; Ap_P; lx_P; Bp_P; Jp_P; mp_P; g_P ]);
B = subs(   B, ...
        [ Rm; Lm; Kb; Kt; Jm; Bmm; Kpl; rho; r; Ap; lx; Bp; Jp; mp; g ], ...
        [ Rm_P; Lm_P; Kb_P; Kt_P; Jm_P; Bm_P; Kpl_P; rho_P; r_P; Ap_P; lx_P; Bp_P; Jp_P; mp_P; g_P ]);

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