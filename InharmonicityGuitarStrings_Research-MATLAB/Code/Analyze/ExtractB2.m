function salida=ExtractB2(Session)
%1- Cálculo de la zona de interés de la grabación de un traste. Aquí
%detectamos las muestras en las que la detección de armónicos parece
%estable:
%*  Se calculan inicialmente los valores fk/k donde fk es la frecuencia detectada
% para el armónico k. El armonico k=1 es la fundamental.
% * Se calcula la varianza del fector fk/k (var(fk/k)), en horizontal, es decir, si la
% grabación es de longitud L y el número de armónicos A, se obtiene un
% vector de varianza de longitud L.
% * El vector var(fk/k) se suaviza usando un filtro de mediana
%de tamaño NFM
% * Se obtiene la zona de interés de fk/k, como aquellos puntos en que el
% vector var(fk/k) es inferior a UmbralVar*min(var(fk/k))
% *Nos quedamos con las muestras de fk/k de la zona de interés, pero
% suavizamos el vector fk/k usando un filtro de media móvil de longitud N
% 2 - Cálculo de B empleando el resultado anterior
% *MinHarm y MaxHarm definen el primer y último armónico usado
% *Calculamos B según la fórmula de Fletcher:
%r=fn/fm;
%B=((r*m/n)^2-1)/(n^2 - (r*m/n)^2*m^2)
%Usamos aquí todos los pares de armónicos entre MinHarm y MaxHamr
%B debe ser constante para cada traste. Consideramos el resultado como una
%nube de puntos que son  realizaciones de una variable aleatoria.
% * Obtenemos el histograma para B (por traste), consideramos el máximo
% del histograma como el valor buscado

PlotHist=0;
PlotRelFreq=0;
PlotHistB=0;


%Longitud del filtro de mediana para suavizar fk/k
NFM=50;
%Umbral para la detección de la zona de interés
UmbralVar=5;
%Longitud del filtro de media móvil
N=500;
%Límite de desvio de frecuencia relativa
LimFreq=5;
%Número de armónicos ya detectados
NHarm=length(Session.Strings(1).Fret(1).Freq);
%Armónicos usados para detección de B
MinHarm=4;
MaxHarm=NHarm-1; 
%Longitud histograma
LHist=200;
TodosB=zeros(6,13);
%All strings
for string=1:6;
    BVal=[];
    mystring=Session.Strings(string);
    %All frets
    for frets=1:13
        Fret=mystring.Fret(frets);
        NHarm=length(Fret.Freq);
        FreqRel=Fret.HarmFreq./(1:NHarm);
        mivar=medfilt1(var(FreqRel'),NFM);
        FreqRelSuavizada=filter((1/N)*ones(1,N),1,FreqRel);
        FreqRelFinal1=FreqRelSuavizada(mivar<UmbralVar*min(mivar(mivar~=0)),:);
        FreqRelFinal=FreqRelFinal1(max(abs(FreqRelFinal1-Fret.NoteRefFreq)')<LimFreq,:);
        
       
        
        
        if (PlotRelFreq)
            index1=1:length(FreqRel);
            figure(3)
            subplot 311
            plot(FreqRel);
            subplot 312
            plot(FreqRelSuavizada);hold on;
            index2=index1(mivar<UmbralVar*min(mivar(mivar~=0)));
            %plot(index1(mivar<UmbralVar*min(mivar)),FreqRelFinal1,'r *');
            plot(index2(max(abs(FreqRelFinal1-Fret.NoteRefFreq)')<LimFreq),FreqRelFinal,'r *');
            hold off;
            subplot 313
            plot(FreqRelSuavizada-Fret.NoteRefFreq);
            clear index2;
            clear index1;
            pause
            
        end
        if PlotHistB
            figure(9);clf; hold on;
            title(['String ',num2str(string),' Fret ',num2str(frets)]);
        end
                 Bt=[];
                 Btb=[];
        for m=MaxHarm:-1:MinHarm
            %ux2=filter((1/N)*ones(1,N),1,aux21);
            % figure;subplot 211; hold on; subplot 212; hold on;
            Bta=[];
           
            for n=m-1:-1:MinHarm
                
                %Fórmula de Fletcher:
                %r=fn/fm;
                % B=((r*m/n)^2-1)/(n^2 - (r*m/n)^2*m^2)
                %Aquí rprima2=(fn*m/fm*n)^2;
                % B=(rprima-1)/n^2-rprima*m^2;
                rprima2=(FreqRelFinal(:,n)./FreqRelFinal(:,m)).^2;
                B=(rprima2-1)./(n^2-rprima2.*m^2);
                %Acumulamos los puntos
                Bta=[Bta; B];
                 Btb=[Btb,B];
            end % Armónico m
            if PlotHistB
                    [Counts Categories]=histcounts(Bta,50,'Normalization','probability');
                     plot(Categories(1:end-1),Counts);
                     %title([num2str(m),' ',num2str(n)]);
                     title(num2str(m));
                     %pause
                    %plot(m,B','.');
                end
            Bt=[Bt;Bta];
           
         end % Armónico n
        if PlotHistB
            figure(9);legend(num2str(MaxHarm:-1:MinHarm)'); hold off;
            pause;
            %figure(10);boxplot(Btb);pause
        end
       
        [Counts Categories]=histcounts(Bt(abs(Bt)<1e-3),LHist,'Normalization','probability');
        [iv mv]=max(Counts);
        BVal=[BVal (Categories(mv)+Categories(mv+1))*0.5];
        %BVal=[BVal median(Bt)];
        
        % title(['String ',num2str(string),' Fret ',num2str(frets), ' B = ',num2str(h. BinEdges(mv))]);
        if (PlotHist)
            figure(3);
            
            plot(Categories(1:end-1),Counts);hold on; plot(Categories(mv),iv,'r*');hold off;
            %boxplot(Bt);
            title(['String ',num2str(string),' Fret ',num2str(frets), ' B = ',num2str(Categories(mv))]);
            pause
        end
        
        
        
        % pause
        
        %         Prec=Fret.Prec;
        
        %         RefF=Fret.Freq(1);
        %         CanonicPart=RefF*(1:NHarm);
        %         SupMarg=(RefF+Fret.Prec)*(1:NHarm);
        %         InfMarg=(RefF-Fret.Prec)*(1:NHarm);
        %           %aux=(Fret.Freq/CanonicFreq)^2;
        %         %mybeta(i)=(aux - 1)/(i^2);
        %          %plot(1:NHarm,Fret.Freq./CanonicPart,cell2mat(line(frets)));
        %          plot(1:NHarm,((Fret.Freq./CanonicPart).^2-1)./((1:10).^2),cell2mat(line(frets)));
        % %          plot(0:NHarm-1,SupMarg./CanonicPart,'-b');
        % %           plot(0:NHarm-1,InfMarg./CanonicPart,'-b');
    end % Fret
    % figure(4);plot(BVal,'*');pause;
    TodosB(string,:)=BVal;
    %     legend(num2str((1:13)'));
end %String
%        salida=1;
figure(5);
plot(TodosB','-*');
legend('1 E','2 A','3 D','4 G','5 B','6 e')
salida=TodosB;

L=CalculateFretPos(65);
figure(6);
plot((TodosB.*L.^2)','-*');
legend('1 E','2 A','3 D','4 G','5 B','6 e')
salida=TodosB;
end