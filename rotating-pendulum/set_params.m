function [g, l_1, l_2, m_1, m_2, c_1_0, c_2_0, I_1_0, I_2_0, b_1_0, b_2_0, k_m_0, tau_e_0, P_1, P_2, P_3, g_1, g_2] ...
    = set_params(params)
    g = 9.81;
    l_1 = 0.1;
    l_2 = 0.1;
    m_1 = 0.125;
    m_2 = 0.05;
    
    c_1_0 = params(1);
    c_2_0 = params(2);
    I_1_0 = params(3);
    I_2_0 = params(4);
    b_1_0 = params(5);
    b_2_0 = params(6);
    k_m_0 = params(7);
    tau_e_0 = params(8);
    
    P_1 = m_1 * c_1_0 * c_1_0 + m_2 * l_1 * l_1 + I_1_0;
    P_2 = m_2 * c_2_0 * c_2_0 + I_2_0;
    P_3 = m_2 * l_1 * c_2_0;
    
    g_1 = (m_1 * c_1_0 + m_2 * l_1) * g;
    g_2 = m_2 * c_2_0 * g;
end
