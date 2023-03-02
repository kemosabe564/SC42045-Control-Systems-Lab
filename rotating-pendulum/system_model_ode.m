function dydt = system_model_ode(t, y, u, params)
    T = 0;
    dydt = zeros(4, 1);
    
%     params
    [g, l_1, l_2, m_1, m_2, c_1_0, c_2_0, I_1_0, I_2_0, b_1_0, b_2_0, k_m_0, tau_e_0, P_1, P_2, P_3, g_1, g_2] ...
    = set_params(params);

    theta_1 = y(1);
    theta_2 = y(2);
    omega_1 = y(3);
    omega_2 = y(4);
%     T = y(5);
    
    A1 = P_1 + P_2 + 2 * P_3 * cos(theta_2);
    A2 = P_2 + P_3 * cos(theta_2);
    A3 = P_2 + P_3 * cos(theta_2);
    A4 = P_2;

    B1 = b_1_0 - P_3 * omega_2 * sin(theta_2);
    B2 = -P_3 * (omega_1 + omega_2) * sin(theta_2);
    B3 = P_3 * omega_1 * sin(theta_2);
    B4 = b_2_0;

    C1 = -g_1 * sin(theta_1) - g_2 * sin(theta_1 + theta_2);
    C2 = -g_2 * sin(theta_1 + theta_2);

    d_omega_1 = ( A2 / A4 * (B3 * omega_1 + B4 * omega_2 + C2) - (B1 * omega_1 + B2 * omega_2 + C1 - T)) * A4 / (A1 * A4 - A2 * A3);
    d_omega_2 = -(A3 * d_omega_1 + B3 * omega_1 + B4 * omega_2 + C2) / A4;
    
%     d_T = (k_m_0 * u - T) / tau_e_0;

    dydt(1) = omega_1;
    dydt(2) = omega_2;
    dydt(3) = d_omega_1;
    dydt(4) = d_omega_2;
%     dydt(5) = d_T;
end