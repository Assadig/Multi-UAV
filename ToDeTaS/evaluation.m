function fitness = evaluation(M, task, N, pop)

% fitness: the fitness of the population
% M: the number of the tasks
% task: the tasks of mobile users
% N: the nummber of UAVs
% pop: the population

H = 100;   % the altitude of each UAV
theta = pi / 4;   % the beamwidth of each directional antenna
k1 = 1e-27;   % the effective switched capacitance
k2 = 1e-28;   % the effective switched capacitance
v = 3;   % the positive constant
B = 1e6;   % the channel bandwidth
P = 1;   % the transmission power of each mobile device
B0 = 1.42e-4;   % the channel power gain at the reference distance
G0 = 2.2846;   % the positive constant
N0 = 1e-20;   % the noise power spectrum density
P0 = 1000;   % the hover power of each UAV
T_max = 1;   % the maximum time used to complete each task

x = reshape(task(1 : M)' * ones(1, N), 1, M * N);
y = reshape(task(M + 1 : 2 * M)' * ones(1, N), 1, M * N);
F = reshape(task(2 * M + 1 : 3 * M)' * ones(1, N), 1, M * N);
D = reshape(task(3 * M + 1 : end)' * ones(1, N), 1, M * N);

X = reshape(ones(M, 1) * pop(1 : N), 1, M * N);
Y = reshape(ones(M, 1) * pop(N + 1 : 2 * N), 1, M * N);

a = pop(2 * N + 1 : 2 * N + M * (N + 1));
f = pop(2 * N + M * (N + 1) + 1 : end);

r = B * log2(1 + P * B0 * G0 ./ (N0 * B * theta ^ 2 * (H ^ 2 + (x - X) .^ 2 + (y - Y) .^ 2)));

% Calculate the fitness of the population and the number of uncompleted tasks
f0 = sum(a(1 : M) * k1 .* f(1 : M) .^ (v - 1) .* F(1 : M)) + sum(a(M + 1 : end) * k2 .* f(M + 1 : end) .^ (v - 1) .* F) + sum(a(M + 1 : end) * P .* D ./ r) + N * P0 * T_max;
g = M - sum(a);

fitness = -[f0, g, f0 + g * 1e20];





