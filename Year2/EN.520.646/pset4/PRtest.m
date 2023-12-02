function pass = PRtest(H0, H1, F0, F1)
    % Set tolerance of equality
    de_tolerance = 0.3;
    zero_tolerance = 1e14*eps;
    
    % Normalize vectors
    H0 = H0/norm(H0);
    H1 = H1/norm(H1);
    F0 = F0/norm(F0);
    F1 = F1/norm(F1);
    
    %% Get modulated versions of F0 and F1
    % F0_modulated = F0(-z)
    mod = ones(1,length(F0));
    for iii = 2:2:length(mod)
        mod(iii) = -1;
    end
    F0_modulated = F0.*mod;
    
    % F1_modulated = F1(-z)
    mod = ones(1,length(F1));
    for iii = 2:2:length(mod)
        mod(iii) = -1;
    end
    F1_modulated = F1.*mod;
    
    %% Find Distortion Elimination and Aliasing Cancellation terms
    de_term = conv(H0,F0)+conv(H1,F1);
    ac_term = conv(H0,F0_modulated)+conv(H1, F1_modulated);
    
    %% Check for FIR perfect reconsturction conditions
    
    if abs(ac_term-0) < zero_tolerance
        disp("AC Passed"); ac_satisfied = true;
    else
        disp("AC Failed"); ac_satisfied = false;
    end
    disp(ac_term);

    if (nnz(abs(de_term)>zero_tolerance) == 1) && (abs(norm(de_term)-2.0) < de_tolerance)
        disp("DE passed"); de_satisfied = true;
    else
        disp("DE failed"); de_satisfied = false;
    end
    disp(de_term);

    pass = de_satisfied && ac_satisfied;
end