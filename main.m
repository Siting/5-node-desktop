clear all
clc

dbstop if error

global full_range

% set parameters
networkID = '5Node-network';
numNodes = 5;
numRoutes = 2;       % number of candidate routes
numStations = 1;     % number of stations to locate
numPads = 1;         % number of pads(routes) to locate
full_range = 4;      % set full capacity vehicle range (in mile)

% load graph
load([networkID, '-graph.mat']);

% load links
% map keys: linkIDs
% map structure: linkID, incomingNode, outgoingNode, lengthInMiles, fuelCost
[LINK] = loadLinks(linkMap);

% load linkID look up matrix
% linkIDMatrix(incomingNode, outgoingNode) = linkID
load('linkIDMatrix.mat');

% load shortest paths == all flow pairs
% matrix, each row: [O, D, cost, traveled nodes]
load('shortest_paths_matrix.mat');

% load sorted flows
% matrix, each row: [flowID, flow volume]
load('generated_flow_sorted.mat');
topFlowIDs = sortedFlows(1:numRoutes, 1);   % retrive candidate route/flow IDs

% retrieve top k flow info: nodes + links
% map keys: flowIDs
% map structure TOP_FLOWS: flowID, origin, destination, cost, nodes, links
topFlowIDs = [2;1];  % for testing
[TOP_FLOWS] = retriveFlows(topFlowIDs, shortest_paths_matrix, linkIDMatrix);

% pre-generate b_qh, a_hp
[b_qh, a_hp] = pregenerateCoefficientMatrix(shortest_paths_matrix, TOP_FLOWS, numNodes,...
    numStations, numPads);

% retrieve all flows info: nodes + links
% map keys: flowIDs
% map structure ALL_FLOWS: flowID, origin, destination, cost, nodes, links
size(shortest_paths_matrix,1);
flowIDs = [1:size(shortest_paths_matrix,1)];
[ALL_FLOWS] = retriveFlows(flowIDs, shortest_paths_matrix, linkIDMatrix);

% filter out ineligible combinatinos
[b_qh, a_hp] = filterCombinations(b_qh, a_hp, ALL_FLOWS, TOP_FLOWS, numNodes, numRoutes, LINK);


