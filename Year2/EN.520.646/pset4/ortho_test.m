function pass = ortho_test(TEST1, TEST2)
    % Dont want to use constant tolerance
    % (think of very large filters)
    % so we use a percentage instead
    zero_tolerance = max(0.12*norm(TEST1), 0.12*norm(TEST2));
    zero_tolerance = max(zero_tolerance, 0.5);

    pass = true;
    L2 = length(TEST2);
    TEST2 = [zeros(1, length(TEST1)) TEST2 zeros(1, length(TEST1))];
    TEST1 = [TEST1 zeros(1, L2) zeros(1, L2)];
    clear L2;
    stop_index = length(TEST1)/2 -1;
    for k=0:stop_index
        dot_prod = dot(circshift(TEST1, 2*k),TEST2);
        if dot_prod > zero_tolerance
            disp(dot_prod);
            disp([circshift(TEST1, 2*k);TEST2])
            disp(["Shift", num2str(k), "/", num2str(stop_index), "failed"])
            pass = false;
            break
        end
    end
end