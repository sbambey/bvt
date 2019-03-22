clc
clear variables

%% MATLAB code to determine injector parameters.
%Running a for loop for all the desired variables and quit the loop when
%desired values are reached

for d_f=0.02:0.01:0.07
    for d_o=0.02:0.01:0.07
        for A_f=0.05:0.01:1
            for A_o=0.05:0.01:1
                for L_fs_f=0.01:0.01:1
%                     for L_fs_o=0.01:0.1:1
                        %% Initiate Variables
                        p_f=0.0325; %Fuel density (lb/in^3)
                        p_o=0.0412; %Ox. density (lb/in^3)

                        sf_f=0.00015417; %Fuel surf. tension (lb/in)
                        sf_o=0.00021864; %Ox. surf. tension (lb/in)
                        
                        vis_f=9.1275e-5; %Fuel dyn visc. (lb*s/in)
                        vis_o=7.2516e-7; %Ox. dyn visc. @173K (lb*s/in)
                        
                        g=386.1; %Grav. const. (in/sec^2)
                        C_d=0.75; %Discharge Coeff. Value ranges from 0.5 to 0.92 and can be determined through flow test

                        P_f=258.17; %Fuel Pressure (psi). From 'Optimization Output' spreadsheet, 1.76E+06 Pa, at the tank
                        P_o=310.38; %Oxidiser Pressure (psi). From 'Optimization Output' spreadsheet, 1.78E+06 Pa, at the tank

                        T_d_P_f=P_f*0.2; %Target fuel pressure drop (psi). For a 20% pressure drop
                        T_d_P_o=P_o*0.2; %Target Ox. pressure drop (psi). For a 20% pressure drop

                        theta=60; %Impingement angle (degres)
                        L_fs_o=L_fs_f; 

                        %% Injection velocity
                        w_f_dot=4.01; %Fuel mass flow rate (lb/sec). From 'Optimization Output' spreadsheet, 1.4 kg/s
                        v_f=(w_f_dot)/(A_f*p_f); %Fuel injection velocity (in/sec). Eq. 4-39 from Design of Liquid Rocket Engines - NASA

                        w_o_dot=9.22; %Ox. mass flow rate (lb/sec). From 'Optimization Output' spreadsheet, 3.2 kg/s
                        v_o=(w_o_dot)/(A_o*p_o); %Ox. Injection velocity (in/sec). Eq. 4-39 from Design of Liquid Rocket Engines - NASA

                        %% Injection pressure drop
                        d_P_f=(1/(2*g*p_f))*((w_f_dot/(C_d*A_f))^2); %Fuel pressure drop (lb/in^2). Eq. 4-40 from Design of Liquid Rocket Engines - NASA
                        d_P_o=(1/(2*g*p_o))*((w_o_dot/(C_d*A_o))^2); %Ox. pressure drop (lb/in^2). Eq. 4-40 from Design of Liquid Rocket Engines - NASA

                        %% Orifice area ratio
                        M=1; %Mixing Factor 1-on-1:M=1, 2-on-1:M=1.6
                        o_rat=(M*((p_o/p_f)*(w_f_dot/w_o_dot)^2)^(0.7)); %d_f/d_o. Orifice Area Ratio
                        o_rat_act=(d_f)^2/(d_o)^2; %Actual orifice area ratio

                        %% Number of elements
                        n_f=A_f/(pi*((d_f/2)^2)); %Number of fuel elements
                        n_o=A_o/(pi*((d_o/2)^2)); %Number of ox. elements

                        %% Impinging distance
                        f_d_rat=L_fs_f/d_f; %Fuel distance ratio. Eq. (2.1.1.1.4) from Liquid Rocket Engine Injectors. Values between 5-7 desired
                        o_d_rat=L_fs_o/d_o; %Ox. Distance ratio. Eq. (2.1.1.1.4) from Liquid Rocket Engine Injectors. Values between 5-7 desired
                        d=(L_fs_f+L_fs_o)*sind(theta/2); %Distance between orifice centers
                        
                        %% Beta angle
                        a1=30; %(deg) Angle between engine axis and fuel stream
                        a2=30; %(deg) Angle between engine axis and ox. stream
                        beta=atand((w_f_dot*v_f*sind(a1)-w_o_dot*v_o*sind(a2))/(w_f_dot*v_f*cosd(a1)+w_o_dot*v_o*cosd(a2)));
                        
                        %% Momentum Ratio
                        R_m=(w_o_dot*v_o)/(w_f_dot*v_f); %Momentum ratio. Ideally between 1.5-3.5. Eq. 4-42 from Design of Liquid Rocket Engines - NASA. 
                        
                        %% Non-dimensionalised numbers
                        weber_f=(p_f)*(v_f^2)*(d_f)/(sf_f); %Fuel weber no.
                        weber_o=(p_o)*(v_o^2)*(d_o)/(sf_o); %Ox. weber no.
                        
                        Re_f=(p_f)*(v_f)*(d_f)/(vis_f); %Fuel Re. no.
                        Re_o=(p_o)*(v_o)*(d_o)/(vis_o); %Ox. Re. no.
                        
                        Ohn_f=sqrt(weber_f)/Re_f; %Fuel Ohnesorge number
                        Ohn_o=sqrt(weber_o)/Re_o; %Ox. Ohnesorge number
                        %% Optimisation 'if' loop
                        %These are the parameters set. The loop will break
                        %at the first possible iteration
                        if (d_P_f>=T_d_P_f-10 && d_P_f<=T_d_P_f+10) &&... %Set the calc. fuel pressure drop to within 5 PSI of desired pressure drop
                                (d_P_o>=T_d_P_o-10 && d_P_o<=T_d_P_o+10) && ... %Set the calc. ox. pressure drop to within 5 PSI of desired pressure drop
                                (o_rat_act>=o_rat-0.15 && o_rat_act<=o_rat+0.15) && ... %Set actual orifice ratio to within 15% of desires orifice ratio
                                (n_f<=400 && n_f>=50) && (n_o<=n_f+3 && n_o>=n_f-3) && ... %No. of fuel holes to be >50 and <100, and ox. fuel holes to be within 5 holes of the fuel no.
                                (d>=(d_f/2)+(d_o/2)+0.06) && ... %Set minimum distance between the hole edges to be 0.06'
                                (o_d_rat>=5 && o_d_rat<=7) && (f_d_rat>=5 && f_d_rat<=7) %Set distance ratio for fuel and ox. to be between 5 and 7
                            fprintf('PARAMETERS \n\n')
                            fprintf('Total fuel area = %4.3f in^2\n', A_f);
                            fprintf('Total no. fuel holes = %2.0f \n', n_f);
                            fprintf('Fuel hole diameter = %4.3f in \n', d_f);
                            fprintf('Fuel injection velocity = %4.3f in/sec \n', v_f);
                            fprintf('Fuel pressure drop = %4.2f psi \n', d_P_f);
                            fprintf('Fuel free stream length = %4.3f in \n', L_fs_f);
                            fprintf('Fuel Reynolds no. = %4.3f \n', Re_f);
                            fprintf('Fuel Ohnesorge no. = %4.3f \n\n', Ohn_f);
                            
                            fprintf('Total oxidiser area = %4.3f in^2\n', A_o);
                            fprintf('Total no. oxidiser holes = %2.0f \n', n_o);
                            fprintf('Oxidiser hole diameter = %4.3f in \n', d_o);
                            fprintf('Oxidiser injection velocity = %4.3f in/sec \n', v_o);
                            fprintf('Oxidiser pressure drop = %4.2f psi \n', d_P_o);
                            fprintf('Oxidiser free stream length = %4.3f in \n', L_fs_o);
                            fprintf('Oxidiser Reynolds no. = %4.3f \n', Re_o);
                            fprintf('Oxidiser Ohnesorge no. = %4.3f \n\n', Ohn_o);
                            
                            fprintf('Beta angle = %4.2f degrees\n', beta);
                            fprintf('Momentum ratio = %4.2f \n\n', R_m);
                            return
%                         end
                        end
                end
            end
        end
    end
end
















