%% initialize cobra toolbox

initCobraToolbox
% changeCobraSolver('glpk');
changeCobraSolver('gurobi6');


%% import model

% model = readCbModel('../models/mat/iML1515.mat');
model = readCbModel('../models/mat/GM_iML1515.mat');
% model2 = readCbModel('../models/mat/test2.mat');

% verifyModel(model, 'massBalance', true)

%% add accoa demand

model = addDemandReaction(model, {'accoa_c'});

%% set constraints

model = changeRxnBounds(model, 'EX_phleth_e', -0, 'l');
model = changeRxnBounds(model, 'EX_o2_e', -20, 'l');
model = changeRxnBounds(model, 'EX_glc__D_e', -10, 'l');
% model = changeRxnBounds(model, 'EX_so4_e', -20, 'l');

% model = changeRxnBounds(model, 'GAPN', -9.094641, 'l');

% model = changeObjective(model,'BIOMASS_Ec_iML1515_core_75p37M');
% model = changeObjective(model,'DM_phb_c');

%% robustness analysis

figure(1)
% controlRxn = char('DM_accoa_c');
% controlRxn = char('EX_glc__D_e');
controlRxn = char('EX_phleth_e');
% controlRxn = char('EX_o2_e');
[controlFlux, objFlux] = robustnessAnalysis(model, controlRxn);
% xlim([-14 0])
% ylim([0 10])

csvwrite('controlFlux.csv', controlFlux)
csvwrite('objFlux.csv', objFlux)

%% double robustness analysis

figure(1)
controlRxn1 = char('EX_glc__D_e');
controlRxn2 = char('EX_phleth_e');
[controlFlux1, controlFlux2, objFlux] = doubleRobustnessAnalysis(model, controlRxn1, controlRxn2);


%% production envelope

figure(2)

% wt
deletions = '';
lineColor = 'blue';
targetRxn = char('CS');
% targetRxn = char('ATPS4rpp');
biomassRxn = char('BIOMASS_Ec_iML1515_core_75p37M');
geneDelFlag = false;
nPts = 20;

[biomass_wt, phb_wt, lineHandle] = productionEnvelope(model, deletions, lineColor, targetRxn, biomassRxn, geneDelFlag, nPts);

csvwrite('p_e/biomass_wt.csv', biomass_wt)
csvwrite('p_e/phb_wt.csv', phb_wt)

hold on

% acetate modifications
deletions = {'PTAr', 'ACKr'};
lineColor = 'green';

model = changeRxnBounds(model, 'ACS', 0.5, 'l'); % overexpress acs

[biomass_ac, phb_ac, lineHandle] = productionEnvelope(model, deletions, lineColor, targetRxn, biomassRxn, geneDelFlag, nPts);

csvwrite('p_e/biomass_ac.csv', biomass_ac)
csvwrite('p_e/phb_ac.csv', phb_ac)

% tca modifications
deletions = {'SUCOAS', 'SUCDi'};
lineColor = 'red';

model = changeRxnBounds(model, 'ACS', 0, 'l'); % normal acs

[biomass_tca, phb_tca, lineHandle] = productionEnvelope(model, deletions, lineColor, targetRxn, biomassRxn, geneDelFlag, nPts);

csvwrite('p_e/biomass_tca.csv', biomass_tca)
csvwrite('p_e/phb_tca.csv', phb_tca)

% others
deletions = {'AGMHE', 'GMHEPPA', 'GMHEPAT', 'GMHEPK'};
lineColor = 'magenta';

% model = changeRxnBounds(model, 'EX_glc__D_e', -1, 'l');

% [biomass_o, phb_o, lineHandle] = productionEnvelope(model, deletions, lineColor, targetRxn, biomassRxn, geneDelFlag, nPts);

% csvwrite('p_e/biomass_o.csv', biomass_o)
% csvwrite('p_e/phb_o.csv', phb_o)

hold off

xlabel('Growth Rate (h^-^1)')
ylabel('PHB Production (mmol/gDWh)')
title('PHB Production Envelopes')
legend('Wild Type', 'Acetate Modifications', 'TCA Modifications')


%% production envelope 2

figure(3)

% wt
deletions = '';
lineColor = 'blue';
targetRxn = char('DM_phb_c');
biomassRxn = char('BIOMASS_Ec_iML1515_core_75p37M');
geneDelFlag = false;
nPts = 20;

% model = changeRxnBounds(model, 'GAPN', 0, 'l');
% model = changeRxnBounds(model, 'GAPN', 0, 'u');

[biomass_wt, phb_wt, lineHandle] = productionEnvelope(model, deletions, lineColor, targetRxn, biomassRxn, geneDelFlag, nPts);

% csvwrite('p_e/biomass_wt.csv', biomass_wt)
% csvwrite('p_e/phb_wt.csv', phb_wt)

hold on

% others
deletions = {'SUCDi'};
% deletions = {'GLUDy', 'GLUSy'};
lineColor = 'red';
% 
% model = changeRxnBounds(model, 'ACS', 0.5, 'l'); % overexpress acs
% 
[biomass_ac, phb_ac, lineHandle] = productionEnvelope(model, deletions, lineColor, targetRxn, biomassRxn, geneDelFlag, nPts);

% csvwrite('p_e/biomass_ac.csv', biomass_ac)
% csvwrite('p_e/phb_ac.csv', phb_ac)

hold off

%% optgene

targetRxn = char('DM_phb_c');
substrateRxn = char('EX_glc__D_e');
generxnList = {'GLUDy', 'GLUSy', 'GAPD'};

[x, population, scores, optGeneSol] = optGene(model, targetRxn, substrateRxn, generxnList);
