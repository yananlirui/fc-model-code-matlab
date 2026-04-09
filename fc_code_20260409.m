

% Code developed for Li et al. "Exploring the roles of facility-based isolation
% in early response to potential future pandemics: A modelling study "


% Start and initialization

clear all;                    % Clear workspace to avoid variable conflicts       
clc;                          % Clear command window for clean output
rng(192);                     % Set random seed for reproducible results
start_time = tic;             % Display current timestamp to mark run start

% Variable : [name, baseline, lower, upper, distribution, source, note]
% source: 'literature' = from published data, 'pct_variation' = baseline ± pct assumption,  'calculated' = 'derived' 
% R0    =	'Basic reproduction number'
% ps    =	'Proportion of severe and dead case, %'
% pa    =	'Ascertained proportion'
% k     =	'Relative transmissibility in incubation period'
% 1/δ   =	'Mean incubation period, days'
% 1/γ   =	'Mean duration of infectiousness, days'
% 1/ϕ_H =	'Mean time from symptom onset to admission, days'
% 1/τ_m =	'Mean duration from admission to resolved, days'
% 1/τ_p =	'Mean duration from admission to severe stage, days'
% 1/τ_h =	'Mean duration from severe stage to resolved, days'
% T1    =	'Mean duration from symptom onset to death, days'
% T2    =	'Mean duration from symptom onset to recovery (severe cases), days'
% T3    =	'Mean duration from symptom onset to recovery (mild cases), days'
% P1    =	'Case fatality rate, %'
% P2    =	'Proportion of severe non-fatal case, %'
% P3    =	'Proportion of non-severe case, %'
% D1    =	'Mean duration from admission to death, days'
% D2    =	'Mean duration of admission to recovery of severe cases, days'
% D3    =	'Mean duration from symptom onset to resolved across mixed mild and severe cases, days'
% D4    =	'Mean duration from symptoms onset to severe stage, days'

% Virus 1 = 'Flu'
v1 = {
    'R0',       1.31,  1.25,  1.38,  'PERT',      'literature',    'Tuite et al 2010';                  % Checked
    'ps',       0.045, 0.038, 0.052, 'Beta',      'literature',    'Tuite et al 2010';                  % Checked
    'pa',       0.187, 0.013, 0.326, 'Beta',      'literature',    'Meadows et al 2020';                % Checked
    'k',        0,     0,     0,     'None',      'literature',    'ECDC, 2009';                        % Checked
    '1/delta',  2.62,  2.28,  3.12,  'Lognormal', 'literature',    'Tuite et al 2010';                  % Checked
    '1/gamma',  NaN,   NaN,   NaN,   'None',      'calculated',    'T1 .* P1 + T2 .* P2 + T3 .* P3';    % Checked
    '1/phi_H',  4,     3.44,  4.56,  'Lognormal', 'literature',    'Kumar et al 2009';                  % Checked
    '1/tau_m',  3.5,   NaN,   NaN,   'PERT',      'pct_variation', 'Balcan et al 2009';                 % Checked
    '1/tau_p',  1.5,   NaN,   NaN,   'PERT',      'pct_variation', 'Balcan et al 2009';                 % Checked
    '1/tau_h',  NaN,   NaN,   NaN,   'None',      'calculated',    '(T1 .* P1 + T2 .* P2)./(P1 + P2) - 1/phi_H - 1/tau_p'; % Checked
    'T1',       NaN,   NaN,   NaN,   'None',      'calculated',    'D1 + 1/phi_H';                      % Checked
    'T2',       NaN,   NaN,   NaN,   'None',      'calculated',    'D2 + 1/phi_H';                      % Checked
    'T3',       NaN,   NaN,   NaN,   'None',      'calculated',    '1/tau_m + 1/phi_H';                 % Checked
    'P1',       0.003, 0.001, 0.005, 'Beta',      'literature',    'Tuite et al 2010';                  % Checked
    'P2',       NaN,   NaN,   NaN,   'None',      'calculated',    'ps - P1';                           % Checked
    'P3',       NaN,   NaN,   NaN,   'None',      'calculated',    '1 - ps';                            % Checked
    'D1',       14.0,  12.43, 15.57, 'Lognormal', 'literature',    'Kumar et al 2009';                  % Checked
    'D2',       6.5,   NaN,   NaN,   'PERT',      'pct_variation', 'Balcan et al 2009';                 % Checked
    'D3',       NaN,   NaN,   NaN,   'None',      'None',          'None';                              % Checked
    'D4',       NaN,   NaN,   NaN,   'None',      'None',          'None'                               % Checked
};

% Virus 2 = 'Ebola'
v2 = {
    'R0',       1.95,  1.74,  2.15,  'PERT',      'literature',    'Muzembo et al 2024';                % Checked
    'ps',       NaN,   NaN,   NaN,   'None',      'calculated',    'P1 + P2';                           % Checked
    'pa',       0.6,   0.4,   0.8,   'Beta',      'literature',    'Kucharski et al 2015';              % Checked
    'k',        0,     0,     0,     'None',      'literature',    'Malvy et al 2019';                  % Checked   
    '1/delta',  9.7,   8.83,  10.57, 'Lognormal', 'literature',    'WHO team 2014';                     % Checked
    '1/gamma',  NaN,   NaN,   NaN,   'None',      'calculated',    'T1 .* P1 + T2 .* P2 + T3 .* P3';    % Checked
    '1/phi_H',  3.2,   1.8,   4.6,   'Lognormal', 'literature',    'Kucharski et al 2015';              % Checked
    '1/tau_m',  NaN,   NaN,   NaN,   'None',      'calculated',    'T3 - 1/phi_H';                      % Checked
    '1/tau_p',  NaN,   NaN,   NaN,   'None',      'calculated',    'D4 - 1/phi_H';                      % Checked
    '1/tau_h',  NaN,   NaN,   NaN,   'None',      'calculated',    '(T1 .* P1 + T2 .* P2)./(P1 + P2) - 1/phi_H - 1/tau_p'; % Checked
    'T1',       7.5,   6.95,  8.05,  'Lognormal', 'literature',    'WHO team 2014';                     % Checked
    'T2',       NaN,   NaN,   NaN,   'None',      'calculated',    '(D3 .*(P2 + P3) - T3 .* P3) ./ P2'; % Checked
    'T3',       12,    NaN,   NaN,   'PERT',      'pct_variation', 'Malvy et al 2014'                   % Checked
    'P1',       0.708, 0.686, 0.728, 'Beta',      'literature',    'WHO team 2014';                     % Checked
    'P2',       NaN,   NaN,   NaN,   'None',      'calculated',    '1 - P1 - P3';                       % Checked
    'P3',       0.111, NaN,   NaN,   'PERT',      'pct_variation', 'Timothy et al 2019';                % Checked
    'D1',       NaN,   NaN,   NaN,   'None',      'None',          'None';                              % Checked
    'D2',       NaN,   NaN,   NaN,   'None',      'None',          'None';                              % Checked
    'D3',       16.4,  15.62, 17.18, 'Lognormal', 'literature',    'WHO team 2014';                     % Checked
    'D4',       7,     NaN,   NaN,   'PERT',      'pct_variation', 'Malvy et al 2014'                   % Checked
};

% Virus 3 = 'SARS2'
v3 = {
    'R0',       2.68,  2.47,  2.86,  'PERT',      'literature',    'Wu et al 2020';                     % Checked
    'ps',       NaN,   NaN,   NaN,   'None',      'calculated',    'P1 + P2';                           % Checked
    'pa',       0.23,  0.14,  0.42,  'Beta',      'literature',    'Hao et al 2020';                    % Checked
    'k',        0.125, 0,     0.25,  'Uniform',   'literature',    'Prem et al 2020';                   % Checked   
    '1/delta',  6.4,   5.6,   7.7,   'Lognormal', 'literature',    'Backer et al 2020';                 % Checked
    '1/gamma',  NaN,   NaN,   NaN,   'None',      'calculated',    'T1 .* P1 + T2 .* P2 + T3 .* P3';    % Checked
    '1/phi_H',  6.5,   6.15,  6.85,  'Lognormal', 'literature',    'Kraemer et al 2020';                % Checked
    '1/tau_m',  NaN,   NaN,   NaN,   'None',      'calculated',    'T3 - 1/phi_H';                      % Checked
    '1/tau_p',  NaN,   NaN,   NaN,   'None',      'calculated',    'D4 - 1/phi_H';                      % Checked
    '1/tau_h',  NaN,   NaN,   NaN,   'None',      'calculated',    '(T1 .* P1 + T2 .* P2)./(P1 + P2) - 1/phi_H - 1/tau_p'; % Checked
    'T1',       24.0,  NaN,   NaN,   'PERT',      'pct_variation', 'Reddy et al 2020';                  % Checked
    'T2',       20.6,  NaN,   NaN,   'PERT',      'pct_variation', 'Reddy et al 2020';                  % Checked
    'T3',       10.0,  NaN,   NaN,   'PERT',      'pct_variation', 'Reddy et al 2020';                  % Checked
    'P1',       0.038, NaN,   NaN,   'PERT',      'pct_variation', 'WHO-China Joint Mission 2020';      % Checked
    'P2',       0.162, NaN,   NaN,   'PERT',      'pct_variation', 'WHO-China Joint Mission 2020';      % Checked
    'P3',       NaN,   NaN,   NaN,   'None',      'calculated',    '1 - P1 - P2';                       % Checked
    'D1',       NaN,   NaN,   NaN,   'None',      'None',          'None';                              % Checked
    'D2',       NaN,   NaN,   NaN,   'None',      'None',          'None';                              % Checked
    'D3',       NaN,   NaN,   NaN,   'None',      'None',          'None';                              % Checked
    'D4',       8.0,   7.48,  8.52,  'Lognormal', 'literature',    'Sisay et al 2022'                   % Checked
};

% Virus 4 = 'SARS1'
v4 = {
    'R0',       2.70,  2.20,  3.70,  'PERT',      'literature',    'Riley et al 2003';                  % Checked
    'ps',       NaN,   NaN,   NaN,   'None',      'calculated',    'P1 + P2';                           % Checked
    'pa',       0.6,   0.4,   0.8,   'Beta',      'assumption',    'Same as Ebola';                     % Checked
    'k',        0.05,  0,     0.10,  'Uniform',   'literature',    'Lloyd et al 2003';                  % Checked   
    '1/delta',  6.37,  5.29,  7.75,  'Lognormal', 'literature',    'Donnelly et al 2004';               % Checked
    '1/gamma',  NaN,   NaN,   NaN,   'None',      'calculated',    'T1 .* P1 + T2 .* P2 + T3 .* P3';    % Checked
    '1/phi_H',  3.45,  2.0,   4.9,   'Lognormal', 'literature',    'Anderson et al 2004';               % Checked
    '1/tau_m',  NaN,   NaN,   NaN,   'None',      'calculated',    'T3 - 1/phi_H';                      % Checked
    '1/tau_p',  3.0,   2.0,   4.0,   'Lognormal', 'literature',    'Tsang et al 2004';                  % Checked
    '1/tau_h',  NaN,   NaN,   NaN,   'None',      'calculated',    '(T1 .* P1 + T2 .* P2)./(P1 + P2) - 1/phi_H - 1/tau_p'; % Checked
    'T1',       23.7,  22.0,  25.3,  'Lognormal', 'literature',    'Leung et al 2004';                  % Checked
    'T2',       NaN,   NaN,   NaN,   'None',      'calculated',    '(D3 .*(P2 + P3) - T3 .* P3) ./ P2'; % Checked
    'T3',       14.0,  NaN,   NaN,   'PERT',      'pct_variation', 'Schneider et al 2012';              % Checked
    'P1',       0.172, NaN,   NaN,   'PERT',      'pct_variation', 'Leung et al 2004';                  % Checked
    'P2',       NaN,   NaN,   NaN,   'None',      'calculated',    '1 - P1 - P3';                       % Checked
    'P3',       0.36,  NaN,   NaN,   'PERT',      'pct_variation', 'Tsui et al 2003';                   % Checked
    'D1',       NaN,   NaN,   NaN,   'None',      'None',          'None';                              % Checked
    'D2',       NaN,   NaN,   NaN,   'None',      'None',          'None';                              % Checked 
    'D3',       26.5,  25.8,  27.2,  'Lognormal', 'literature',    'Leung et al 2004';                  % Checked
    'D4',       NaN,   NaN,   NaN,   'None',      'None',          'None'                               % Checked 
};

% ========== Generate or Load Parameter Samples ==========
% Get the folder where the current code file is located
code_folder = fileparts(mfilename('fullpath'));

% Check for existing parameter sample files
mat_files = dir(fullfile(code_folder, 'fc_model_parameter_samples_*.mat'));

if ~isempty(mat_files)
    % Load the most recent existing file
    [~, idx] = max([mat_files.datenum]);
    load(fullfile(code_folder, mat_files(idx).name));
    fprintf('Loaded existing parameter samples from: %s\n', mat_files(idx).name);
else
    % Generate new parameter samples
    NS            = 10000;                               % Number of samples
    pct_variation = 0.20;                                % Variation for PERT distributions
    viruses       = {v1, v2, v3, v4};                    % Virus parameter data
    virus_names   = {'Flu', 'Ebola', 'SARS2', 'SARS1'};  % Virus names
    
    fprintf('Generating new parameter samples for %d viruses with NS=%d...\n', length(viruses), NS);
    Par_profile = sample_parameters(viruses, virus_names, NS, pct_variation);
    
    baseline_matrix = [Par_profile{1}.baseline(1:10), ...
                       Par_profile{2}.baseline(1:10), ...
                       Par_profile{3}.baseline(1:10), ...
                       Par_profile{4}.baseline(1:10)];
    
    HybridVirus = produce_hybrid_virus(baseline_matrix, virus_names, NS); % Create hybrid virus
    Par_profile{5} = HybridVirus;                                         % Store in Par_profile{5}
    
    % Save results to file with date stamp
    output_file = fullfile(code_folder, ['fc_model_parameter_samples_' char(datetime('now', 'Format', 'yyyyMMdd')) '.mat']);
    save(output_file, 'Par_profile', 'NS', 'pct_variation', 'virus_names', 'viruses');
    fprintf('Saved new parameter samples to: %s\n', output_file);
end

% Display sampling results
for i = 1:length(Par_profile)
    fprintf('\n=== %s ===\n', Par_profile{i}.name);
    disp(Par_profile{i});
end

%%
% ========== Model Simulation ==========
% Set flags to control execution
RUN_SIMULATION  = false;  % Set to true to run simulation, false to load existing results
RUN_SENSITIVITY = false;  % Set to true to run sensitivity analysis, false to load existing results
RUN_UNKNOWNVIRU = true;   % Set to true to run UNKNOWNVIRU, false to load existing results

% Common simulation parameters for all models
Pop   = 100000;               % Total population
dt    = 1;                    % Time step (days)
Ini_E = Pop * 0.00020;        % Initial exposed individuals (0.02% of population)
t     = 0:100;                % Time horizon (101 days)
y0    = [Pop - Ini_E, Ini_E, 0, 0, 0, 0, 0, 0, 0, 0, 0]; % [S,E,I1,I2,I3,H,Q,R,D,V,C]
Cap_H = [57, 140, 283, 446, 736];   % Traditional hospital capacity set

% ========== Main Simulation for Figure 3 ==========
% Simulates 4 viruses across 5 hospital capacities and various FC proportions
if RUN_SIMULATION
    fc_impl_prop = [0:0.04:0.48, 0.5];     % FC capacity as proportion of traditional hospital
    Fig3_results_cell = cell(4, 5);        % Store results: {virus, capacity}
    
    % Loop over 4 viruses: 1=Flu, 2=Ebola, 3=SARS2, 4=SARS1
    for virus = 1:4
        Par_sam0 = Par_profile{virus}.samples;   % Get parameter samples for current virus
        
        % Loop over 5 hospital capacities
        for th = 1:5
            H_cap = Cap_H(th) * (1 - 0.714);     % Traditional hospital capacity after reduction
            Results = zeros(length(fc_impl_prop), 2); % [probability_exceedance, mean_infected]
            
            % Loop over different FC capacity proportions
            for i = 1:length(fc_impl_prop)
                F_cap = Cap_H(th) * fc_impl_prop(i);   % Field hospital capacity
                XH1 = zeros(NS, 1);    % Track if capacity is exceeded
                XH2 = zeros(NS, 1);    % Track total infected population
                
                % Parallel simulation over parameter sets
                parfor Pnum = 1:NS
                    Par_bas0 = Par_sam0(Pnum, 1:10)';   % Get one parameter set
                    X1 = fc_model(t, y0, dt, H_cap, F_cap, Par_bas0);   % Run simulation
                    XH1(Pnum) = any(sum(X1(:, 8:10), 2) >= H_cap);   % Check capacity exceedance
                    XH2(Pnum) = Pop - X1(end, 1);   % Total infected at end
                end
                
                % Store results: probability of exceedance and mean infected
                Results(i, :) = [mean(XH1), mean(XH2)];
            end
            Fig3_results_cell{virus, th} = Results;
            fprintf('Virus %d, capacity %d done\n', virus, th);
        end
    end
    
    % Save simulation results with date stamp
    save(fullfile(code_folder, ['Fig3_results_' datestr(now, 'yyyymmdd') '.mat']), 'Fig3_results_cell');
    fprintf('Simulation results saved\n');
    
else
    % Load most recent existing simulation results
    mat_files = dir(fullfile(code_folder, 'Fig3_results_*.mat'));
    if ~isempty(mat_files)
        [~, idx] = max([mat_files.datenum]);
        load(fullfile(code_folder, mat_files(idx).name));
        fprintf('Loaded simulation results from: %s\n', mat_files(idx).name);
    else
        error('No simulation results found. Set RUN_SIMULATION = true to run first.');
    end
end


% ========== Sensitivity Analysis for Figure 5 ==========
% Analyzes sensitivity to pa (proportion of severe cases) and time to seek care (1/phi_H)
if RUN_SENSITIVITY
    pa_range     = 0:0.05:1;        % Proportion of severe cases (baseline=0.23)
    t_care_range = 1:0.5:7;         % Time from onset to seeking care (1/phi_H), days (baseline=6.5)
    
    % Fixed parameters
    H_cap    = Cap_H(3) * (1 - 0.714);   % Traditional hospital capacity after reduction
    F_cap    = Cap_H(3) * 0.5;           % Field hospital capacity (50% of traditional)
    Par_sam0 = Par_profile{3}.samples;   % Parameter samples for SARS2
    
    % Initialize results
    prob_exceed = zeros(length(pa_range), length(t_care_range));
    
    fprintf('Sensitivity: %d pa × %d t_care = %d combinations\n', ...
            length(pa_range), length(t_care_range), length(pa_range)*length(t_care_range));
    
    for i_pa = 1:length(pa_range)
        pa = pa_range(i_pa);
        
        for i_tc = 1:length(t_care_range)
            t_care = t_care_range(i_tc);   % Time from onset to seeking care (1/phi_H)
            
            XH1 = zeros(NS, 1);
            parfor Pnum = 1:NS
                Par_bas0 = Par_sam0(Pnum, 1:10)';
                T1 = Par_sam0(Pnum, 11);
                T2 = Par_sam0(Pnum, 12);
                T3 = Par_sam0(Pnum, 13);
                P1 = Par_sam0(Pnum, 14);
                P2 = Par_sam0(Pnum, 15);
                D4 = Par_sam0(Pnum, 20);
                
                tau_m = T3 - t_care;
                tau_p = D4 - t_care;
                tau_h = (T1*P1 + T2*P2)/(P1 + P2) - t_care - tau_p;
                
                Par_bas0([3, 7:10]) = [pa, t_care, tau_m, tau_p, tau_h];
                
                X1 = fc_model(t, y0, dt, H_cap, F_cap, Par_bas0);
                XH1(Pnum) = any(sum(X1(:, 8:10), 2) >= H_cap);
            end
            
            prob_exceed(i_pa, i_tc) = mean(XH1);
        end
        fprintf('pa = %.2f done\n', pa);
    end
    
    save(fullfile(code_folder, ['Fig5_results_' datestr(now, 'yyyymmdd') '.mat']), ...
         'prob_exceed', 'pa_range', 't_care_range');
    fprintf('Sensitivity results saved\n');
    
else
    mat_files = dir(fullfile(code_folder, 'Fig5_results_*.mat'));
    if ~isempty(mat_files)
        [~, idx] = max([mat_files.datenum]);
        load(fullfile(code_folder, mat_files(idx).name));
        fprintf('Loaded: %s\n', mat_files(idx).name);
    end
end

% ========== RUN_UNKNOWNVIRU for Figure S2 ==========
% Analyzes unknown virus scenarios: varying R0 (1.25 to 3.70) and ps (3.8% to 96.7%)
if RUN_UNKNOWNVIRU
    R0_range  = [1.25, 3.70];        % R0 range (baseline varies)
    ps_range  = [0.038, 0.967];      % ps range (3.8% to 96.7%)
    
    % Create parameter grids (10 × 10)
    R0_values = linspace(R0_range(1), R0_range(2), 10);   % 10 R0 values
    ps_values = linspace(ps_range(1), ps_range(2), 10);   % 10 ps values
    
    % Fixed parameters
    H_cap = Cap_H(3) * (1 - 0.714);   % Traditional hospital capacity after reduction
    
    % Two FC capacity scenarios
    fc_props = [0, 0.5];              % FC capacity proportions (0% and 50%)
    
    % Initialize results cell: {fc_prop_index} -> matrix
    FigS2_results = cell(length(fc_props), 1);
    
    for i_fc = 1:length(fc_props)
        F_cap = Cap_H(3) * fc_props(i_fc);   % Field hospital capacity
        prob_exceed = zeros(length(R0_values), length(ps_values));
        
        fprintf('FC proportion = %.0f%%: %d R0 × %d ps = %d combinations\n', ...
                fc_props(i_fc)*100, length(R0_values), length(ps_values), ...
                length(R0_values)*length(ps_values));
        
        for i_R0 = 1:length(R0_values)
            R0 = R0_values(i_R0);
            
            for i_ps = 1:length(ps_values)
                ps = ps_values(i_ps);
                
                XH1 = zeros(NS, 1);
                parfor Pnum = 1:NS
                    Par_bas0 = Par_profile{3}.samples(Pnum, 1:10)';
                    
                    % Update R0 and ps
                    Par_bas0(1) = R0;      % R0
                    Par_bas0(2) = ps;      % ps (proportion of asymptomatic)
                    
                    X1 = fc_model(t, y0, dt, H_cap, F_cap, Par_bas0);
                    XH1(Pnum) = any(sum(X1(:, 8:10), 2) >= H_cap);
                end
                
                prob_exceed(i_R0, i_ps) = mean(XH1);
            end
            fprintf('  R0 = %.2f done\n', R0);
        end
        
        FigS2_results{i_fc} = prob_exceed;
        fprintf('FC proportion = %.0f%% completed\n\n', fc_props(i_fc)*100);
    end
    
    % Save results with consistent naming
    save(fullfile(code_folder, ['FigS2_results_' datestr(now, 'yyyymmdd') '.mat']), ...
         'FigS2_results', 'R0_values', 'ps_values', 'fc_props');
    fprintf('FigS2 results saved to: %s\n', fullfile(code_folder, ['FigS2_results_' datestr(now, 'yyyymmdd') '.mat']));
    
else
    % Load existing results
    mat_files = dir(fullfile(code_folder, 'FigS2_results_*.mat'));
    if ~isempty(mat_files)
        [~, idx] = max([mat_files.datenum]);
        load(fullfile(code_folder, mat_files(idx).name));
        fprintf('Loaded: %s\n', mat_files(idx).name);
    else
        fprintf('No FigS2 results found. Set RUN_UNKNOWNVIRU = true to run analysis.\n');
    end
end


%% NS = 200;
% load Par_20250519_1bas; % Previous baseline parameters
% load Par_20250519_2sam; % Previous baseline parameters

% fig_S1 = plot_hybrid_virus_histograms(HybridVirus);
% set(fig_S1, 'Units', 'inches', 'PaperPosition', [0 0 10 6]);
% saveas(fig_S1, fullfile(code_folder, 'Hybrid_Virus_Histograms.png'));
fig3 = plot_capacity_exceedance(Fig3_results_cell);
fig4 = plot_overload_probability_bars(Fig3_results_cell);


%%
% ========== Plot Figure 5: Sensitivity Analysis Heatmap ==========
% Plot probability of hospital capacity exceedance as function of pa and t_care

% Load results if not already in workspace
if ~exist('prob_exceed', 'var') || ~exist('pa_range', 'var') || ~exist('t_care_range', 'var')
    mat_files = dir(fullfile(code_folder, 'Fig5_results_*.mat'));
    if ~isempty(mat_files)
        [~, idx] = max([mat_files.datenum]);
        load(fullfile(code_folder, mat_files(idx).name));
        fprintf('Loaded: %s\n', mat_files(idx).name);
    else
        error('No Fig5 results found. Set RUN_SENSITIVITY = true to run first.');
    end
end

% Convert probability to percentage
prob_percent = prob_exceed * 100;

% Baseline parameters
pa_baseline = 0.23;
t_care_baseline = 6.5;

% Find baseline indices
[~, idx_pa] = min(abs(pa_range - pa_baseline));
[~, idx_tc] = min(abs(t_care_range - t_care_baseline));
baseline_value = prob_percent(idx_pa, idx_tc);

% Create figure
figure('Position', [300, 100, 1000, 900]);

% Plot filled contour
contourf(pa_range, t_care_range, prob_percent', 20, 'LineColor', 'none');
hold on;

% Add contour lines with labels
[M, c] = contour(pa_range, t_care_range, prob_percent', [10, 30, 50, 70, 90], ...
                 'ShowText', 'on', 'LineColor', 'k', 'LineWidth', 0.8);
clabel(M, c, 'FontSize', 10, 'Color', 'k');

% Add 50% contour line in red
contour(pa_range, t_care_range, prob_percent', [50, 50], ...
        'LineColor', 'r', 'LineWidth', 2);

% Mark baseline point
plot(pa_baseline, t_care_baseline, 'ko', 'MarkerSize', 10, 'LineWidth', 2, 'MarkerFaceColor', 'w');
plot(pa_baseline, t_care_baseline, 'k+', 'MarkerSize', 6, 'LineWidth', 1.5);

% Colorbar
colormap(parula);
caxis([0, 100]);
bar_c = colorbar;
ylabel(bar_c, 'Probability of capacity exceedance (%)', 'FontSize', 11);
set(bar_c, 'FontSize', 10, 'FontName', 'Times New Roman');

% Labels and title
xlabel('p_a (Proportion of cases who are eventually ascertained)', 'FontSize', 12);
ylabel('t_{care} (Time from onset to seeking care, days)', 'FontSize', 12);
title('Figure 5: Sensitivity Analysis of Hospital Capacity Exceedance', 'FontSize', 13, 'FontWeight', 'bold');

% Axis settings
set(gca, 'FontSize', 11, 'FontName', 'Times New Roman');
set(gca, 'YDir', 'normal');
xlim([min(pa_range), max(pa_range)]);
ylim([min(t_care_range), max(t_care_range)]);
axis square;

% Add baseline annotation
text(pa_baseline + 0.05, t_care_baseline + 0.3, ...
     sprintf('Baseline\np_a=%.2f\nt_{care}=%.1f\nP=%.1f%%', ...
     pa_baseline, t_care_baseline, baseline_value), ...
     'FontSize', 9, 'BackgroundColor', 'w', 'EdgeColor', 'k');

% Print statistics
fprintf('\n========== Fig5 Results Summary ==========\n');
fprintf('Parameter ranges:\n');
fprintf('  p_a: [%.2f, %.2f] (baseline: %.2f)\n', pa_range(1), pa_range(end), pa_baseline);
fprintf('  t_care: [%.1f, %.1f] days (baseline: %.1f)\n', t_care_range(1), t_care_range(end), t_care_baseline);
fprintf('\nProbability of exceedance:\n');
fprintf('  Range: [%.1f%%, %.1f%%]\n', min(prob_percent(:)), max(prob_percent(:)));
fprintf('  Baseline: %.1f%%\n', baseline_value);
fprintf('  Mean: %.1f%%\n', mean(prob_percent(:)));

%%
% ========== Plot Figure S2: Unknown Virus Analysis ==========
% Plot probability of hospital capacity exceedance for unknown virus
% Two scenarios: FC = 0% and FC = 50%

% Load results if not already in workspace
if ~exist('FigS2_results', 'var') || ~exist('R0_values', 'var') || ~exist('ps_values', 'var')
    mat_files = dir(fullfile(code_folder, 'FigS2_results_*.mat'));
    if ~isempty(mat_files)
        [~, idx] = max([mat_files.datenum]);
        load(fullfile(code_folder, mat_files(idx).name));
        fprintf('Loaded: %s\n', mat_files(idx).name);
    else
        error('No FigS2 results found.');
    end
end

load FigS2_results_20260409
% Convert probability to percentage
prob1 = FigS2_results{1} * 100;  % FC = 0%
prob2 = FigS2_results{2} * 100;  % FC = 50%

% Create figure
figure('Position', [100, 300, 1400, 620]);

% Subplot 1: FC = 0%
subplot(1, 2, 1);
contourf(R0_values, ps_values, prob1', 20, 'LineColor', 'none');
hold on;
[M, c] = contour(R0_values, ps_values, prob1', [10, 30, 50, 70, 90], ...
                 'ShowText', 'on', 'LineColor', 'k', 'LineWidth', 0.5);
clabel(M, c, 'FontSize', 9, 'Color', 'k');
% Add 50% contour line in red
contour(R0_values, ps_values, prob1', [50, 50], ...
        'LineColor', 'r', 'LineWidth', 2);
colormap(parula);
caxis([0, 100]);
xlabel('Transmissibility (R_0)', 'FontSize', 12);
ylabel('Proportion of severe cases (p_s)', 'FontSize', 12);
title('(a) Field Hospital Capacity = 0%', 'FontSize', 12);
set(gca, 'FontSize', 11, 'FontName', 'Times New Roman');
set(gca, 'YDir', 'normal');
axis square;
xlim([min(R0_values), max(R0_values)]);
ylim([min(ps_values), max(ps_values)]);

% Subplot 2: FC = 50%
subplot(1, 2, 2);
contourf(R0_values, ps_values, prob2', 20, 'LineColor', 'none');
hold on;
[M, c] = contour(R0_values, ps_values, prob2', [10, 30, 50, 70, 90], ...
                 'ShowText', 'on', 'LineColor', 'k', 'LineWidth', 0.5);
clabel(M, c, 'FontSize', 9, 'Color', 'k');
% Add 50% contour line in red
contour(R0_values, ps_values, prob2', [50, 50], ...
        'LineColor', 'r', 'LineWidth', 2);
colormap(parula);
caxis([0, 100]);
xlabel('Transmissibility (R_0)', 'FontSize', 12);
ylabel('Proportion of asymptomatic cases (p_s)', 'FontSize', 12);
title('(b) Field Hospital Capacity = 50%', 'FontSize', 12);
set(gca, 'FontSize', 11, 'FontName', 'Times New Roman');
set(gca, 'YDir', 'normal');
axis square;
xlim([min(R0_values), max(R0_values)]);
ylim([min(ps_values), max(ps_values)]);

% Add colorbar
bar_c = colorbar;
set(bar_c, 'Position', [0.92, 0.15, 0.016, 0.7]);
set(bar_c, 'FontSize', 10, 'FontName', 'Times New Roman');
ylabel(bar_c, 'Probability of capacity exceedance (%)', 'FontSize', 10);

% Add overall title
sgtitle('Figure S2: Hospital Capacity Exceedance Probability for Unknown Virus', ...
        'FontSize', 13, 'FontWeight', 'bold');

% Print statistics
fprintf('\n========== FigS2 Results Summary ==========\n');
fprintf('Parameter ranges:\n');
fprintf('  R0: [%.2f, %.2f]\n', R0_values(1), R0_values(end));
fprintf('  ps: [%.1f%%, %.1f%%]\n', ps_values(1)*100, ps_values(end)*100);
fprintf('\nFC = 0%% (No field hospital):\n');
fprintf('  Probability range: [%.1f%%, %.1f%%]\n', min(prob1(:)), max(prob1(:)));
fprintf('\nFC = 50%% (With field hospital):\n');
fprintf('  Probability range: [%.1f%%, %.1f%%]\n', min(prob2(:)), max(prob2(:)));
%%
% param_names = {'R_0', 'p_a', 'k', '1/\delta', '1/\gamma', ...
%                '1/\phi_H', '1/\tau_m', '1/\tau_p', '1/\tau_h', 'p_s'};
% 
% figure(1);
% clf;
% set(gcf, 'Position', [100, 100, 1200, 800], ...
%          'Name', 'Figure 1: Distribution of 10 Parameters (5000 Samples)', ...
%          'NumberTitle', 'on');
% 
% for param_idx = 1:10
%     subplot(2, 5, param_idx);
% 
%     param_values = Par_sam0(param_idx, :);
% 
%     histogram(param_values, 30, 'FaceColor', [0.3, 0.6, 0.9], 'EdgeColor', 'k');
% 
%     hold on;
%     mean_val = mean(param_values);
%     median_val = median(param_values);
%     xline(mean_val, 'r-', 'LineWidth', 1.5);
%     xline(median_val, 'b--', 'LineWidth', 1.5);
%     hold off;
% 
%     % 标题：参数名称 + 均值
%     title(sprintf('%s\nmean=%.3f', param_names{param_idx}, mean_val), ...
%           'FontSize', 10, 'FontWeight', 'bold');
%     xlabel('Value', 'FontSize', 8);
%     ylabel('Frequency', 'FontSize', 8);
%     grid on;
% end
% 
% sgtitle('Distribution of 10 Parameters (5000 Samples Each)', 'FontSize', 14);
% Fig3
% load Par_20250507_1bas;Fig3_results=cell(1,4);NS=5000;itv=10;CF=linspace(0,0.5,itv);
% Cap_H={linspace(0,40,itv);linspace(0,40,itv);linspace(0,800,itv);linspace(0,100,itv)};
% for virus=1:4
%     H_capv=Cap_H{virus};Results=zeros(length(H_capv),length(CF),6);
%     for i=1:length(H_capv)
%         for j=1:length(CF)
%             XH1=zeros(NS,1);XH2=zeros(NS,1);
%             parfor Pnum=1:NS
%                 X1=fcfun2_model(t,y0,dt,H_capv(i),H_capv(i)*CF(j),Par_bas(:,virus));
%                 XH1(Pnum)=any(sum(X1(:,8:10),2)>=H_capv(i));XH2(Pnum)=(Pop-X1(end,1));    
%             end
%             p=mean(XH1);SE=sqrt(p*(1-p)/NS);CI1=p-1.96*SE;CI2=p+1.96*SE;
%             Results(i,j,:)=[p CI1 CI2 mean(XH2) prctile(XH2,[2.5,97.5])];
%         end
%     end
%     Fig3_results{virus}=Results;
%     fprintf('Virus%s模型运行时间: %s | 当前时间: %s\n',num2str(virus),duration(0,0,toc),datetime('now'));
%     save([Path,'Fig3_results_20250507.mat'],'Fig3_results');
% end
% Fig4
% load Par_20250507_1bas;load Par_20250507_3per;
% Cap_H=[141 141 141 141 283 283 283 283 444 444 444 444];
% Cap_F=[0 0.1 0.25 0.5 0 0.1 0.25 0.5 0 0.1 0.25 0.5];
% NS=5000;R0=linspace(1.25,3.7,15);Sev=linspace(0.038,0.967,10);
% load Fig4_results_20250507; % Fig4_results=cell(1,length(Cap_H));
% for cap=6:length(Cap_H)
%     Results=zeros(length(R0),length(Sev),3);
%     for i=1:length(R0)
%         for j=1:length(Sev)
%             XH=zeros(NS,1);
%             parfor Pnum=1:NS
%                 Par_bas0=Par_per(:,Pnum);%Par_bas_median;%parjun(:,Pnum);
%                 Par_bas0(1)=R0(i);Par_bas0(10)=Sev(j);
%                 X1=fcfun2_model(t,y0,dt,Cap_H(cap),Cap_F(cap)*Cap_H(cap),Par_bas0);
%                 XH(Pnum)=any(sum(X1(:,8:10),2)>=Cap_H(cap)); 
%             end
%             X=XH;p=mean(X);SE=sqrt(p*(1-p)/length(X));CI1=p-1.96*SE;CI2=p+1.96*SE;
%             Results(i,j,:)=[p CI1 CI2]'*100;
%         end 
%     end
%     fprintf('cap=%s模型运行时间: %s | 当前时间: %s\n',num2str(cap),duration(0,0,toc),datetime('now'));
%     Fig4_results{cap}=Results;
%     save([Path,'Fig4_results_20250507.mat'],'Fig4_results');
% end
% Fig5
% NS=5000;itv=5;Fig5_data0=readtable('fc_data.xlsx','Sheet','fig5');
% load Par_20250507_4bci;load Afig2outcome;load Fig5_results_20250516;%out44=zeros(5,9,44);
% Fig5_data=table2array(Fig5_data0);Fig5_results=Fig5_data(:,2:end);ff=0.25;
% for virus=3
%     Par_fig5=Par_bci(virus*11-10:virus*11,:);bsl=Afig2outcome(virus,[1 7 16]);
%     for parlh=5:11
%         capR=Fig5_results(parlh+(virus-1)*11,4:7);Results=zeros(itv,16);
%         H_capvl=linspace(capR(1),capR(2),itv);H_capvh=linspace(capR(3),capR(4),itv);
%         if Par_fig5(parlh,3)>0
%             for i=1:itv
%                 XH16=zeros(NS,16);hc1=H_capvl(i);hc2=H_capvh(i);
%                 parfor Pnum=1:NS
%                     X1=fcfun_model_sen(t,Pop,dt,hc1,0,Par_fig5,parlh,1);
%                     X2=fcfun_model_sen(t,Pop,dt,hc1,0,Par_fig5,parlh,2);
%                     X3=fcfun_model_sen(t,Pop,dt,hc1,0,Par_fig5,parlh,3);
%                     X4=fcfun_model_sen(t,Pop,dt,hc1,0,Par_fig5,parlh,4);
%                     X5=fcfun_model_sen(t,Pop,dt,hc2,0,Par_fig5,parlh,5);
%                     X6=fcfun_model_sen(t,Pop,dt,hc2,0,Par_fig5,parlh,6);
%                     X7=fcfun_model_sen(t,Pop,dt,hc2,0,Par_fig5,parlh,7);
%                     X8=fcfun_model_sen(t,Pop,dt,hc2,0,Par_fig5,parlh,8);
%                     x1=fcfun_model_sen(t,Pop,dt,hc1,ff*hc1,Par_fig5,parlh,1);
%                     x2=fcfun_model_sen(t,Pop,dt,hc1,ff*hc1,Par_fig5,parlh,2);
%                     x3=fcfun_model_sen(t,Pop,dt,hc1,ff*hc1,Par_fig5,parlh,3);
%                     x4=fcfun_model_sen(t,Pop,dt,hc1,ff*hc1,Par_fig5,parlh,4);
%                     x5=fcfun_model_sen(t,Pop,dt,hc2,ff*hc2,Par_fig5,parlh,5);
%                     x6=fcfun_model_sen(t,Pop,dt,hc2,ff*hc2,Par_fig5,parlh,6);
%                     x7=fcfun_model_sen(t,Pop,dt,hc2,ff*hc2,Par_fig5,parlh,7);
%                     x8=fcfun_model_sen(t,Pop,dt,hc2,ff*hc2,Par_fig5,parlh,8);
%                     p1=any(sum(X1(:,8:10),2)>=hc1); b1=any(sum(x1(:,8:10),2)>=hc1); 
%                     p2=any(sum(X2(:,8:10),2)>=hc1); b2=any(sum(x2(:,8:10),2)>=hc1);
%                     p3=any(sum(X3(:,8:10),2)>=hc1); b3=any(sum(x3(:,8:10),2)>=hc1);
%                     p4=any(sum(X4(:,8:10),2)>=hc1); b4=any(sum(x4(:,8:10),2)>=hc1);
%                     p5=any(sum(X5(:,8:10),2)>=hc2); b5=any(sum(x5(:,8:10),2)>=hc2);
%                     p6=any(sum(X6(:,8:10),2)>=hc2); b6=any(sum(x6(:,8:10),2)>=hc2); 
%                     p7=any(sum(X7(:,8:10),2)>=hc2); b7=any(sum(x7(:,8:10),2)>=hc2);
%                     p8=any(sum(X8(:,8:10),2)>=hc2); b8=any(sum(x8(:,8:10),2)>=hc2);
%                     XH16(Pnum,:)=[p1 p2 p3 p4 p5 p6 p7 p8 b1 b2 b3 b4 b5 b6 b7 b8];
%                 end
%                 Results(i,:)=mean(XH16);
%             end
%         end
%         if all(Results(1:2,:)~=0)
%             cpt=hl(Results,H_capvl,H_capvh);XH8=zeros(NS,8);
%             parfor Pnum=1:NS
%                 X1=fcfun_model_sen(t,Pop,dt,cpt(1),ff*cpt(1),Par_fig5,parlh,1);
%                 X2=fcfun_model_sen(t,Pop,dt,cpt(2),ff*cpt(2),Par_fig5,parlh,2);
%                 X3=fcfun_model_sen(t,Pop,dt,cpt(3),ff*cpt(3),Par_fig5,parlh,3);
%                 X4=fcfun_model_sen(t,Pop,dt,cpt(4),ff*cpt(4),Par_fig5,parlh,4);
%                 X5=fcfun_model_sen(t,Pop,dt,cpt(5),ff*cpt(5),Par_fig5,parlh,5);
%                 X6=fcfun_model_sen(t,Pop,dt,cpt(6),ff*cpt(6),Par_fig5,parlh,6);
%                 X7=fcfun_model_sen(t,Pop,dt,cpt(7),ff*cpt(7),Par_fig5,parlh,7);
%                 X8=fcfun_model_sen(t,Pop,dt,cpt(8),ff*cpt(8),Par_fig5,parlh,8);
%                 p1=any(sum(X1(:,8:10),2)>=cpt(1)); 
%                 p2=any(sum(X2(:,8:10),2)>=cpt(2));
%                 p3=any(sum(X3(:,8:10),2)>=cpt(3)); 
%                 p4=any(sum(X4(:,8:10),2)>=cpt(4));
%                 p5=any(sum(X5(:,8:10),2)>=cpt(5)); 
%                 p6=any(sum(X6(:,8:10),2)>=cpt(6));
%                 p7=any(sum(X7(:,8:10),2)>=cpt(7)); 
%                 p8=any(sum(X8(:,8:10),2)>=cpt(8));
%                 XH8(Pnum,:)=[p1 p2 p3 p4 p5 p6 p7 p8];
%             end
%             cpt(1,17:24)=mean(XH8);out=xingzhuang(Par_fig5(parlh,:),cpt,bsl);
%             fprintf('parlh%s模型运行时间: %s | 当前时间: %s\n',num2str(parlh),duration(0,0,toc),datetime('now'));
%             out44(:,:,parlh+(virus-1)*11)=out;
%             save([Path,'Fig5_results_20250516.mat'],'out44');
%         end
%     end
% end
% out=out44(:,:,3);
% close(figure(1));figure(1);set(gcf,'position',[300 70 1050 900])
% hold on
% plot(out(1,:), out(2,:),'k-o',LineWidth=2);
% plot(out(1,:), out(3,:),'b-o',LineWidth=2);
% ylim([0 30])
% yyaxis right
% plot(out(1,:), out(4,:),'--mo',LineWidth=2);
% plot(out(1,:), out(5,:),'--ro',LineWidth=2);
% ylim([0 0.5])
% legend('Threshold capacity without Fangcang','Threshold capacity with medium Fangcang','Overload probability with medium Fangcang','Threshold capacity reduction with medium Fangcang')
% set(gca,'YGrid','on','fontsize',16,'fontname','Times New Roman')

%% function
function X=fc_model(t_range, y0, dt, H_cap, F_cap, Known_par)
R0    = Known_par(1);
ps    = Known_par(2);
pa    = Known_par(3);
k     = Known_par(4);
delta = 1/Known_par(5);
gamma = 1/Known_par(6);
fi_H  = 1/Known_par(7);
Tao_m = 1/Known_par(8);
Tao_p = 1/Known_par(9);
Tao_h = 1/Known_par(10);
beta  = R0/(k/delta+1/gamma);%beta=R0/(k/delta+(1-alpha)/gamma+alpha/fi_H);

ns     = max(t_range)/dt;
X      = zeros(ns,11);
X(1,:) = y0;
p_exp1 = 1 - exp(-(1-pa)*delta*dt);
p_exp2 = 1 - exp(-pa*delta*dt);
p_rec  = 1 - exp(-gamma*dt);
p_as1  = 1 - exp(-(1-ps)*fi_H*dt);
p_as2  = 1 - exp(-ps*fi_H*dt);
p_Tom  = 1 - exp(-Tao_m*dt);
p_Top  = 1 - exp(-Tao_p*dt);
p_Toh  = 1 - exp(-Tao_h*dt);
for t = 2:ns
    S =X(t-1,1);E =X(t-1,2);C =X(t-1,3);A=X(t-1,4);
    F1=X(t-1,5);F2=X(t-1,6);F3=X(t-1,7);
    H1=X(t-1,8);H2=X(t-1,9);H3=X(t-1,10);R=X(t-1,11);
    N=S+E+C+A+F1+F2+F3+H1+H2+H3+R;
    H=H1+H2+H3;F=F1+F2+F3;
   
    p_inf = 1 - exp(-beta*(k*E+C+A)/N*dt);
    Multi_S = binornd(S, p_inf); 
    Multi_E = mnrnd(E, [p_exp1,p_exp2, 1-p_exp1-p_exp2]);
    Multi_C = binornd(C, p_rec);
    Multi_F1 = binornd(F1, p_Tom);
    Multi_F2 = binornd(F2, p_Top);
    Multi_F3 = binornd(F3, p_Toh); 
    Multi_H1 = binornd(H1, p_Tom); 
    Multi_H2 = binornd(H2, p_Top); 
    Multi_H3 = binornd(H3, p_Toh);
    X(t,1) = S - Multi_S(1);
    X(t,2) = E + Multi_S(1) - Multi_E(1)- Multi_E(2);
    X(t,3) = C + Multi_E(1) - Multi_C(1);

    if F>=F_cap && H<H_cap
        %p_F=0;p_H1=1;p_H2=1;
        Multi_A = mnrnd(A, [p_as1,p_as2,1-p_as1-p_as2]);
        X(t,4) = A + Multi_E(2) - Multi_A(1)-Multi_A(2);
        X(t,5) = F1- Multi_F1(1);
        X(t,6) = F2- Multi_F2(1);
        X(t,7) = F3- Multi_F3(1);
        X(t,8) = H1+ Multi_A(1) - Multi_H1(1);
        X(t,9) = H2+ Multi_A(2) - Multi_H2(1);
        X(t,10)= H3+ Multi_F2(1)+ Multi_H2(1)-Multi_H3(1);
        X(t,11)= R + Multi_C(1) + Multi_F1(1)+Multi_H1(1)+Multi_F3(1)+Multi_H3(1);
    elseif F>=F_cap && H>=H_cap
        %p_F=0;p_H1=0;p_H2=0;
        Multi_A =binornd(A,p_rec);
        X(t,4) = A + Multi_E(2) - Multi_A(1);
        X(t,5) = F1- Multi_F1(1);
        X(t,6) = F2- Multi_F2(1);
        X(t,7) = F3+ Multi_F2(1)- Multi_F3(1);
        X(t,8) = H1- Multi_H1(1);
        X(t,9) = H2- Multi_H2(1);
        X(t,10)= H3+ Multi_H2(1)- Multi_H3(1);
        X(t,11)= R + Multi_C(1)+ Multi_A(1)+ Multi_F1(1)+Multi_H1(1)+Multi_F3(1)+Multi_H3(1);
    elseif F<F_cap && H<H_cap
        %p_F=1;p_H1=0;p_H2=1;
        Multi_A = mnrnd(A, [p_as1,p_as2,1-p_as1-p_as2]);
        X(t,4) = A + Multi_E(2) - Multi_A(1) -Multi_A(2);
        X(t,5) = F1+ Multi_A(1) - Multi_F1(1);
        X(t,6) = F2+ Multi_A(2) - Multi_F2(1);
        X(t,7) = F3- Multi_F3(1);
        X(t,8) = H1- Multi_H1(1);
        X(t,9) = H2- Multi_H2(1);
        X(t,10)= H3+ Multi_F2(1)+ Multi_H2(1)-Multi_H3(1);
        X(t,11)= R + Multi_C(1) + Multi_F1(1)+Multi_H1(1)+Multi_F3(1)+Multi_H3(1);
    elseif F<F_cap && H>=H_cap
        %p_F=1;p_H1=0;p_H2=0;
        Multi_A = mnrnd(A, [p_as1,p_as2,1-p_as1-p_as2]);
        X(t,4) = A + Multi_E(2) - Multi_A(1) - Multi_A(2);
        X(t,5) = F1+ Multi_A(1) - Multi_F1(1);
        X(t,6) = F2+ Multi_A(2) - Multi_F2(1);
        X(t,7) = F3+ Multi_F2(1)- Multi_F3(1);
        X(t,8) = H1- Multi_H1(1);
        X(t,9) = H2- Multi_H2(1);
        X(t,10)= H3+ Multi_H2(1)-Multi_H3(1);
        X(t,11)= R + Multi_C(1) + Multi_F1(1)+Multi_H1(1)+Multi_F3(1)+Multi_H3(1);
    end
end
end

function Par_profile = sample_parameters(viruses, virus_names, NS, pct_variation)
% SAMPLE_PARAMETERS Generate parameter samples for multiple viruses
%   Par_profile = SAMPLE_PARAMETERS(viruses, virus_names, NS, pct_variation)
%   performs Monte Carlo sampling of parameters for each virus based on
%   specified distributions and calculates derived parameters.
%
%   Inputs:
%       viruses        - Cell array containing parameter data for each virus
%       virus_names    - Cell array of virus names
%       NS             - Number of samples to generate
%       pct_variation  - Percentage variation for PERT distributions without bounds
%
%   Outputs:
%       Par_profile    - Cell array of structures with sampling results

    % Initialize results container
    Par_profile = cell(length(viruses), 1);
    
    % Process each virus
    for v_idx = 1:length(viruses)
        fprintf('Processing %s...\n', virus_names{v_idx});
        virus_data = viruses{v_idx};
        n_params = size(virus_data, 1);
        
        % Extract parameter names
        param_names = virus_data(:, 1);
        
        % Initialize sampling results matrix
        samples = zeros(NS, n_params);
        
        % Store parameter metadata
        baseline_vals = zeros(n_params, 1);
        lower_vals = zeros(n_params, 1);
        upper_vals = zeros(n_params, 1);
        dist_vals = cell(n_params, 1);
        source_vals = cell(n_params, 1);
        note_vals = cell(n_params, 1);
        dist_params_vals = cell(n_params, 1);  % Store distribution parameters
        
        % Store sample statistics
        sample_mean_vals = zeros(n_params, 1);
        sample_lower_vals = zeros(n_params, 1);
        sample_upper_vals = zeros(n_params, 1);
        
        % Track calculated parameters
        calc_indices = [];
        calc_formulas = {};
        
        % Sample each parameter
        for p_idx = 1:n_params
            name     = param_names{p_idx};
            baseline = virus_data{p_idx, 2};
            lower    = virus_data{p_idx, 3};
            upper    = virus_data{p_idx, 4};
            dist     = virus_data{p_idx, 5};
            source   = virus_data{p_idx, 6};
            note     = virus_data{p_idx, 7};
            
            % Store metadata
            baseline_vals(p_idx) = baseline;
            dist_vals{p_idx} = dist;
            source_vals{p_idx} = source;
            note_vals{p_idx} = note;
            
            % Handle pct_variation source
            if strcmpi(source, 'pct_variation')
                lower_calc = baseline * (1 - pct_variation);
                upper_calc = baseline * (1 + pct_variation);
                lower_vals(p_idx) = lower_calc;
                upper_vals(p_idx) = upper_calc;
            else
                lower_vals(p_idx) = lower;
                upper_vals(p_idx) = upper;
            end
            
            % Case 1: PERT with lower & upper both available
            if strcmpi(dist, 'PERT') && ~isnan(lower_vals(p_idx)) && ~isnan(upper_vals(p_idx))
                dist_params_vals{p_idx} = sprintf('PERT (%.3f, %.3f, %.3f)', baseline, lower_vals(p_idx), upper_vals(p_idx));
                samples(:, p_idx) = pert_sample(baseline, lower_vals(p_idx), upper_vals(p_idx), NS);
                continue;
            end
            
            % Case 2: PERT with NaN lower & upper (use pct_variation)
            if strcmpi(dist, 'PERT') && (isnan(lower) || isnan(upper))
                lower_calc = baseline * (1 - pct_variation);
                upper_calc = baseline * (1 + pct_variation);
                lower_vals(p_idx) = lower_calc;
                upper_vals(p_idx) = upper_calc;
                dist_params_vals{p_idx} = sprintf('PERT (%.3f, %.3f, %.3f)', baseline, lower_calc, upper_calc);
                samples(:, p_idx) = pert_sample(baseline, lower_calc, upper_calc, NS);
                continue;
            end
            
            % Case 3: Beta distribution
            if strcmpi(dist, 'Beta')
                [alpha, beta] = prop2beta(baseline, lower_vals(p_idx), upper_vals(p_idx));
                dist_params_vals{p_idx} = sprintf('Beta (%.3f, %.3f)', alpha, beta);
                samples(:, p_idx) = betarnd(alpha, beta, NS, 1);
                continue;
            end
            
            % Case 4: Lognormal with lower & upper both available
            if strcmpi(dist, 'Lognormal') && ~isnan(lower_vals(p_idx)) && ~isnan(upper_vals(p_idx))
                [mu_log, sigma_log] = lognormal2params(baseline, lower_vals(p_idx), upper_vals(p_idx));
                dist_params_vals{p_idx} = sprintf('Lognormal (%.3f, %.3f)', mu_log, sigma_log);
                samples(:, p_idx) = lognrnd(mu_log, sigma_log, NS, 1);
                continue;
            end
            
            % Case 5: Uniform distribution
            if strcmpi(dist, 'Uniform')
                if ~isnan(lower_vals(p_idx)) && ~isnan(upper_vals(p_idx))
                    dist_params_vals{p_idx} = sprintf('Uniform (%.3f, %.3f)', lower_vals(p_idx), upper_vals(p_idx));
                    samples(:, p_idx) = lower_vals(p_idx) + (upper_vals(p_idx) - lower_vals(p_idx)) * rand(NS, 1);
                else
                    error('Uniform distribution requires lower and upper for %s', name);
                end
                continue;
            end
            
            % Case 6: None with baseline = 0
            if strcmpi(dist, 'None') && isnumeric(baseline) && baseline == 0
                dist_params_vals{p_idx} = 'Fixed (0)';
                samples(:, p_idx) = zeros(NS, 1);
                continue;
            end
            
            % Case 7: None with source = "calculated"
            if strcmpi(dist, 'None') && strcmpi(source, 'calculated')
                dist_params_vals{p_idx} = 'Calculated';
                calc_indices = [calc_indices, p_idx];
                calc_formulas{end+1} = note;
                continue;
            end
            
            % Fallback: use baseline
            if ~isnan(baseline)
                dist_params_vals{p_idx} = sprintf('Fixed (%.3f)', baseline);
                samples(:, p_idx) = baseline * ones(NS, 1);
            else
                dist_params_vals{p_idx} = 'NaN';
                samples(:, p_idx) = NaN(NS, 1);
            end
        end
        
        % Process calculated parameters with topological sorting
        if ~isempty(calc_indices)
            % First, get the topological order for sampling
            samples = process_calculated_params(samples, param_names, ...
                calc_indices, calc_formulas);
            
            % Second, calculate baseline for calculated parameters using baseline values
            % Extract dependencies and sort
            n_calc = length(calc_indices);
            deps = cell(n_calc, 1);
            for i = 1:n_calc
                formula = calc_formulas{i};
                tokens = regexp(formula, '[A-Za-z_][A-Za-z0-9_]*', 'match');
                deps{i} = unique(tokens);
            end
            
            % Topological sort for baseline calculation
            order = [];
            remaining = 1:n_calc;
            while ~isempty(remaining)
                found = false;
                for i = 1:length(remaining)
                    idx = remaining(i);
                    all_ready = true;
                    for j = 1:length(deps{idx})
                        dep_name = deps{idx}{j};
                        dep_idx = find(strcmp(param_names, dep_name), 1);
                        if ismember(dep_idx, calc_indices)
                            dep_calc_idx = find(calc_indices == dep_idx);
                            if ~ismember(dep_calc_idx, order)
                                all_ready = false;
                                break;
                            end
                        end
                    end
                    if all_ready
                        order = [order, idx];
                        remaining(i) = [];
                        found = true;
                        break;
                    end
                end
                if ~found
                    order = [order, remaining];
                    break;
                end
            end
            
            % Calculate baseline values in topological order
            baseline_row = baseline_vals';
            for i = 1:length(order)
                idx = order(i);
                p_idx = calc_indices(idx);
                formula = calc_formulas{idx};
                
                % Replace parameter names with their baseline values
                calc_formula = formula;
                for j = 1:n_params
                    param_name = param_names{j};
                    pattern = ['\<', regexptranslate('escape', param_name), '\>'];
                    replacement = num2str(baseline_row(j));
                    calc_formula = regexprep(calc_formula, pattern, replacement);
                end
                
                % Calculate baseline value
                try
                    baseline_vals(p_idx) = eval(calc_formula);
                    % Update baseline_row for subsequent calculations
                    baseline_row(p_idx) = baseline_vals(p_idx);
                    % Update dist_params for calculated parameter
                    dist_params_vals{p_idx} = sprintf('Calculated (%.3f)', baseline_vals(p_idx));
                catch
                    baseline_vals(p_idx) = NaN;
                    dist_params_vals{p_idx} = 'Calculated (Error)';
                end
            end
        end
        
        % Calculate sample statistics for all parameters
        for p_idx = 1:n_params
            sample_mean_vals(p_idx) = mean(samples(:, p_idx));
            sample_lower_vals(p_idx) = prctile(samples(:, p_idx), 2.5);
            sample_upper_vals(p_idx) = prctile(samples(:, p_idx), 97.5);
            
            % For calculated parameters, set lower/upper to sample percentiles
            if any(calc_indices == p_idx)
                lower_vals(p_idx) = sample_lower_vals(p_idx);
                upper_vals(p_idx) = sample_upper_vals(p_idx);
            end
        end
        
        % Create summary table
        summary_table = table(param_names, baseline_vals, lower_vals, upper_vals, ...
            dist_vals, dist_params_vals, source_vals, note_vals, ...
            sample_mean_vals, sample_lower_vals, sample_upper_vals, ...
            'VariableNames', {'Parameter', 'Baseline', 'Lower', 'Upper', ...
            'Distribution', 'Distribution_Parameters', 'Source', 'Note', ...
            'Sample_Mean', 'Sample_Lower_2.5pct', 'Sample_Upper_97.5pct'});
        
        % Store results with all metadata
        Par_profile{v_idx} = struct();
        Par_profile{v_idx}.name = virus_names{v_idx};
        Par_profile{v_idx}.param_names = param_names;
        Par_profile{v_idx}.samples = samples;
        Par_profile{v_idx}.baseline = baseline_vals;
        Par_profile{v_idx}.lower = lower_vals;
        Par_profile{v_idx}.upper = upper_vals;
        Par_profile{v_idx}.distribution = dist_vals;
        Par_profile{v_idx}.distribution_parameters = dist_params_vals;
        Par_profile{v_idx}.source = source_vals;
        Par_profile{v_idx}.note = note_vals;
        Par_profile{v_idx}.sample_mean = sample_mean_vals;
        Par_profile{v_idx}.sample_lower = sample_lower_vals;
        Par_profile{v_idx}.sample_upper = sample_upper_vals;
        Par_profile{v_idx}.summary_table = summary_table;
        Par_profile{v_idx}.n_samples = NS;
        Par_profile{v_idx}.sampling_date = datestr(now);
        
        fprintf('  Completed: %d parameters sampled\n', n_params);
    end
end

function NewVirus = produce_hybrid_virus(virus_data, virus_names, n_samples)
% PRODUCE_HYBRID_VIRUS Generate PERT samples from 4 existing viruses to create a hybrid virus
%   NewVirus = PRODUCE_HYBRID_VIRUS(virus_data, virus_names, n_samples)
%   takes baseline values from 4 viruses for each parameter, treats them as 
%   min, max, and mode (from 4 values), and generates PERT distribution samples.
%
%   Inputs:
%       virus_data   - 10x4 matrix, each column is a virus, each row is a parameter
%       virus_names  - Cell array of 4 virus names
%       n_samples    - Number of samples to generate
%
%   Outputs:
%       NewVirus     - Struct containing sampling results for the hybrid virus

    % Input validation
    [n_params, n_viruses] = size(virus_data);
    assert(n_viruses == 4, 'Input matrix must have exactly 4 columns (4 viruses)');
    assert(length(virus_names) == 4, 'virus_names must have 4 elements');
    
    % Initialize output
    NewVirus = struct();
    NewVirus.name = 'Hybrid_Virus';
    NewVirus.source_viruses = virus_names;
    NewVirus.n_samples = n_samples;
    NewVirus.sampling_date = datestr(now);
    
    % Store parameter names (assuming same order as original)
    param_names = {'R0', 'ps', 'pa', 'k', '1/delta', '1/gamma', ...
                   '1/phi_H', '1/tau_m', '1/tau_p', '1/tau_h'};
    NewVirus.param_names = param_names;
    
    % Store baseline matrix (original values from 4 viruses)
    NewVirus.baseline_matrix = virus_data;  % 10x4 matrix
    NewVirus.baseline_source = sprintf('Values from %s, %s, %s, %s', virus_names{:});
    
    % Initialize storage for PERT parameters and samples
    pert_min = zeros(n_params, 1);
    pert_max = zeros(n_params, 1);
    pert_mode = zeros(n_params, 1);
    pert_samples = zeros(n_params, n_samples);
    pert_alpha = zeros(n_params, 1);
    pert_beta = zeros(n_params, 1);
    
    lambda = 4;  % Standard PERT shape parameter
    
    % Generate PERT samples for each parameter
    for i = 1:n_params
        % Get 4 values from 4 viruses for current parameter
        values = virus_data(i, :);
        
        % Sort to identify min, max, and mode (use middle two for mode)
        sorted_vals = sort(values);
        min_val = sorted_vals(1);
        max_val = sorted_vals(4);
        mode_val = mean(sorted_vals(2:3));  % Average of middle two values
        
        % Store PERT parameters
        pert_min(i) = min_val;
        pert_max(i) = max_val;
        pert_mode(i) = mode_val;
        
        % Calculate Beta distribution shape parameters
        pert_alpha(i) = 1 + lambda * (mode_val - min_val) / (max_val - min_val);
        pert_beta(i) = 1 + lambda * (max_val - mode_val) / (max_val - min_val);
        
        % Generate samples: Beta -> scale to [min, max]
        beta_samples = betarnd(pert_alpha(i), pert_beta(i), [1, n_samples]);
        pert_samples(i, :) = min_val + (max_val - min_val) * beta_samples;
    end
    
    % Store PERT parameters
    NewVirus.pert_min = pert_min;
    NewVirus.pert_max = pert_max;
    NewVirus.pert_mode = pert_mode;
    NewVirus.pert_alpha = pert_alpha;
    NewVirus.pert_beta = pert_beta;
    NewVirus.lambda = lambda;
    
    % Store samples
    NewVirus.samples = pert_samples;  % n_params x n_samples
    
    % Calculate sample statistics
    NewVirus.sample_mean = mean(pert_samples, 2);
    NewVirus.sample_median = median(pert_samples, 2);
    NewVirus.sample_lower = prctile(pert_samples, 2.5, 2);
    NewVirus.sample_upper = prctile(pert_samples, 97.5, 2);
    
    % Create summary table
    summary_table = table(param_names', pert_min, pert_mode, pert_max, ...
        pert_alpha, pert_beta, NewVirus.sample_mean, ...
        NewVirus.sample_lower, NewVirus.sample_upper, ...
        'VariableNames', {'Parameter', 'Min', 'Mode', 'Max', ...
        'Alpha', 'Beta', 'Sample_Mean', 'Sample_Lower_2.5pct', 'Sample_Upper_97.5pct'});
    NewVirus.summary_table = summary_table;
    
    % Display summary
    fprintf('\n=== Hybrid Virus Created ===\n');
    fprintf('Source viruses: %s, %s, %s, %s\n', virus_names{:});
    fprintf('Number of parameters: %d\n', n_params);
    fprintf('Number of samples: %d\n', n_samples);
    fprintf('PERT shape parameter lambda: %.1f\n', lambda);
    disp(summary_table);
end

function samples = process_calculated_params(samples, param_names, calc_indices, calc_formulas)
% PROCESS_CALCULATED_PARAMS Process calculated parameters with dependency sorting

    n_params = length(param_names);
    n_calc = length(calc_indices);
    
    % Create mapping from parameter name to column index
    param_to_idx = containers.Map(param_names, 1:n_params);
    
    % Step 1: Extract dependencies for each calculated parameter
    deps = cell(n_calc, 1);
    for i = 1:n_calc
        formula = calc_formulas{i};
        
        % Extract dependencies by matching parameter names exactly
        % Instead of regex, check each parameter name against the formula
        deps{i} = {};
        for j = 1:length(param_names)
            param_name = param_names{j};
            % Check if parameter name appears in formula (as whole word)
            % Use regexp with word boundaries
            pattern = ['\<', regexptranslate('escape', param_name), '\>'];
            if ~isempty(regexp(formula, pattern, 'once'))
                deps{i}{end+1} = param_name;
            end
        end
        
        % Debug: print dependencies
        if ~isempty(deps{i})
            fprintf('    %s depends on: %s\n', param_names{calc_indices(i)}, strjoin(deps{i}, ', '));
        else
            fprintf('    %s depends on: (no dependencies found)\n', param_names{calc_indices(i)});
        end
    end
    
    % Step 2: Topological sort
    order = [];
    remaining = 1:n_calc;
    max_iter = n_calc * n_calc;
    iter = 0;
    
    while ~isempty(remaining) && iter < max_iter
        iter = iter + 1;
        found = false;
        
        for i = 1:length(remaining)
            idx = remaining(i);
            p_idx = calc_indices(idx);
            
            % Check if all dependencies are ready
            all_ready = true;
            for j = 1:length(deps{idx})
                dep_name = deps{idx}{j};
                
                % Find parameter index
                if param_to_idx.isKey(dep_name)
                    dep_param_idx = param_to_idx(dep_name);
                    
                    % Check if dependency is a calculated parameter
                    dep_calc_pos = find(calc_indices == dep_param_idx);
                    
                    if ~isempty(dep_calc_pos)
                        % Dependency is calculated - check if already processed
                        if ~ismember(dep_calc_pos, order)
                            all_ready = false;
                            break;
                        end
                    end
                else
                    warning('  Parameter "%s" not found for formula of %s', ...
                        dep_name, param_names{p_idx});
                    all_ready = false;
                    break;
                end
            end
            
            if all_ready
                order = [order, idx];
                remaining(i) = [];
                found = true;
                break;
            end
        end
        
        if ~found && ~isempty(remaining)
            warning('  Circular dependency detected. Processing remaining in order:');
            for i = 1:length(remaining)
                fprintf('    %s\n', param_names{calc_indices(remaining(i))});
            end
            order = [order, remaining];
            break;
        end
    end
    
    % Step 3: Print calculation order
    fprintf('  Calculation order:\n');
    for i = 1:length(order)
        fprintf('    %d. %s\n', i, param_names{calc_indices(order(i))});
    end
    
    % Step 4: Compile and execute in sorted order
    for i = 1:length(order)
        idx = order(i);
        p_idx = calc_indices(idx);
        formula = calc_formulas{idx};
        param_name = param_names{p_idx};
        
        % Replace parameter names with sample column references
        processed = formula;
        for j = 1:n_params
            param_name_j = param_names{j};
            % Escape special regex characters in parameter name
            escaped_name = regexptranslate('escape', param_name_j);
            pattern = ['\<', escaped_name, '\>'];
            replacement = sprintf('samples(:, %d)', j);
            processed = regexprep(processed, pattern, replacement);
        end
        
        % Ensure element-wise operations
        processed = strrep(processed, '^', '.^');
        
        % Create and execute function
        try
            func = str2func(['@(samples) ', processed]);
            result = func(samples);
            
            % Validate result
            if size(result, 1) == size(samples, 1)
                samples(:, p_idx) = result;
                fprintf('    ✓ %s = %s\n', param_name, formula);
            else
                warning('  Dimension mismatch for %s: got %d, expected %d', ...
                    param_name, size(result, 1), size(samples, 1));
                samples(:, p_idx) = NaN(size(samples, 1), 1);
            end
            
        catch ME
            warning('  Error calculating %s: %s', param_name, ME.message);
            samples(:, p_idx) = NaN(size(samples, 1), 1);
        end
    end
end

function [alpha, beta] = prop2beta(mu, L, U)
    % Estimate standard deviation from range (assuming normal approximation)
    sigma = (U - L) / 3.92;
    % Method of moments for Beta distribution
    scale = mu * (1 - mu) / sigma^2 - 1;
    alpha = mu * scale;
    beta = (1 - mu) * scale;
end

function [mu_log, sigma_log] = lognormal2params(mean_val, L, U)
    % LOGNORMAL2PARAMS Convert mean and 95% CI to lognormal distribution parameters
    % Input:
    %   mean_val - mean on original scale
    %   L        - lower bound of 95% CI
    %   U        - upper bound of 95% CI
    % Output:
    %   mu_log   - mean of log-transformed distribution
    %   sigma_log - standard deviation of log-transformed distribution
    
    % Estimate sigma on log scale from 95% CI
    sigma_log = (log(U) - log(L)) / 3.92;
    
    % Calculate mu on log scale
    % For lognormal: mean = exp(mu_log + sigma_log^2/2)
    % Therefore: mu_log = log(mean_val) - sigma_log^2/2
    mu_log = log(mean_val) - 0.5 * sigma_log^2;
end

function samples = pert_sample(mode, lower, upper, NS)
    % PERT distribution sampling function
    
    % Validate inputs
    if mode <= lower || mode >= upper
        warning('Mode (%.3f) outside [lower, upper] = [%.3f, %.3f]. Using uniform distribution.', ...
            mode, lower, upper);
        samples = lower + (upper - lower) * rand(NS, 1);
        return;
    end
    
    % Calculate mean
    mu = (lower + 4*mode + upper) / 6;
    
    % Handle case where mode equals mu (symmetric case)
    if abs(mode - mu) < 1e-10
        % Use symmetric shape parameters (alpha = beta = 4)
        alpha = 4;
        beta = 4;
    else
        % Calculate shape parameters
        alpha = (mu - lower) * (2*mode - lower - upper) / ((mode - mu) * (upper - lower));
        beta = alpha * (upper - mu) / (mu - lower);
        
        % Ensure valid parameters
        if alpha <= 0 || beta <= 0 || isnan(alpha) || isnan(beta) || isinf(alpha) || isinf(beta)
            % Fall back to symmetric distribution
            alpha = 4;
            beta = 4;
        end
    end
    
    % Generate samples
    beta_samples = betarnd(alpha, beta, NS, 1);
    samples = lower + (upper - lower) * beta_samples;
end

function [CI_lower, CI_upper] = median_ci_from_iqr(median_val, Q1, Q3, n, varargin)
    % MEDIAN_CI_FROM_IQR  Estimate 95% CI for median from median, IQR, and sample size
    %
    % Inputs:
    %   median_val - sample median
    %   Q1         - 25th percentile (first quartile)
    %   Q3         - 75th percentile (third quartile)
    %   n          - sample size
    %
    % Optional name-value pairs:
    %   'alpha'    - confidence level (default: 0.05 for 95% CI)
    %   'method'   - 'logistic' (default) or 'normal'
    %
    % Outputs:
    %   CI_lower   - lower bound of confidence interval
    %   CI_upper   - upper bound of confidence interval
    %
    % Example:
    %   [L, U] = median_ci_from_iqr(12, 5, 22, 168)
    %   [L, U] = median_ci_from_iqr(4, 2, 7, 168)
    %   [L, U] = median_ci_from_iqr(14, 6, 20, 168)
    %   [L, U] = median_ci_from_iqr(8, 7, 12, 194)
    
    % Parse inputs
    p = inputParser;
    addRequired(p, 'median_val', @isnumeric);
    addRequired(p, 'Q1', @isnumeric);
    addRequired(p, 'Q3', @isnumeric);
    addRequired(p, 'n', @(x) isnumeric(x) && x > 0);
    addParameter(p, 'alpha', 0.05, @(x) isnumeric(x) && x > 0 && x < 1);
    addParameter(p, 'method', 'logistic', @(x) ismember(x, {'logistic', 'normal'}));
    parse(p, median_val, Q1, Q3, n, varargin{:});
    
    alpha = p.Results.alpha;
    method = p.Results.method;
    z = norminv(1 - alpha/2);  % 1.96 for alpha=0.05
    
    % Calculate IQR width
    IQR_width = Q3 - Q1;
    
    % Estimate standard error of the median
    switch method
        case 'logistic'
            % Logistic distribution approximation (most common in medical stats)
            % For logistic: SD = IQR / ln(3) ≈ IQR / 1.0986
            % f(median) = 1/(4*SD) → SE = 1/(2*f(median)*sqrt(n)) = IQR/(1.35*sqrt(n))
            SE_median = IQR_width / (1.35 * sqrt(n));
        case 'normal'
            % Normal approximation: SD ≈ IQR / 1.35
            % f(median) = 1/(sqrt(2*pi)*SD) ≈ 0.54/IQR
            SE_median = IQR_width / (1.08 * sqrt(n));
        otherwise
            error('Unknown method');
    end
    
    % Calculate confidence interval
    CI_lower = median_val - z * SE_median;
    CI_upper = median_val + z * SE_median;
    
    % Display results
    fprintf('\n=== Median Confidence Interval Calculation ===\n');
    fprintf('Median: %.1f\n', median_val);
    fprintf('IQR: [%.1f, %.1f] (width = %.1f)\n', Q1, Q3, IQR_width);
    fprintf('Sample size: n = %d\n', n);
    fprintf('Method: %s\n', method);
    fprintf('Standard error of median: %.4f\n', SE_median);
    fprintf('z = %.4f (for %.1f%% CI)\n', z, (1-alpha)*100);
    fprintf('95%% CI for median: [%.4f, %.4f]\n', CI_lower, CI_upper);
    
end

function [CI_lower, CI_upper] = mean_ci_from_mean_sd(mean_val, SD, n, alpha)
    % MEAN_CI_FROM_MEAN_SD  Calculate confidence interval for the mean
    %
    % Inputs:
    %   mean_val - sample mean
    %   SD       - sample standard deviation
    %   n        - sample size
    %   alpha    - significance level (default: 0.05 for 95% CI)
    %
    % Outputs:
    %   CI_lower - lower bound
    %   CI_upper - upper bound

    % mean_ci_from_mean_sd(9.7, 5.5, 155)
    % mean_ci_from_mean_sd(7.5, 6.8, 594)
    % mean_ci_from_mean_sd(16.4, 6.5, 267)
    % mean_ci_from_mean_sd(6.5, 4.2, 554)
    
    if nargin < 4
        alpha = 0.05;
    end
    
    z = norminv(1 - alpha/2);  % 1.96 for alpha=0.05
    SE = SD / sqrt(n);
    radius = z * SE;
    
    CI_lower = mean_val - radius;
    CI_upper = mean_val + radius;
    
    fprintf('\n=== Mean Confidence Interval Calculation ===\n');
    fprintf('Mean: %.2f\n', mean_val);
    fprintf('SD: %.2f\n', SD);
    fprintf('n: %d\n', n);
    fprintf('SE: %.4f\n', SE);
    fprintf('z: %.4f\n', z);
    fprintf('95%% CI: [%.3f, %.3f]\n', CI_lower, CI_upper);
end

function fig = plot_hybrid_virus_histograms(HybridVirus)
% Plot histograms for the last 8 parameters of the hybrid virus
% Mark original virus baseline values on x-axis with different colors
%
% Input:
%   HybridVirus - Structure with fields:
%       .samples          - 10 x n_samples matrix
%       .param_names      - Cell array of parameter names
%       .source_viruses   - Cell array of virus names
%       .baseline_matrix  - 10 x 4 matrix
%       .pert_min         - Minimum perturbation values (10 x 1)
%       .pert_max         - Maximum perturbation values (10 x 1)
%
% Output:
%   fig - Figure handle

% Get hybrid virus data
samples         = HybridVirus.samples;          % 10 x n_samples matrix
param_names     = HybridVirus.param_names;
source_viruses  = HybridVirus.source_viruses;
baseline_matrix = HybridVirus.baseline_matrix;  % 10 x 4 matrix

% Parameters to plot (last 8: indices 3-10)
param_indices = 3:10;
n_params = length(param_indices);
n_samples = size(samples, 2);

% Create figure with tighter subplot spacing
fig = figure('Position', [100, 100, 1400, 900]);

% Colors for original viruses
virus_colors = {'r', 'b', 'g', 'm'};

% Adjust subplot spacing - tighter layout
for i = 1:n_params
    p_idx = param_indices(i);
    param_name = param_names{p_idx};
    
    subplot(2, 4, i);
    
    % Plot histogram with counts (not probability)
    histogram(samples(p_idx, :), 30, 'FaceColor', [0.3, 0.6, 0.8], ...
              'EdgeColor', 'white', 'FaceAlpha', 0.7);
    hold on;
    
    % Mark original virus baseline values on x-axis
    baseline_values = baseline_matrix(p_idx, :);
    y_max = max(histcounts(samples(p_idx, :), 30)) * 1.25;
    
    for v = 1:4
        % Add vertical line
        line([baseline_values(v), baseline_values(v)], [0, y_max * 0.75], ...
             'Color', virus_colors{v}, 'LineWidth', 2.5, 'LineStyle', '--');
        
        % Check if this baseline value is too close to any previous one
        offset = 0;
        threshold = (max(baseline_values) - min(baseline_values)) * 0.05; % 5% of total range
        for prev_v = 1:v-1
            if abs(baseline_values(v) - baseline_values(prev_v)) < threshold
                % If current is to the right of previous, offset right; otherwise offset left
                if baseline_values(v) > baseline_values(prev_v)
                    offset = 0.05 * (max(baseline_values) - min(baseline_values));
                else
                    offset = -0.05 * (max(baseline_values) - min(baseline_values));
                end
                break;
            end
        end
        
        % Add virus name label with possible horizontal offset
        text(baseline_values(v) + offset, y_max * 0.82, source_viruses{v}, ...
             'HorizontalAlignment', 'center', 'FontSize', 14, ...
             'Color', virus_colors{v}, 'FontWeight', 'bold', ...
             'Rotation', 90);
    end
    
    hold off;
    
    % Set x-axis label based on parameter
    if contains(param_name, 'pa') || contains(param_name, 'k')
        xlabel('Proportion', 'FontSize', 20);
    else
        xlabel('Days', 'FontSize', 20);
    end
    
    if mod(i, 4) == 1
        ylabel('Count', 'FontSize', 20);
    end

    
    title(param_name, 'FontSize', 20, 'FontWeight', 'bold');
    
    grid on;
    box on;
    set(gca, 'FontSize', 18);
    ylim([0, y_max]);
    xrg = (HybridVirus.pert_max(p_idx) - HybridVirus.pert_min(p_idx)) * 0.1;
    xlim([HybridVirus.pert_min(p_idx) - xrg, HybridVirus.pert_max(p_idx) + xrg]);
end

% Tighten subplot spacing
set(gcf, 'Color', 'white');
for i = 1:n_params
    subplot(2, 4, i);
    pos = get(gca, 'Position');
    % Reduce gaps between subplots
    pos(1) = 0.06 + mod(i-1, 4) * 0.235;   % Adjust horizontal position
    pos(2) = 0.54 - floor((i-1)/4) * 0.45; % Adjust vertical position
    pos(3) = 0.20;  % Width
    pos(4) = 0.35;  % Height
    set(gca, 'Position', pos);
end

% Add suptitle
sgtitle('Hybrid Virus Parameter Distributions (PERT Sampling from 4 Source Viruses)', ...
        'FontSize', 22, 'FontWeight', 'bold');

% Save figure (commented out - uncomment if needed)
% set(gcf, 'Units', 'inches', 'PaperPosition', [0 0 10 6]);
% saveas(gcf, fullfile(code_folder, 'Hybrid_Virus_Histograms.png'));

end

function fig = plot_capacity_exceedance(Fig3_results_cell)
% Plot hospital capacity exceedance probability curves (beautified version)
%
% Input:
%   Fig3_results_cell - 4x5 cell array containing results for each virus and capacity threshold
%
% Output:
%   fig - Figure handle

% Create figure window with clean white background
fig = figure('Position', [100, 100, 1200, 950], 'Color', 'white');

% Use aesthetically pleasing color scheme (from colorbrewer2.org Set1)
colors = {[0.894, 0.102, 0.110], ...  % Red
          [0.216, 0.494, 0.722], ...  % Blue
          [0.302, 0.686, 0.290], ...  % Green
          [0.596, 0.306, 0.639], ...  % Purple
          [1.000, 0.498, 0.000]};     % Orange

% Capacity labels for legend
capacity_labels = {'57 beds', '140 beds', '283 beds', '446 beds', '736 beds'};

% Virus names with detailed descriptions
virus_names = {'(A) Low transmissibility and low severity (H1N1pdm09)', ...
               '(B) Low transmissibility and high severity (Ebola)', ...
               '(C) High transmissibility and low severity (SARS-CoV-2)', ...
               '(D) High transmissibility and high severity (SARS-CoV-1)'};

% Y-axis label
y_label = sprintf('Community care facility capacity \n (%% of traditional hospital capacity)');

% Loop through all 4 viruses
for virus = 1:4
    subplot(2, 2, virus);
    hold on;
    
    % Plot curves for different hospital capacities
    for th = 1:5
        Results = Fig3_results_cell{virus, th};
        p = Results(:, 1);              % Column 1: Probability p
        fc = Results(:, end);           % Last column: fc_impl_prop
        
        % Plot smooth curve with beautiful colors
        plot(p, fc, 'Color', colors{th}, 'LineWidth', 2.5, ...
             'DisplayName', capacity_labels{th});
        
        % Add subtle filled area below the curve for visual appeal
        fill([p; flip(p)], [fc; zeros(size(fc))], colors{th}, ...
             'FaceAlpha', 0.15, 'EdgeColor', 'none', ...
             'HandleVisibility', 'off');
    end
    
    hold off;
    
    % Configure axes
    set(gca, 'XDir', 'reverse');        % Reverse x-axis direction
    xlim([0, 1]);
    xticks(0:0.1:1); % Set x-axis ticks as percentages (10% intervals)
    xticklabels({'0%', '10%', '20%', '30%', '40%', '50%', '60%', '70%', '80%', '90%', '100%'});
    xtickangle(0);                      % Horizontal x-axis labels

    % Set y-axis ticks dynamically based on data range
    ylimits = ylim;
    y_max = ylimits(2);
    yticks(0:0.1:y_max);
    yticklabels(arrayfun(@(x) sprintf('%d%%', x*100), 0:0.1:y_max, 'UniformOutput', false));
    ytickangle(0);

    % Set x-label only for subplots 3 and 4 (bottom row)
    if virus == 3 || virus == 4
        xlabel('Overload probability', 'FontSize', 16, 'FontWeight', 'bold');
    end
    
    % Set y-label only for subplots 1 and 3 (left column)
    if virus == 1 || virus == 3
        ylabel(y_label, 'FontSize', 16, 'FontWeight', 'bold');
    end
    
    t = title(virus_names{virus}, 'FontSize', 18, 'FontWeight', 'bold');
    t.Position(2) = t.Position(2) + 0.01;  % Move title up
    
    % Beautify axes appearance - remove top and right borders
    set(gca, 'FontSize', 16, 'FontName', 'Arial', ...
             'Box', 'off', 'LineWidth', 1.2, ...
             'TickDir', 'out', 'TickLength', [0.02, 0.02]);
    grid on;
    set(gca, 'GridLineStyle', '--', 'GridAlpha', 0.3);
    
    % Add legend in top-left corner only for the first subplot
    if virus == 1
        lgd = legend('Location', 'northwest', 'FontSize', 16, 'Box', 'off');
        lgd.Title.String = 'Traditional hospital capacity';
        lgd.Title.FontSize = 16;
        lgd.Title.FontWeight = 'bold';
        set(lgd, 'String', capacity_labels);
    else
        legend off;
    end
end

% Adjust subplot spacing for better layout
for i = 1:4
    subplot(2, 2, i);
    pos = get(gca, 'Position');
    if i == 1 || i == 2
        pos(2) = 0.56;
    else
        pos(2) = 0.09;
    end
    pos(3) = 0.38;  % Width
    pos(4) = 0.38;  % Height
    set(gca, 'Position', pos);
end

end

function fig = plot_overload_probability_bars(Fig3_results_cell)
% Plot overload probability bar charts (beautified version)
%
% Input:
%   Fig3_results_cell - 4x5 cell array containing results for each virus and capacity threshold
%                       Each cell is a 14x7 matrix, first three columns: [mean, lower, upper]
%                       Column 7: fc_impl_prop = [0:0.04:0.48 0.5] (14 values total)
%
% Output:
%   fig - Figure handle

% Row indices to extract (corresponding to fc_impl_prop = 0, 0.08, 0.16, 0.32, 0.50)
target_props = [0, 0.08, 0.16, 0.32, 0.50];
fc_prop_full = [0:0.04:0.48 0.5];

% Find row indices
target_rows = zeros(1, length(target_props));
for i = 1:length(target_props)
    target_rows(i) = find(abs(fc_prop_full - target_props(i)) < 1e-10);
end

% Virus names and colors
viruses = {'Influenza', 'Ebola', 'SARS-CoV-2', 'SARS-CoV-1'};
virus_colors = {[0.216, 0.494, 0.722], ...  % Blue
                [0.894, 0.102, 0.110], ...  % Red
                [0.302, 0.686, 0.290], ...  % Green
                [0.596, 0.306, 0.639]};     % Purple

% Traditional hospital capacity set
Cap_H = [57, 140, 283, 446, 736];

% Create figure
fig = figure('Position', [300, 100, 1000, 1000], 'Color', 'white');

% Loop over each subplot (5 rows of Cap_H)
for col = 1:5
    subplot(5, 1, col);
    
    % Store data for current column (4 viruses)
    means = zeros(4, 5);
    lows  = zeros(4, 5);
    highs = zeros(4, 5);
    
    for virus_idx = 1:4
        data_matrix = Fig3_results_cell{virus_idx, col};
        means(virus_idx, :) = data_matrix(target_rows, 1)';
        lows(virus_idx, :)  = data_matrix(target_rows, 2)';
        highs(virus_idx, :) = data_matrix(target_rows, 3)';
    end
    
    % Draw grouped bar chart
    x = 1:4;
    bar_width = 0.14;
    x_offset = linspace(-0.28, 0.28, 5);
    
    hold on;
    
    for virus_idx = 1:4
        x_pos = x(virus_idx) + x_offset;
        
        for prop_idx = 1:5
            % Create bar
            bar(x_pos(prop_idx), means(virus_idx, prop_idx), bar_width, ...
                'FaceColor', virus_colors{virus_idx}, ...
                'EdgeColor', 'white', ...
                'LineWidth', 0.5, ...
                'FaceAlpha', 0.8);
            
            % Add error bar
            errorbar(x_pos(prop_idx), means(virus_idx, prop_idx), ...
                     means(virus_idx, prop_idx) - lows(virus_idx, prop_idx), ...
                     highs(virus_idx, prop_idx) - means(virus_idx, prop_idx), ...
                     'Color', [0.2, 0.2, 0.2], ...
                     'LineStyle', 'none', ...
                     'LineWidth', 1.2, ...
                     'CapSize', 8);
        end
    end
    
    hold off;
    
    % Set plot properties
    xlim([0.5, 4.5]);
    ylim([0, 1]);
    xticks(1:4);
    xticklabels(viruses);
    xtickangle(0);
    
    % Add labels
    if col == 5
        xlabel('Virus type', 'FontSize', 14, 'FontWeight', 'bold');
    end
    
    ylabel('Overload probability', 'FontSize', 13, 'FontWeight', 'bold');
    title(sprintf('Traditional hospital capacity: %d beds', Cap_H(col)), ...
          'FontSize', 14, 'FontWeight', 'bold');
    
    % Beautify axes appearance
    set(gca, 'FontSize', 11, 'FontName', 'Arial', ...
             'Box', 'off', 'LineWidth', 1.2, ...
             'TickDir', 'out', 'TickLength', [0.01, 0.01]);
    grid on;
    set(gca, 'GridLineStyle', '--', 'GridAlpha', 0.25);
    
    % Set y-axis ticks as percentages
    yticks(0:0.2:1);
    yticklabels({'0%', '20%', '40%', '60%', '80%', '100%'});
    ylim([0, 1]);
end

% Add text note about Fangcang proportions (bottom of figure)
annotation('textbox', [0.15, 0.02, 0.7, 0.03], ...
           'String', 'Note: For each virus, bars from left to right represent Fangcang implementation proportions: 0%, 8%, 16%, 32%, and 50%', ...
           'FontSize', 11, ...
           'FontName', 'Arial', ...
           'HorizontalAlignment', 'right', ...
           'LineStyle', 'none', ...
           'FontWeight', 'normal');

% Add overall title
sgtitle('Overload Probability by Virus Type and Fangcang Implementation Proportion', ...
        'FontSize', 16, 'FontWeight', 'bold');

end

