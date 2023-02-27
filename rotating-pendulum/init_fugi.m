fugiboard('CloseAll');
h=fugiboard('Open', 'Pendulum1');
h.WatchdogTimeout = 0.5;
fugiboard('SetParams', h);
