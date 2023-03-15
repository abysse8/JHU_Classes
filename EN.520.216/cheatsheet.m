global k; k = 8.6*10^(-5); %eV/K
global kmV; kmV = 1.38*10^(-23);
global q; q = 1.6*10^(-19);
global Eg; Eg = 1.1;
global phi; phi = 26*10^(-3);


%% DEVICE PHYSICS
%disp(getfermiprob(0.225, 0.555, 300)); disp('% chance'); %raw values of E, Ef in eV
%disp( getfermiprobDelt(0.225)); disp('% chance'); %if E = Ef + 0.225kT
%disp( getDeltaE(10^(17), 295)); disp('eV above intrinsic'); %Nd, T 
%%disp( getNa_Nd(10^(17), 300) ); disp('electrons per unit cubed')
%%disp( getEg(300) ); disp('eV')
%%disp( getni(295) ); disp('carriers per unit cubed')

%% DEVICES
%%disp( getApproximateDiode(1.8*10^(-6), 1, 10000, 295) ); disp('V'); %Isat, Vsource, Rseries, temp
%%disp (

labels = ["mode", "k'µ", "W/L", "Id" "gm" "Vg" "Vs" "Vd" "Vb" "Vt" "Vto" "lambda"]; 
info = [2       960      1     nan   nan   0.3   0   nan  nan  0.22 nan   0];
test = containers.Map(labels, info)
getMOSCharacteristics();
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

function output = getMOScharacteristics(dict)
    output = dict;
    if dict("mode") == 1 %%linear
        output("Id") = 999;
    elseif dict("mode") == 2 %%saturation
        output("Id") = 888;
    end
end
