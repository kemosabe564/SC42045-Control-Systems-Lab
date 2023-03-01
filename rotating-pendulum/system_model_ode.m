function dydt = system_model_ode(t, theta)
  dydt(1) = theta(2);
  dydt(2) = theta(1)*theta(2)-2;
end