# Rotating Double Pendulum

This is an implementation of a control system towards a rotating double pendulum in the course CS42045. The expriment is done by MATLAB and Simulink with a real setup in DCSC lab, TU Delft, Netherlands

## The repository is organized as follows steps:

1. calibrate the sensor to obtain the desired measurement

2. bulid the nonlinear model based on the proviced equations

3. Since the parameters are incorrect, an optimization is conducted to find the optimal parameters by optimizing the error between real measurement and nonlinear model

4. Linearized the nonlinear system around operating points based on the parameters obtained from previous step

5. Instead of using the nonlinear model, a possible way is to do the black box estimation to get the linear model directly.

6. Some states's value can't be measured, an observer is designed to obtain those value and filter our the noise

7. A feedback controller is designed, both LQR and pole placement methods are used. The feedback controller works for all position.

8. A PID controller is only tried with the down/down position


