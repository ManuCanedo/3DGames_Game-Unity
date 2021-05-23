function salida=InharmonicityAnalysis(Session)

selected=SelectStrings()
ss=1:6;
f=figure;
hold on;
line={'*-r','<-r','>-r','d-r','*-g','<-g','>-g','d-g',...
    '*-b','<-b','>-b','d-b','*-k','<-k','>-k','d-k',};
for string=ss(selected)
    
    mystring=Session.Strings(string);
    title(mystring.StringID)
    for frets=1:13
        Fret=mystring.Fret(frets);
        Prec=Fret.Prec;
        NHarm=length(Fret.Freq);
        RefF=Fret.Freq(1);
        CanonicPart=RefF*(1:NHarm);
        SupMarg=(RefF+Fret.Prec)*(1:NHarm);
        InfMarg=(RefF-Fret.Prec)*(1:NHarm);
          %aux=(Fret.Freq/CanonicFreq)^2;
        %mybeta(i)=(aux - 1)/(i^2);
         %plot(1:NHarm,Fret.Freq./CanonicPart,cell2mat(line(frets)));
         plot(1:NHarm,((Fret.Freq./CanonicPart).^2-1)./((1:10).^2),cell2mat(line(frets)));
%          plot(0:NHarm-1,SupMarg./CanonicPart,'-b');
%           plot(0:NHarm-1,InfMarg./CanonicPart,'-b');
    end
    legend(num2str((1:13)'));
end
       salida=1;  
end