function af = greedy_algorithm(M, task, N, UAV)

% af: the offloading decision and the resource allocation
% M: the number of the tasks
% task: the tasks of mobile users
% N: the nummber of UAVs
% UAV: the deployment of UAVs

H = 100;   % the altitude of each UAV
theta = pi / 4;   % the beamwidth of each directional antenna
f_local_max = 8e8;   % the maximum computation resources each mobile device can provide
k1 = 1e-27;   % the effective switched capacitance
k2 = 1e-28;   % the effective switched capacitance
v = 3;   % the positive constant
B = 1e6;   % the channel bandwidth
P = 1;   % the transmission power of each mobile device
B0 = 1.42e-4;   % the channel power gain at the reference distance
G0 = 2.2846;   % the positive constant
N0 = 1e-20;   % the noise power spectrum density
n_max = 10;   % the maximum number of tasks each UAV can execute
T_max = 1;   % the maximum time used to complete each task

x = task(1 : M)' * ones(1, N);
y = task(M + 1 : 2 * M)' * ones(1, N);
F = task(2 * M + 1 : 3 * M)' * ones(1, N);
D = task(3 * M + 1 : end)' * ones(1, N);

X = ones(M, 1) * UAV(1 : N);
Y = ones(M, 1) * UAV(N + 1 : end);

d = sqrt((x - X) .^ 2 + (y - Y) .^ 2);
r = B * log2(1 + P * B0 * G0 ./ (N0 * B * theta ^ 2 * (H ^ 2 + d .^ 2)));

a_local = ones(M, 1);
a_UAV = ones(M, N);
a_UAV1 = zeros(M, N);
f_local = F(:, 1) / T_max;
f_UAV = F ./ (T_max - D ./ r + 1e-100);

a_local(f_local > f_local_max) = 0;
index = d > H * tan(theta);
a_UAV(index) = 0;

capacity = n_max * ones(1, N);

only_index = find(~a_local);

energy = P * D(only_index, :) ./ r(only_index, :) + k2 * f_UAV(only_index, :) .^ (v - 1) .* F(only_index, :);
energy(~logical(a_UAV(only_index, :))) = Inf;
number = sum(energy < Inf, 2);

number_min = min(number(number > 0));
while number_min > 0
    
    row = find(number == number_min, 1);
    [~, column] = min(energy(row, :));
    
    a_UAV(only_index(row), :) = 0;
    a_UAV(only_index(row), column) = 1;
    a_UAV1(only_index(row), column) = 1;
    energy(row, :) = Inf;
    
    capacity(column) = capacity(column) - 1;
    if capacity(column) == 0
        
        a_UAV(:, column) = 0;
        a_UAV(:, column) = a_UAV1(:, column);
        energy(:, column) = Inf;
        
    end
    number = sum(energy < Inf, 2);
    
    number_min = min(number(number > 0));
    
end

both_index = find(a_local);

energy = P * D(both_index, :) ./ r(both_index, :) + k2 * f_UAV(both_index, :) .^ (v - 1) .* F(both_index, :);
energy((k1 * f_local(both_index) .^ (v - 1) .* F(both_index, 1) - energy) <= 0) = Inf;
energy(~logical(a_UAV(both_index, :))) = Inf;
energy = [k1 * f_local(both_index) .^ (v - 1) .* F(both_index, 1), energy];
number = sum(energy < Inf, 2);
energy(find(number == 1), 1) = Inf;
a_UAV2 = a_UAV(both_index, :);
a_UAV2(energy(:, 2 : end) == Inf) = 0;
a_UAV(both_index, :) = a_UAV2;
number = sum(energy < Inf, 2);
number(number == 0) = Inf;
if isempty(max(number(number < Inf)))
    
    number1 = [];
    
elseif max(number(number < Inf)) == min(number(number < Inf))
    
    number1 = ones(size(number, 1), N);
    
else
    
    number1 = ((number - min(number(number < Inf))) / (max(number(number < Inf)) - min(number(number < Inf)))) * ones(1, N) + 0.1;
    
end
if isempty(max(energy(energy < Inf)))
    
    energy1 = [];
    
else
    
    energy1 = (energy(:, 2 : end) - min(energy(energy < Inf))) / (max(energy(energy < Inf)) - min(energy(energy < Inf))) + 0.1;
    
end
number_energy = number1 .* energy1;

number_energy_min = min(min(number_energy));
while number_energy_min < Inf
    
    [row, column] = find(number_energy == number_energy_min, 1);
    
    a_local(both_index(row)) = 0;
    a_UAV(both_index(row), :) = 0;
    a_UAV(both_index(row), column) = 1;
    a_UAV1(both_index(row), column) = 1;
    energy(row, :) = Inf;
    
    capacity(column) = capacity(column) - 1;
    if capacity(column) == 0
        
        a_UAV(:, column) = 0;
        a_UAV(:, column) = a_UAV1(:, column);
        energy(:, column + 1) = Inf;
        
    end
    number = sum(energy < Inf, 2);
    number(number == 0) = Inf;
    if isempty(max(number(number < Inf)))
        
        number1 = [];
        
    elseif max(number(number < Inf)) == min(number(number < Inf))
        
        number1 = ones(size(number, 1), N);
        
    else
        
        number1 = ((number - min(number(number < Inf))) / (max(number(number < Inf)) - min(number(number < Inf)))) * ones(1, N) + 0.1;
        
    end
    if isempty(max(energy(energy < Inf)))
        
        energy1 = [];
        
    else
        
        energy1 = (energy(:, 2 : end) - min(energy(energy < Inf))) / (max(energy(energy < Inf)) - min(energy(energy < Inf))) + 0.1;
        
    end
    number_energy = number1 .* energy1;
    
    number_energy_min = min(min(number_energy));
    
end

f_local(~logical(a_local)) = 0;
f_UAV(~logical(a_UAV)) = 0;

af = [reshape([a_local, a_UAV], 1, M * (N + 1)), reshape([f_local, f_UAV], 1, M * (N + 1))];
