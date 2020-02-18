function [prob,chain]=prob_calc(prob_caught,n,n_states,s0)
    prob = [(1-prob_caught).*ones(n_states,n_states/2) (prob_caught).*ones(n_states,n_states/2)]./(n_states./2); 
    [chain,~] = markov(prob,n,s0);
    