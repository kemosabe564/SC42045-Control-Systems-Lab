%% observer K design - pole placement
 
Pole1 = -70;
Pole2 = -71;
Pole3 = -72;
Pole4 = -73;
Pole5 = -75;
J = 0.5*[Pole1 Pole2 Pole3 Pole4 Pole5];
clear Pole1 Pole2 Pole3 Pole4 Pole5

A_ = A';
B_ = C';
C_ = B';
D_ = D';
Ke = place(A_, B_, J)'; % Observer Gain

save('ObserverMatrix','Ke')

%% impulse response for obs

Ac = (A_ - B_*Ke');

G1 = ss(Ac, B_, C_, D_);

pole(G1)

figure;
impulse(G1, t)
