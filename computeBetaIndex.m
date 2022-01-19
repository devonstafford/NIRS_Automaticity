function beta_index = computeBetaIndex(fit)  
%compute the index of each regression coefficient
% 
% --------Argument-------------------
%-fit: a LinearModel object (the result of fitlm)
% 
%---------Return--------------------
%-beta_index: a double array, representing the index/ratio of each beta
%coefficient/sum of all coefficients. The array of index is in the same
%order of the beta coefficients in the Estimate (i.e., if 1st row of
%fit.Coefficients is Adapt, the 1st entry in beta_index will be the
%adapt_index.

    betas = fit.Coefficients.Estimate;
    beta_index = nan(1,length(betas));
    for i = 1:length(betas)
        beta_index(1,i) = betas(i)/sum(abs(betas));
    end
end