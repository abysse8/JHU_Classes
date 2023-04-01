y = string2bitstring('SHUT UP')
bitstring2string(y)

function bitstring = string2bitstring(my_string)
    cod = fopen('ascii.code', 'r','s');
    c = textscan(cod, '%s%f32');
    c{1}(1) = {" :"}
    bitstring = []
    for jjj=1:length(my_string)
        my_string(jjj)
        for iii=1:length(c{1})
            x = char(string(c{1}(iii)));
            if x(1) == my_string(jjj)
                bitstring = [bitstring c{2}(iii)];
            end
        end
    end
end

function outstring = bitstring2string(bitstring)
    cod = fopen('ascii.code', 'r','s');
    c = textscan(cod, '%s%f32');
    c{1}(1) = {" :"}
    outstring = []
    bitstring = string(bitstring);
    for jjj=1:length(bitstring)
        for iii=1:length(c{1})
            x = string(c{2}(iii));
            if x == bitstring(jjj)
                out = string(c{1}(iii))
                to_char = char(out)
                outstring = [outstring to_char(1)];
            end
        end
    end
end