function mybeta=CalculateInharmonicity2(Fret)
%Calculo de beta para fk=k*fo*sqrt(1+beta*k^2)
NHarm=length(Fret.Freq);

RefF=Fret.Freq(1);
%Valores canonicos de las frecuencias de cada armónico
CanHarm=RefF*(1:NHarm);

l=2:NHarm;
aux=Fret.Freq(2:end)./CanHarm(2:end);
B0=(aux.^2-1)./l.^2;
B0d=mean(B0(NHarm-3:end));
B1=(aux-1)./l;
B1d=mean(B1(NHarm-3:end));
B2=(aux-1)./l.^2;
B2d=mean(B2(NHarm-3:end));
B3=(aux-1);
B3d=mean(B3(NHarm-3:end));
figure;
plot(l,aux,'r-*');hold on;
plot(l,sqrt(1+B0d*(l.^2)));
plot(l,1+B1d*l);
plot(l,1+B2d*(l.^2));
plot(l,(1+B3d)*ones(1,length(l)));
legend('fn/(nfo)','B0','B1','B2','B3');
hold off;
mybeta=B0d;

return;


