

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
mat_files = dir(fullfile(code_folder, 'fc_model_parameter_*.mat'));

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
    output_file = fullfile(code_folder, ['fc_model_parameter_' char(datetime('now', 'Format', 'yyyyMMdd')) '.mat']);
    save(output_file, 'Par_profile', 'NS', 'pct_variation', 'virus_names', 'viruses');
    fprintf('Saved new parameter samples to: %s\n', output_file);
end

% Display sampling results
for i = 1:length(Par_profile)
    fprintf('\n=== %s ===\n', Par_profile{i}.name);
    disp(Par_profile{i});
end

%% ========== Master Script: Run All Three Analyses Together ==========
RUN_SIMULATION  = false;           % Set to true to run simulations, false to load existing results
NS =10000;
Pop = 100000;                      % Total population
dt = 1;                            % Time step (days)
Ini_E = Pop * 0.00020;             % Initial exposed (0.02% of population)
t = 0:100;                         % Time horizon (101 days)
y0 = [Pop - Ini_E, Ini_E, 0, 0, 0, 0, 0, 0, 0, 0, 0]; % State variables: [S, E, U, A, F1, F2, F3, H1, H2, H3, R]
Cap_H = [57, 140, 283, 446, 736];  % Traditional hospital capacities

% For Fig5
pa_range = sort([0:0.05:1, 0.23]); % 22 values: proportion of severe cases (baseline=0.23)
t_care_range = 1:0.5:7;            % 13 values: time to seek care (days, baseline=6.5)

% For FigS3
R0_values = linspace(1.25, 3.70, 10);    % 10 R0 values (basic reproduction number)
ps_values = linspace(0.038, 0.967, 10);  % 10 ps values (proportion asymptomatic)

fprintf('==================== Combined Analysis Started ====================\n');
fprintf('Date: %s\n\n', datestr(now));

if RUN_SIMULATION
    % ========== FIGURE 3: Main Simulation (4 viruses × 5 capacities) ==========
    fprintf('========== FIGURE 3: Main Simulation ==========\n');
    fig3_start = tic;
    fc_impl_prop = [0:0.04:0.48, 0.5];  % FC proportions (0%, 4%, 8%, ..., 50%)
    Fig3_results = cell(4, 5);          % {virus, capacity}
    
    for virus = 1:4
        fprintf('Processing Virus %d/4...\n', virus);
        Par_sam0 = Par_profile{virus}.samples;
        
        for th = 1:5
            H_cap = Cap_H(th) * (1 - 0.714);            % Traditional hospital capacity after reduction
            Results = zeros(length(fc_impl_prop), 13);  % 13-column result matrix
            
            for i = 1:length(fc_impl_prop)
                F_cap = Cap_H(th) * fc_impl_prop(i);    % fc hospital capacity
                XH1 = zeros(NS, 1);                     % Capacity exceedance indicator
                XH2 = zeros(NS, 1);                     % Total infected population
                
                % Parallel simulation over all parameter sets
                parfor Pnum = 1:NS
                    Par_bas0 = Par_sam0(Pnum, 1:10)';
                    X1 = fc_model(t, y0, dt, H_cap, F_cap, Par_bas0);
                    XH1(Pnum) = any(sum(X1(:, 8:10), 2) >= H_cap);  % H1+H2+H3 >= capacity
                    XH2(Pnum) = Pop - X1(end, 1);                   % Total infected = Pop - final S
                end
                
                % Calculate statistics
                p = mean(XH1);                                      % Probability of capacity exceedance
                CI = p + [-1.96, 1.96] * sqrt(p*(1-p)/NS);          % 95% CI for proportion
                inf_mean = mean(XH2,'omitnan');                     % Mean infected population
                inf_CI = prctile(XH2, [2.5, 97.5]);                 % 95% CI for infected
                
                if i == 1
                    % Reference group (FC = 0)
                    [p0, XH20] = deal(p, XH2);
                    Results(i, :) = [p, CI, inf_mean, inf_CI, zeros(1,6), fc_impl_prop(i)];
                else
                    % Difference from reference group
                    diff_p = p - p0;                               % Difference in probability
                    diff_CI = diff_p + [-1.96, 1.96] * sqrt(p0*(1-p0)/NS + p*(1-p)/NS);
                    diff_inf = mean(XH2 - XH20, 'omitnan');        % Mean difference in infected
                    diff_inf_CI = prctile(XH2 - XH20, [2.5, 97.5]);
                    Results(i, :) = [p, CI, inf_mean, inf_CI, diff_p, diff_CI, diff_inf, diff_inf_CI, fc_impl_prop(i)];
                end
            end
            Fig3_results{virus, th} = Results;
            fprintf('  Capacity %d/5 done\n', th);
        end
    end
    fprintf('Fig3 completed. Time: %.2f seconds\n\n', toc(fig3_start));
    
    % ========== FIGURE 4: Sensitivity Analysis (22×13 cell) ==========
    fprintf('========== FIGURE 4: Sensitivity Analysis ==========\n');
    fig4_start = tic;
    Par_sam0 = Par_profile{3}.samples;  % Use SARS2 parameters
    Fig4_results = cell(length(pa_range), length(t_care_range));  % 22×13 cell
    
    for i_pa = 1:length(pa_range)
        pa = pa_range(i_pa);
        for i_tc = 1:length(t_care_range)
            t_care = t_care_range(i_tc);
            
            % Results matrix: 4 rows (FC=0%, FC=50%) × 14 columns
            Results = zeros(4, 14);
            for i = 1:4  
                if i<=2
                    Cap_FH = Cap_H(3); % Use median capacity (283 beds) 
                    fc_prop = (i - 1) * 0.5;
                else
                    Cap_FH = Cap_H(5); % Use median capacity (736 beds)
                    fc_prop = (i - 3) * 0.5;
                end
                
                H_cap = Cap_FH * (1 - 0.714);     
                F_cap = Cap_FH * fc_prop;
                XH1     = zeros(NS, 1);
                XH2     = zeros(NS, 1);
                parfor Pnum = 1:NS
                    Par_bas0 = Par_sam0(Pnum, 1:10)';
                    % Extract additional parameters for sensitivity analysis
                    T1 = Par_sam0(Pnum, 11); T2 = Par_sam0(Pnum, 12); T3 = Par_sam0(Pnum, 13);
                    P1 = Par_sam0(Pnum, 14); P2 = Par_sam0(Pnum, 15); D4 = Par_sam0(Pnum, 20);
                    
                    % Calculate derived parameters
                    tau_m = T3 - t_care;
                    tau_p = D4 - t_care;
                    tau_h = (T1*P1 + T2*P2)/(P1 + P2) - t_care - tau_p;
                    
                    % Update parameters: pa, t_care, tau_m, tau_p, tau_h
                    if ~(pa == 0.23 && t_care == 6.5)
                        Par_bas0([3, 7:10]) = [pa, t_care, tau_m, tau_p, tau_h];
                    end
                    X1 = fc_model(t, y0, dt, H_cap, F_cap, Par_bas0);
                    XH1(Pnum) = any(sum(X1(:, 8:10), 2) >= H_cap);
                    XH2(Pnum) = Pop - X1(end, 1);
                end
                
                % Calculate statistics
                p  = mean(XH1);
                CI = p + [-1.96, 1.96] * sqrt(p*(1-p)/NS);
                inf_mean = mean(XH2,'omitnan');
                inf_CI = prctile(XH2, [2.5, 97.5]);
                
                if fc_prop == 0
                    % Reference group (FC = 0)
                    [p0, XH20] = deal(p, XH2);
                    Results(i, :) = [p, CI, inf_mean, inf_CI, zeros(1,6), fc_prop, Cap_FH];
                else
                    % Difference from reference (FC=50% vs FC=0%)
                    diff_p = p - p0;
                    diff_CI = diff_p + [-1.96, 1.96] * sqrt(p0*(1-p0)/NS + p*(1-p)/NS);
                    diff_inf = mean(XH2 - XH20, 'omitnan');
                    diff_inf_CI = prctile(XH2 - XH20, [2.5, 97.5]);
                    Results(i, :) = [p, CI, inf_mean, inf_CI, diff_p, diff_CI, diff_inf, diff_inf_CI, fc_prop, Cap_FH];
                end
            end
            Fig4_results{i_pa, i_tc} = Results;
        end
        fprintf('pa = %.2f done (%d/%d)\n', pa, i_pa, length(pa_range));
    end
    fprintf('Fig4 completed. Time: %.2f seconds\n\n', toc(fig4_start));

    % ========== FIGURE S3: Unknown Virus Analysis (10×10 cell) ==========
    fprintf('========== FIGURE S3: Unknown Virus Analysis ==========\n');
    figS3_start = tic;

    Par_sam0 = Par_profile{3}.samples;       % Use SARS2 as template
    FigS3_results = cell(length(R0_values), length(ps_values));  % 10×10 cell
    
    for i_R0 = 1:length(R0_values)
        R0 = R0_values(i_R0);
        for i_ps = 1:length(ps_values)
            ps = ps_values(i_ps);
            
            % Results matrix: 4 rows (FC=0%, FC=50%) × 14 columns
            Results = zeros(4, 14);
            for i = 1:4  
                if i<=2
                    Cap_FH = Cap_H(3); % Use median capacity (283 beds) 
                    fc_prop = (i - 1) * 0.5;
                else
                    Cap_FH = Cap_H(5); % Use median capacity (736 beds)
                    fc_prop = (i - 3) * 0.5;
                end
                
                H_cap = Cap_FH * (1 - 0.714);     
                F_cap = Cap_FH * fc_prop;
                XH1     = zeros(NS, 1);
                XH2     = zeros(NS, 1);
                
                parfor Pnum = 1:NS
                    Par_bas0 = Par_sam0(Pnum, 1:10)';
                    % Update R0 and ps for unknown virus scenario 
                    Par_bas0(1) = R0;  % Set R0
                    Par_bas0(2) = ps;  % Set proportion asymptomatic
                    
                    X1 = fc_model(t, y0, dt, H_cap, F_cap, Par_bas0);
                    XH1(Pnum) = any(sum(X1(:, 8:10), 2) >= H_cap);
                    XH2(Pnum) = Pop - X1(end, 1);
                end
                
                % Calculate statistics
                p = mean(XH1);
                CI = p + [-1.96, 1.96] * sqrt(p*(1-p)/NS);
                inf_mean = mean(XH2,'omitnan');
                inf_CI = prctile(XH2, [2.5, 97.5]);
                
                if fc_prop == 1
                    % Reference group (FC = 0)
                    [p0, XH20] = deal(p, XH2);
                    Results(i, :) = [p, CI, inf_mean, inf_CI, zeros(1,6), fc_prop, Cap_FH];
                else
                    % Difference from reference (FC=50% vs FC=0%)
                    diff_p = p - p0;
                    diff_CI = diff_p + [-1.96, 1.96] * sqrt(p0*(1-p0)/NS + p*(1-p)/NS);
                    diff_inf = mean(XH2 - XH20, 'omitnan');
                    diff_inf_CI = prctile(XH2 - XH20, [2.5, 97.5]);
                    Results(i, :) = [p, CI, inf_mean, inf_CI, diff_p, diff_CI, diff_inf, diff_inf_CI, fc_prop, Cap_FH];
                end
            end
            FigS3_results{i_R0, i_ps} = Results;
        end
        fprintf('R0 = %.2f done (%d/%d)\n', R0, i_R0, length(R0_values));
    end
    fprintf('FigS3 completed. Time: %.2f seconds\n\n', toc(figS3_start));
    
    % ========== Save All Results ==========
    timestamp = datestr(now, 'yyyymmdd');
    filename  = sprintf('fc_model_result_%s.mat', timestamp);
    save_path = fullfile(code_folder, filename);
    save(save_path, 'Fig3_results', 'Fig4_results', 'FigS3_results', '-v7.3');

    total_time = toc(start_time);
    fprintf('\n==================== ALL COMPLETED ====================\n');
    fprintf('Results saved to: %s\n', save_path);
    fprintf('Total run time: %.2f seconds (%.2f minutes)\n', total_time, total_time/60);
    
else
    % Load existing results
    fprintf('Loading existing results...\n');
    mat_files = dir(fullfile(code_folder, 'fc_model_result_*.mat'));
    if ~isempty(mat_files)
        [~, idx] = max([mat_files.datenum]);
        load(fullfile(code_folder, mat_files(idx).name));
        fprintf('Loaded: %s\n', mat_files(idx).name);
    else
        error('No existing results found. Set RUN_SIMULATION = true to run simulations.');
    end
end

%%
% HybridVirus = Par_profile{5};
% fig_S2 = plot_hybrid_virus_histograms(HybridVirus);
% set(fig_S2, 'Units', 'inches', 'PaperPosition', [0 0 10 6]);
% saveas(fig_S2, fullfile(code_folder, 'Hybrid_Virus_Histograms.png'));

 fig3  = plot_capacity_exceedance(Fig3_results);
% fig3s = plot_overload_probability_bars(Fig3_results);
[table1, table2, tableS] = generate_table(Fig3_results);
fig4 = plot_sensitivity_heatmap(Fig4_results, pa_range, t_care_range);
figS3 = plot_unknown_virus_analysis(FigS3_results, R0_values, ps_values);

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
capacity_labels = {'Low (57/100,000 populaiton)', ...
                   'Low-middle (140/100,000 populaiton)', ...
                   'Moderate (283/100,000 populaiton)', ...
                   'Moderate-high (446/100,000 populaiton)', ...
                   'High (736/100,000 populaiton)'};

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
    % set(gca, 'XDir', 'reverse');        % Reverse x-axis direction
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
    set(gca, 'FontSize', 16, 'FontName', 'Times New Roman', ...
             'Box', 'off', 'LineWidth', 1.2, ...
             'TickDir', 'out', 'TickLength', [0.02, 0.02]);
    grid on;
    set(gca, 'GridLineStyle', '--', 'GridAlpha', 0.3);
    
    % Add legend in top-left corner only for the first subplot
    if virus == 1
        lgd = legend('Location', 'northeast', 'FontSize', 16, 'Box', 'off');
        lgd.Title.String = 'Traditional hospital capacity level';
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
    
    ylabel('Overload probability', 'FontSize', 13, 'FontWeight', 'bold');
    title(sprintf('Traditional hospital capacity: %d beds per 100,000 population', Cap_H(col)), ...
          'FontSize', 28, 'FontWeight', 'bold');
    
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
annotation('textbox', [0.05, 0.02, 0.7, 0.03], ...
           'String', 'Note: For each pathogen, bars from left to right represent implementation proportions: 0%, 8%, 16%, 32%, and 50%', ...
           'FontSize', 12, ...
           'FontName', 'Arial', ...
           'HorizontalAlignment', 'right', ...
           'LineStyle', 'none', ...
           'FontWeight', 'normal');

end

function [table1, table2, tableS] = generate_table(Fig3_results)
% Generate three formatted tables from Fig3_results
% Input: Fig3_results - 5-column cell array
% Output: table1 - 25×5 cell array (mode a: r=1 uses cols1-3, else cols7-9)
%         table2 - 25×5 cell array (mode a1: always uses cols1-3)
%         tableS - 25×5 cell array (mode a2: r=1 uses cols4-6, else col10/col4 ratio)

ratios = [0, 0.08, 0.16, 0.32, 0.50];
table1 = cell(25,5);
table2 = cell(25,5);
tableS = cell(25,5);

for col = 1:5
    data_col = Fig3_results(:, col);
    t1_0 = cell(4,5);
    t2_0 = cell(4,5);
    tS_0 = cell(4,5);
    
    for row = 1:4
        M = data_col{row};  % 14×13 matrix
        
        for r = 1:5
            % Find row matching target ratio
            idx = find(abs(M(:,13) - ratios(r)) < 0.001, 1);
            if isempty(idx), continue; end
            
            % Common values for table1 and table2 (columns 1-3)
            val1 = abs(M(idx,1)); 
            val2 = abs(M(idx,2)); 
            val3 = abs(M(idx,3));
            str_common = sprintf('%.1f%% (%.1f-%.1f%%)', val1*100, val2*100, val3*100);
            
            % Table2 (original a1): always use cols 1-3
            t2_0{row,r} = str_common;
            
            % Table1 (original a): use cols 1-3 for r=1, otherwise cols 7-9
            if r == 1
                t1_0{row,r} = str_common;
            else
                t1_0{row,r} = sprintf('%.1f%% (%.1f-%.1f%%)', ...
                    abs(M(idx,7))*100, abs(M(idx,9))*100, abs(M(idx,8))*100);
            end
            
            % TableS (original a2): use cols 4-6 for r=1, otherwise col10/col4 ratio
            if r == 1
                tS_0{row,r} = sprintf('%.0f (%.0f-%.0f)', ...
                    abs(M(idx,4)), abs(M(idx,5)), abs(M(idx,6)));
            else
                tS_0{row,r} = sprintf('%.1f%%', abs(M(idx,10))/abs(M(idx,4))*100);
            end
        end
    end
    % Assemble 5-column blocks into final 25×5 arrays
    table1(col*5-3:col*5, :) = t1_0;
    table2(col*5-3:col*5, :) = t2_0;
    tableS(col*5-3:col*5, :) = tS_0;
end
end

function fig = plot_sensitivity_heatmap(Fig4_results, pa_range, t_care_range)
% ========== Plot Figure 4: Sensitivity Analysis Heatmap ==========
% Plot probability of hospital capacity exceedance as function of pa and t_care
% Subplot 1: FC = 0%, Subplot 2: FC = 50%
%
% Input arguments:
%   Fig4_results - Cell array containing probability results
%                  Format: {i,j} = [P_FC0, P_FC50] or [P_FC0; P_FC50]
%   pa_range - Vector of p_a parameter values
%   t_care_range - Vector of t_care parameter values
%
% Output:
%   fig - Figure handle
% Set baseline parameters
pa_baseline = 0.23;
t_care_baseline = 6.5;

% Extract probability for both FC scenarios
n_pa = size(Fig4_results, 1);
n_tc = size(Fig4_results, 2);
prob_all = zeros(n_pa, n_tc, 4);  % 3D array: [pa, tc, fc_idx]

for i = 1:n_pa
    for j = 1:n_tc
        prob_all(i, j, 1) = Fig4_results{i, j}(3, 1) * 100;  % FC = 0%
        prob_all(i, j, 2) = Fig4_results{i, j}(4, 1) * 100;  % FC = 50%
        prob_all(i, j, 3) = Fig4_results{i, j}(1, 1) * 100;  % FC = 0%
        prob_all(i, j, 4) = Fig4_results{i, j}(2, 1) * 100;  % FC = 50%
    end
end

% Find baseline indices
[~, idx_pa] = min(abs(pa_range - pa_baseline));
[~, idx_tc] = min(abs(t_care_range - t_care_baseline));
baseline_values = squeeze(prob_all(idx_pa, idx_tc, :));

% Create figure with 2x2 subplots
fig = figure('Position', [250, 100, 1000, 900]);
fc_titles = {'(A) Cap_H = 736/100,000 population, FC = 0%', ...
    '(B) Cap_H = 736/100,000 population, FC = 50%', ...
    '(C) Cap_H = 283/100,000 population, FC = 0%', ...
    '(D) Cap_H = 283 /100,000 population, FC = 50%'};

for fc_idx = 1:4
    subplot(2, 2, fc_idx);
    pos_x = 0.03 + 0.40 * mod(fc_idx-1, 2);
    pos_y = 0.55 - 0.47 * floor((fc_idx-1)/2);
    set(gca, 'Position', [pos_x, pos_y, 0.50, 0.39]);

    prob_percent = prob_all(:, :, fc_idx);
    % Filled contour
    contourf(pa_range, t_care_range, prob_percent', 20, 'LineColor', 'none');
    hold on;
    
    % Contour lines with labels
    [M, c] = contour(pa_range, t_care_range, prob_percent', [10, 30, 50, 70, 90], ...
                     'ShowText', 'on', 'LineColor', [0.5 0.5 0.5], 'LineWidth', 0.6);
    clabel(M, c, 'FontSize', 10, 'Color', [0.3 0.3 0.3], 'FontName', 'Times New Roman');
    
    % Colorbar
    cmap_full = parula(256);
    cmap_mid  = cmap_full(80:250,:);
    colormap(cmap_mid); 
    caxis([0, 100]);
    if mod(i, 3)==1
        bar_c = colorbar; 
        set(bar_c, Position = [0.895,0.08,0.017,0.860]);
        annotation('textbox',[0.863,0.915,0.1,0.1], String = sprintf('Overload\n probability (%%)'),...
            HorizontalAlignment='center', VerticalAlignment='middle', ...
            FontName = 'Times New Roman', FontSize = 15, EdgeColor='none');
        set(bar_c, 'FontSize', 13, 'FontName', 'Times New Roman');
    end 
    
    % Labels and title
    if fc_idx > 2
        xlabel('p_a (Proportion of cases who are eventually ascertained)', 'FontSize', 13, 'FontName', 'Times New Roman');
    end
    
    if mod(fc_idx, 2) == 1
        ylabel('1/{\phi}_H (Time from symptom onset to admission, days)', 'FontSize', 13, 'FontName', 'Times New Roman');
    end
    
    title(fc_titles{fc_idx}, 'FontSize', 14, 'FontWeight', 'bold', 'FontName', 'Times New Roman');
    
    % Axis settings
    set(gca, 'FontSize', 15, 'FontName', 'Times New Roman');
    set(gca, 'YDir', 'normal');
    xlim([min(pa_range), max(pa_range)]);
    ylim([min(t_care_range), max(t_care_range)]);
    axis square;
    
    % Mark baseline point
    plot(pa_baseline, t_care_baseline, 'rp', 'MarkerSize', 16, 'LineWidth', 2, 'MarkerFaceColor', 'r');
    
    % Dashed lines to axes
    plot([pa_baseline, pa_baseline], [min(t_care_range), t_care_baseline], ...
         'r--', 'LineWidth', 1.2, 'Color', [0.8 0.2 0.2]);
    plot([min(pa_range), pa_baseline], [t_care_baseline, t_care_baseline], ...
         'r--', 'LineWidth', 1.2, 'Color', [0.8 0.2 0.2]);
    
    % Baseline annotation
    text(pa_baseline + 0.03, t_care_baseline - 0.15, ...
    sprintf(['Baseline (p_a = %.2f, 1/φ_H = %.1f days):\n', ...
             'Overload probability = %.1f%%'], ...
    pa_baseline, t_care_baseline, baseline_values(fc_idx)), ...
    'FontSize', 12, 'Color', 'r', 'FontName', 'Times New Roman', ...
    'FontWeight', 'bold');

    % Calculate new point coordinates
    pa_new = (pa_baseline + 1) / 2;
    t_care_new = (t_care_baseline + 1) / 2;

    % Find indices for new point
    [~, idx_pa_new] = min(abs(pa_range - pa_new));
    [~, idx_tc_new] = min(abs(t_care_range - t_care_new));
    new_point_value = prob_all(idx_pa_new, idx_tc_new, fc_idx);

     % Mark new point
    plot(pa_new, t_care_new, 'rp', 'MarkerSize', 14, 'LineWidth', 2, 'MarkerFaceColor', 'r');

     % Dashed lines to axes for new point (optional)
    plot([pa_new, pa_new], [min(t_care_range), t_care_new], ...
         'r--', 'LineWidth', 1.2, 'Color', [0.8 0.2 0.2]);
    plot([min(pa_range), pa_new], [t_care_new, t_care_new], ...
         'r--', 'LineWidth', 1.2, 'Color', [0.8 0.2 0.2]);

     % New point annotation (optional)
    text(pa_new - 0.20, t_care_new + 0.4, ...
         sprintf('New point (p_a = %.2f, 1/φ_H = %.1f days):\nOverload probability = %.1f%%', ...
         pa_new, t_care_new, new_point_value), ...
         'FontSize', 12, 'Color', 'r', 'FontName', 'Times New Roman', ...
         'FontWeight', 'bold', 'BackgroundColor', 'none');
end

% Print statistics to command window
fprintf('\n========== Sensitivity Analysis Results Summary ==========\n');
fprintf('Parameter ranges:\n');
fprintf('  p_a: [%.2f, %.2f] (baseline: %.2f), %d points\n', ...
        pa_range(1), pa_range(end), pa_baseline, length(pa_range));
fprintf('  t_care: [%.1f, %.1f] days (baseline: %.1f), %d points\n', ...
        t_care_range(1), t_care_range(end), t_care_baseline, length(t_care_range));
fprintf('\nProbability of capacity exceedance:\n');
fprintf('  FC = 0%%:  Range [%.1f%%, %.1f%%], Baseline: %.1f%%\n', ...
        min(prob_all(:,:,1), [], 'all'), max(prob_all(:,:,1), [], 'all'), baseline_values(1));
fprintf('  FC = 50%%: Range [%.1f%%, %.1f%%], Baseline: %.1f%%\n', ...
        min(prob_all(:,:,2), [], 'all'), max(prob_all(:,:,2), [], 'all'), baseline_values(2));
fprintf('  Reduction at baseline: %.1f percentage points\n', baseline_values(1) - baseline_values(2));
fprintf('================================================================\n');

end

function fig = plot_unknown_virus_analysis(FigS3_results, R0_values, ps_values)
% ========== Plot Figure S2: Unknown Virus Analysis ==========
% Plot probability of hospital capacity exceedance as function of R0 and ps
% Subplot 1: FC = 0%, Subplot 2: FC = 50%
%
% Input arguments:
%   FigS2_results - Cell array containing probability results
%                   Format: {i,j} = [P_FC0, P_FC50] or [P_FC0; P_FC50]
%   R0_values - Vector of R0 parameter values
%   ps_values - Vector of ps parameter values (proportion of severe cases)
%
% Output:
%   fig - Figure handle

% Input validation
if nargin < 3
    error('Error: All three input arguments (FigS2_results, R0_values, ps_values) are required.');
end

% Validate FigS2_results is a cell array
if ~iscell(FigS3_results)
    error('Error: FigS2_results must be a cell array.');
end

% Validate R0_values and ps_values are vectors
if ~isvector(R0_values) || ~isvector(ps_values)
    error('Error: R0_values and ps_values must be vectors.');
end

% Check dimensions match
n_R0_expected = length(R0_values);
n_ps_expected = length(ps_values);
[n_R0_actual, n_ps_actual] = size(FigS3_results);

if n_R0_actual ~= n_R0_expected || n_ps_actual ~= n_ps_expected
    warning('Dimension mismatch: FigS2_results is %dx%d but R0_values and ps_values suggest %dx%d', ...
            n_R0_actual, n_ps_actual, n_R0_expected, n_ps_expected);
end

% Extract probability for both FC scenarios
n_R0 = size(FigS3_results, 1);
n_ps = size(FigS3_results, 2);
probS2_all = zeros(n_R0, n_ps, 4);  % 3D array: [R0, ps, fc_idx]

for i = 1:n_R0
    for j = 1:n_ps
        % Check if cell contains valid data
        if isempty(FigS3_results{i, j})
            warning('Empty cell at position (%d, %d), skipping...', i, j);
            continue;
        end
        probS2_all(i, j, 1) = FigS3_results{i, j}(3, 1) * 100;  % FC = 0%
        probS2_all(i, j, 2) = FigS3_results{i, j}(4, 1) * 100;  % FC = 50%
        probS2_all(i, j, 3) = FigS3_results{i, j}(1, 1) * 100;  % FC = 0%
        probS2_all(i, j, 4) = FigS3_results{i, j}(2, 1) * 100;  % FC = 50%
    end
end

% Create figure with 1x2 subplots
fig = figure('Position', [250, 100, 1000, 900]);
fc_titles = {'(A) Cap_H = 736/100,000 population, FC = 0%', ...
    '(B) Cap_H = 736/100,000 population, FC = 50%', ...
    '(C) Cap_H = 283/100,000 population, FC = 0%', ...
    '(D) Cap_H = 283 /100,000 population, FC = 50%'};


for fc_idx = 1:4
    subplot(2, 2, fc_idx);
    pos_x = 0.03 + 0.40 * mod(fc_idx-1, 2);
    pos_y = 0.55 - 0.47 * floor((fc_idx-1)/2);
    set(gca, 'Position', [pos_x, pos_y, 0.50, 0.39]);
    prob_percent = probS2_all(:, :, fc_idx);
    
    % Filled contour
    contourf(R0_values, ps_values, prob_percent', 20, 'LineColor', 'none');
    hold on;
    
    % Contour lines with labels
    [M, c] = contour(R0_values, ps_values, prob_percent', [10, 30, 50, 70, 90], ...
                     'ShowText', 'on', 'LineColor', [0.5 0.5 0.5], 'LineWidth', 0.6);
    clabel(M, c, 'FontSize', 11, 'Color', [0.3 0.3 0.3], 'FontName', 'Times New Roman');


    % Colorbar
    cmap_full = parula(256);
    cmap_mid  = cmap_full(80:250,:);
    colormap(cmap_mid); 
    caxis([0, 100]);
    if mod(i, 3)==1
        bar_c = colorbar; 
        set(bar_c, Position = [0.895,0.08,0.017,0.860]);
        annotation('textbox',[0.863,0.915,0.1,0.1], String = sprintf('Overload\n probability (%%)'),...
            HorizontalAlignment='center', VerticalAlignment='middle', ...
            FontName = 'Times New Roman', FontSize = 15, EdgeColor='none');
        set(bar_c, 'FontSize', 13, 'FontName', 'Times New Roman');
    end 

    % Labels and title
    if fc_idx > 2
        xlabel('R_0 (Basic reproduction number)', 'FontSize', 13, 'FontName', 'Times New Roman');
    end
    
    if mod(fc_idx, 2) == 1
        ylabel('p_s (Proportion of severe cases)', 'FontSize', 13, 'FontName', 'Times New Roman');
    end
    
    title(fc_titles{fc_idx}, 'FontSize', 14, 'FontWeight', 'bold', 'FontName', 'Times New Roman');

    
    % Axis settings
    set(gca, 'FontSize', 15, 'FontName', 'Times New Roman');
    set(gca, 'YDir', 'normal');
    xlim([min(R0_values), max(R0_values)]);
    ylim([min(ps_values), max(ps_values)]);
    axis square;
end


% Print statistics to command window
fprintf('\n========== FigS2 Results Summary ==========\n');
fprintf('Parameter ranges:\n');
fprintf('  R_0: [%.2f, %.2f]\n', R0_values(1), R0_values(end));
fprintf('  p_s: [%.1f%%, %.1f%%]\n', ps_values(1)*100, ps_values(end)*100);
fprintf('\nProbability of capacity exceedance:\n');
fprintf('  FC = 0%%:  Range [%.1f%%, %.1f%%]\n', ...
        min(probS2_all(:,:,1), [], 'all'), max(probS2_all(:,:,1), [], 'all'));
fprintf('  FC = 50%%: Range [%.1f%%, %.1f%%]\n', ...
        min(probS2_all(:,:,2), [], 'all'), max(probS2_all(:,:,2), [], 'all'));
fprintf('==========================================\n');


% ========== Extract R0 values at 10% and 90% probability contours ==========
% fprintf('\n========== R0 VALUES AT 10%% AND 90%% PROBABILITY ==========\n');
% 
% for fc_idx = 1:4  % 4 subplots
%     if fc_idx == 1
%         prob_data = probS2_all(:, :, 1);
%         cap_label = 'Cap_H=736, FC=0%';
%     elseif fc_idx == 2
%         prob_data = probS2_all(:, :, 2);
%         cap_label = 'Cap_H=736, FC=50%';
%     elseif fc_idx == 3
%         prob_data = probS2_all(:, :, 3);
%         cap_label = 'Cap_H=283, FC=0%';
%     else
%         prob_data = probS2_all(:, :, 4);
%         cap_label = 'Cap_H=283, FC=50%';
%     end
% 
%     fprintf('\n--- %s ---\n', cap_label);
% 
%     for prob = [10, 90]
%         % Extract contour line at target probability
%         [M, c] = contour(R0_values, ps_values, prob_data', [prob prob]);
% 
%         if ~isempty(c)
%             idx = 1;
%             all_R0 = [];
%             all_ps = [];
%             % Parse contour matrix
%             while idx < size(M, 2)
%                 num_pts = M(2, idx);
%                 if num_pts > 0
%                     pts = M(:, idx+1:idx+num_pts);
%                     all_R0 = [all_R0; pts(1,:)'];
%                     all_ps = [all_ps; pts(2,:)'];
%                     idx = idx + num_pts + 1;
%                 else
%                     break;
%                 end
%             end
% 
%             % Find R0 at minimum and maximum ps
%             [~, min_idx] = min(all_ps);
%             [~, max_idx] = max(all_ps);
% 
%             fprintf('  P=%d%%: min p_s=%.4f -> R0=%.4f, max p_s=%.4f -> R0=%.4f\n', ...
%                 prob, all_ps(min_idx), all_R0(min_idx), all_ps(max_idx), all_R0(max_idx));
%         end
%     end
% end
% fprintf('========================================================\n');

end

