function f=notenum2freq(indices)
f=[]
for indice=indices
notenum=mod(indice,12);
octave=floor(indice/12);
base=2^(-9/12)*27.5; %C0 calculado a partir de A0 para que sea exacto
f=[f base*(2)^((notenum/12))*2^(octave)];
end