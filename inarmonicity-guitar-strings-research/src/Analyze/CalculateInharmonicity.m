function mybeta=CalculateInharmonicity(Fret)

% mybeta=CalculateInharmonicity2(Fret);
% return
%Calculo de beta para fk=k*fo*sqrt(1+beta*k^2)
mybeta=0;
NHarm=length(Fret.Freq);
figure
hold on;
line=['b-.';'c-.';'g-.';'k-.';'r-.';'b--';'c--';'g--';'k--';'r--'];
 aux1=Fret.HarmFreq./(1:NHarm);
 N=100;
 aux2=filter((1/N)*ones(1,N),1,aux1);
 plot(aux2);
 legend(num2str((1:NHarm)'))
 figure;plot(aux2(:,2:end)-aux2(:,1:end-1));
 legend(num2str((2:NHarm)'))
 
 figure;plot(aux2(:,2:end).^2-aux2(:,1:end-1).^2);
 legend(num2str((2:NHarm)'))
 title('Al cuadrado');
 
%  %return
% for i=1:NHarm
% %     aux=(Fret.HarmFreq(:,i)./(i*Fret.HarmFreq(:,1)))-1;
% %     aux1=medfilt1(aux,1001);
% %     aux1(isnan(aux1))=0;
%        %aux3=mean(aux1);
%      % plot(aux);%hold on;
%      %aux1=Fret.HarmFreq(:,i)./i;
%      N=100;
%       plot(1:length(aux1(:,i)),filter((1/N)*ones(1,N),1,aux1(:,i)),line(i,:)'); 
%       
%       %plot([1 length(Fret.HarmFreq(:,1))],[aux3 aux3]);%hold off;
%     %pause
% end
% legend(num2str((1:NHarm)'))
% hold off;
% return
%pause
%Para probar en caso ideal
B=1e-3;

% Fret.Freq(1)=Fret.NoteRefFreq;
% Fret.Freq(2:10)=Fret.Freq(1)*(2:10).*sqrt(1+(2:10).^2.*B);

RefF=Fret.Freq(1);
%Valores canonicos de las frecuencias de cada armónico
CanonicPart=RefF*(1:NHarm);
SupMarg=(RefF+Fret.Prec)*(1:NHarm);
InfMarg=(RefF-Fret.Prec)*(1:NHarm);
%Desviación de frecuencia
Deviation=Fret.Freq-CanonicPart;
for i=2:NHarm %i es el número de armónico.
    if Deviation(i) < 0 %Todas las desviaciones deben ser positivas
        display(['Error, partial ',num2str(i),' with negative deviation']);
        mybeta(i)=0;
        betasup(i)=0;
        betainf(i)=0;
    else
        Freq=Fret.Freq(i);
        CanonicFreq=CanonicPart(i);
        aux=(Freq/CanonicFreq)^2;
        mybeta(i)=(aux - 1)/(i^2);
        beta2(i)=(aux-1)/(i^2-aux);
         beta3(i)=(sqrt(aux) - 1)/(i^2);
        betasup(i)=(((Freq+Fret.Prec)/InfMarg(i))^2 - 1)/(i^2);
        betainf(i)=(((Freq-Fret.Prec)/SupMarg(i))^2 - 1)/(i^2);
        a=(1+(i^2*pi^2/8));
        c=1-(Freq/CanonicFreq);
         beta3(i)=(-1+sqrt(1-4*a*c))/2/a;
    end
end
BetaGuess=mean(mybeta(NHarm-3:end));
B=BetaGuess;
%mean(beta(2:end))
%std(beta(2:end))
figure;
l=1:NHarm;
subplot 311
plot(l,mybeta,'*');
aux=1:10;
hold on
%plot(aux(BetaGuess==0),BetaGuess(BetaGuess==0),'r*');

plot(l(mybeta==0),mybeta(mybeta==0),'rx');
plot(l,betasup,'ob');plot(l,betainf,'ob');
plot(beta2,'go');
%plot(beta3,'g<');
%plot(beta3,'k<');

title(['beta=(f/(nfo))^2-1 / n^2',' B = ', num2str(B)]);
plot([1 10],[B B]);
hold off;
%figure;
subplot 312
plot((1:10).^2,(Fret.Freq(1:10)./(1:10)).^2);%Teóricamente esto da una linea
aux=(Fret.Freq(1))^2*(1+B*(1:10).^2);
hold on; plot((1:10).^2,aux);hold off;
hold on; plot(0,Fret.Freq(1)^2,'ro');hold off
title('(f/n)^2 frente a n^2 (recta fo^2+Bfo^2 x)');
subplot 313

 plot(1:NHarm,Fret.Freq./CanonicPart,'*-');
 aux=sqrt(1+B*(1:10).^2);
   title('f/nfo');
hold on; plot((1:10),aux);hold off;
 %hold on; plot(0,Fret.Freq(1).^2,'o');hold off;
 %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%  figure;%Beta3
%  B=mean(beta3(NHarm-3:end));
%  subplot 311
% plot(l,beta3,'*');
% aux=1:10;
% hold on
% title(['beta2=f/(nfo)-1 / n^2',' B2 = ', num2str(B)]);
% plot([1 10],[B B]);
% hold off;
% subplot 312
% plot((1:10).^2,(Fret.Freq(1:10)./(1:10)),'*');%Teóricamente esto da una linea
% aux=(Fret.Freq(1))*(1+B*(1:10).^2);
% hold on; plot((1:10).^2,aux);hold off;
% hold on; plot(0,Fret.Freq(1),'ro');hold off
% title('(f/n) frente a n^2 (recta fo+Bfo x)');
% subplot 313
% 
%  plot(1:NHarm,Fret.Freq./CanonicPart,'*-');
%  aux=1+B*(1:10).^2;
%    title('f/nfo');
% hold on; plot((1:10),aux);hold off;
return

