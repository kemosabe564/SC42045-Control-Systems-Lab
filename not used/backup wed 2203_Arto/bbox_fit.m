%% Black box model estimation

Ts = 0.001;
input = u;
output = [xbeam' xpend'];
data = iddata(output,input,Ts);
data_e1 = iddata(xbeam(1:5000)',input(1:5000),Ts);
data_e2 = iddata(xpend(1:5000)',input(1:5000),Ts);
data_v1 = iddata(xbeam(5001:10000)',input(5001:10000),Ts);
data_v2 = iddata(xpend(5001:10000)',input(5001:10000),Ts);

%% Estimate model order and delay
nk1 = delayest(data(:,1));
nk2 = delayest(data(:,2));

NN = struc(1:40,1:40,1:40);
V1 = arxstruc(data_e1,data_v1,NN);
V2 = arxstruc(data_e2,data_v2,NN);
nn_aic1 = selstruc(V1,'AIC');
nn_aic2 = selstruc(V2,'AIC');
nn_mdl1 = selstruc(V1,'MDL');
nn_mdl2 = selstruc(V2,'MDL');
nn_01 = selstruc(V1,0);
nn_02 = selstruc(V2,0);

%%
arx1sys = arx(data(1:5000,1), [39 1 29],'Ts',Ts);
figure(1)
compare(data(1:5000,1),arx1sys)
arx2sys = arx(data(1:5000,2), [37 1 21],'Ts',Ts);
figure(2)
compare(data(1:5000,2),arx2sys)

%% Set model order and delay
%na = 3*eye(2);
na = [17 0;0 17];
%nb = 3*ones(2,1);
nb = [4;2];
%nc = 3*ones(2,1);
nc = [2;15];
%nd = 3*ones(2,1);
nd = [5;10];
%nf = 3*ones(2,1);
nf = [5;15];
%nk = 0*ones(2,1);
nk = [31; 22];



%% Estimate models
oeopt = oeOptions('InitialCondition','backcast');
arxsys = arx(data, [na nb nk],'Ts',Ts);
armaxsys = armax(data, [na nb nc nk],'Ts',Ts);
oesys = oe(data, [nb nf nk],'Ts',Ts,oeopt);
bjsys = bj(data, [nb nc nd nf nk],'Ts',Ts);

figure(3)
compare(data,arxsys,armaxsys,oesys,bjsys)
%compare(data,armaxsys)