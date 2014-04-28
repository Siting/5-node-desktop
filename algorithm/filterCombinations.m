function[b_qh, a_hp] = filterCombinations(b_qh, a_hp, ALL_FLOWS, TOP_FLOWS,...
    numNodes, numRoutes, LINK)

numFlows = length(ALL_FLOWS);  % num of total flows

numComs = size(b_qh, 2);       % num of combinations

candidateRouteIDs = TOP_FLOWS.keys;

for i = 1 : numFlows  % loop through flows/paths
    
    % get the nodes and links of the testing flow
    nodes_flow = ALL_FLOWS(i).nodes;
    links_flow = ALL_FLOWS(i).links;
    round_nodes_flow = makeRoundTrip_node(nodes_flow);
    round_links_flow = makeRoundTrip_link(links_flow);
    
    for j = 1 : numComs    % loop through combinations
   
        % get the nodes and links of the testing combination
        nodes_com = find(a_hp(j, 1: numNodes)==1);
        route_MatrixIndices_com = find(a_hp(j, numNodes+1:end)==1);
        routeIDs = candidateRouteIDs(route_MatrixIndices_com);
        
        for r = 1 : length(routeIDs) % loop through each selected route
            
            routeID = routeIDs{r};
            links_com = TOP_FLOWS(routeID).links;
            
            % update fuel cost for links with charging pads to 0
            for k = 1 : length(links_com)
                link = LINK(k);
                link.fuelCost = 0;
                LINK(k) = link;
            end
            
            % check if any facility is located for flow
            [checkResult] = comCheck_1(nodes_flow, links_flow, nodes_com, links_com);
            
            if checkResult == 0 % no overlap
                continue
            else
                [checkResult_2] = comCheck_2(nodes_flow, links_flow, nodes_com, links_com, LINK);
                
                % update b_qh
                % if a testing flow could be refueled by any selected
                % route in combination with nodes, set b_qh(i,j) = 1
                if checkResult_2 == 1
                    b_qh(i, j) = 1;
                    
                    break
                end
            end
                        
        end
               
    end
end
