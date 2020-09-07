function salida=ExtractB(Session)

  N=500;
  TodosB=zeros(6,13);
for string=1:6;
    
    BVal=[];
    mystring=Session.Strings(string);
    %title(mystring.StringID)
    for frets=1:13
        Fret=mystring.Fret(frets);
        NHarm=length(Fret.Freq);
        aux1=Fret.HarmFreq./(1:NHarm);
        %First define margins
%        figure
%        subplot 211
%        plot(aux1);
%        subplot 212
        mivar=medfilt1(var(aux1'),50);
%       plot(mivar); hold on;
%         plot([0 length(mivar)],10*min(mivar)*ones(1,2));
%         hold off;
        aux21=aux1(mivar<10*min(mivar),:);
        %aux3=medfilt1(miindex,5);
       % figure;plot(aux3);
%         pause;
         Bt=[];
         %for i=NHarm:-1:2
         for i=NHarm-1:-1:4
        aux2=filter((1/N)*ones(1,N),1,aux21);
  % figure;subplot 211; hold on; subplot 212; hold on;
                 for j=i-1:-1:2
  %nuevo=(aux2(:,i) - aux2(:,j))./(2*i*j-j^2);
  %Fcuad=(aux2(:,i)*j^2 - aux2(:,j)*i^2)./(i^2-j^2);
      aux3=aux2(:,j)./aux2(:,i);
                    B=(aux3-1)./(j^2-aux3.*i^2);
                    Bt=[Bt; B];
 %nuevo=(aux2(:,2:end) - aux2(:,1:end-1));

  %range=1:NHarm-1;
  %subplot(211);
 % plot(filter((1/N)*ones(1,N),1,Fcuad));
  %title(['(f_0) a partir de armónico',num2str(i)]);
  %subplot 212;
  %title('B')
  %plot(filter((1/N)*ones(1,N),1,B));
   end
         end
 figure(3);
 h=histogram(Bt(abs(Bt)<1e-3),500,'Normalization','probability');
 
  [iv mv]=max(h.Values);
  
  BVal=[BVal h.BinEdges(mv)];
 title(['String ',num2str(string),' Fret ',num2str(frets), ' B = ',num2str(h.BinEdges(mv))]);

 
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
    end
   % figure(4);plot(BVal,'*');pause;
    TodosB(string,:)=BVal;
%     legend(num2str((1:13)'));
end
%        salida=1;  
figure(5);
plot(TodosB','-*');
legend('1 E','2 A','3 D','4 G','5 B','6 e')
salida=TodosB;

L=CalculateFretPos(64.8);
 figure(6);
 plot((TodosB.*L.^2)','-*');
 legend('1 E','2 A','3 D','4 G','5 B','6 e')
 salida=TodosB.*L.^2;
end