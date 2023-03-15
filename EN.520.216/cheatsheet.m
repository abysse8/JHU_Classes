global k; k = 8.6*10^(-5); %eV/K
global kmV; kmV = 1.38*10^(-23);
global q; q = 1.6*10^(-19);
global Eg; Eg = 1.1;
global phi; phi = 26*10^(-3);
global gamma; gamma = 0.5;


%% DEVICE PHYSICS
%disp(getfermiprob(0.225, 0.555, 300)); disp('% chance'); %raw values of E, Ef in eV
%disp( getfermiprobDelt(0.225)); disp('% chance'); %if E = Ef + 0.225kT
%disp( getDeltaE(10^(17), 295)); disp('eV above intrinsic'); %Nd, T 
%%disp( getNa_Nd(10^(17), 300) ); disp('electrons per unit cubed')
%%disp( getEg(300) ); disp('eV')
%%disp( getni(295) ); disp('carriers per unit cubed')

%% DEVICES
%%disp( getApproximateDiode(1.8*10^(-6), 1, 10000, 295) ); disp('V'); %Isat, Vsource, Rseries, temp

labels = ["mode", "k'µ", "W/L", "Id" "gm" "Vg" "Vs" "Vd" "Vb" "Vt" "Vto" "lambda" "Vdd" "R1" "R2" "phi" "ro"]; 
info = [    2      10^3    1     nan   nan  0.3   0  1.5 -0.22  nan  0.22   0.09   0.9  nan   nan  0.9   nan];
%disp(getMOSCharacteristics(labels, info));

labels2 = ["mode" "k'µ", "W/L", "Id" "gm" "Vg" "Vs" "Vd" "Vb" "Vt" "Vto" "lambda" "Vdd" "R1" "R2" "phi" "ro"]; 
info2 = [   2    1*10^3    1     nan  nan 2.91  nan  nan  nan  1.5   nan    0.01    10  5000    0   nan   nan];
disp(CommonSource(labels2, info2));
%% DEVICE PHYSICS
function output = getEg(T)
    output = 1.17 - 4.73*10^(-4)*T^2/(T+636);
end

function output = getni(T)
    Eg = getEg(T);
    global k;
    output = 5.2*10^(15)*T^(1.5)*exp(-Eg/(2*k*T));
end

function output = getfermiprob(E, Ef, T)
    global k;
    output = 1 / (1+exp((E-Ef)/(k*T))); %probability
end

function output = getfermiprobDelt(kTDelt_E)
    output = 1/ (1+exp(kTDelt_E));
end

function output = getDeltaE(Nd, T) %Level of Ef ABOVE Efintrinsic
    global k;
    ni = getni(T);
    output = -k*T*log(ni/Nd);
end

function output = getphi(T, Na, Nd)
    global kmV; global q;
    output = string(kmV*T/q * log(Na*Nd/getni(T)^2)*10^3)+'mV';
end

function output = getNa_Nd(N, T)
    output = getni(T)^2 / N;
end

%%DEVICES

function output = getApproximateDiode(I_saturation, Vsource, R, T)
    syms vdon; global k; global q; global phi;
    output = vpasolve(Vsource-vdon == R*I_saturation*(exp(vdon/phi)-1), vdon);
end

function output = getMOSCharacteristics(labels, values)
    global gamma;
    dict = containers.Map(labels, values);
    output = containers.Map(labels, values)
    if isnan(dict('Vt')) & (~isnan(dict('Vto')) & ~isnan(dict('Vb')) & ~isnan(dict('Vs')) & ~isnan(dict('phi')) )
        if (isnan(dict('Vto')) | isnan(dict('Vb')) | isnan(dict('Vs')) | isnan(dict('phi')) )
            disp("Underdefined Vt"); output = [output.keys; output.values]; return;
        end
        Vbs = dict('Vb') - dict('Vs');
        phi = dict('phi');
        output("Vt") = dict("Vto") + gamma*(sqrt(2*phi-Vbs)-sqrt(2*phi));
    end
    if isnan(dict("k'µ")) | isnan(dict("W/L")) | isnan(output("Vt")) | (isnan(dict('lambda')) & isnan(dict('Vd'))) | isnan(dict('Vg')) | isnan(dict('Vs'));
        disp("Underdefined Ids"); output = [output.keys; output.values]; return;
    end
    if dict("mode") == 1 %%linear
        k = dict("k'µ"); wl = dict("W/L"); vt = output("Vt"); gam = dict('lambda')
        vgs = dict('Vg') - dict('Vs'); vds = dict('Vd') - dict('Vs');
        output("Id") = 10^(-6)*k*wl/2*(2*(vgs-vt)*vds-vds^2)*(1+gam*vds);
        output = [output.keys; output.values]
        return;
    elseif dict("mode") == 2 %%saturation
        k = dict("k'µ"); wl = dict("W/L"); vt = output("Vt"); gam = dict('lambda')
        vgs = dict('Vg') - dict('Vs'); vds = dict('Vd') - dict('Vs');
        output("Id") = 10^(-6)*k*wl/2*((vgs-vt)^2)*(1+gam*vds);
    end
    id = output('Id'), vgs = output('Vg')-output('Vs'); vt = output('Vt');
    vds = output('Vd') - output('Vs'); lamb = output('lambda')
    output('gm') = 2*id/(vgs-vt);
    output('ro') = 1/(lamb*id/(1+lamb*vds));
    output = [output.keys; output.values]
end

function output = CommonSource(labels, values)
    dict = containers.Map(labels, values);
    output = containers.Map(labels, values);
    syms id;
    K = dict("k'µ")*dict("W/L")/2; vin = dict('Vg'); vt = dict('Vt'); lamb = dict("lambda");
    R1 = dict("R1"); R2 = dict("R2"); vdd = dict("Vdd");
    ids = vpasolve(id == K*((vin-(R2*id)-vt)^2)*(1+lamb*(vdd-id*R1-id*R2)), id) %in microamps
    id = double(ids(1))*10^(-6); %in amps
    output("Vs") = id*R2;
    output("Vd") = vdd - id*R1;
    output("Id") = double(ids(1));
    output = getMOSCharacteristics(output.keys, output.values);
end