function [S E]= EditSingleSegment(fig,vS,vE)

caxis=axis(fig);
line=imline(fig,[vS vS],[0 caxis(4)]);
api = iptgetapi(line);
fcn = @(pos) [min(pos(:,1)) 0; min(pos(:,1)) caxis(4)];  %k k x1 k
api.setDragConstraintFcn(fcn);  
 wait(line);
 puntosn=getPosition(line)
 S=puntosn(1,1);
 delete(line)
 
 line=imline(fig,[vE vE],[0 caxis(4)]);
api = iptgetapi(line);
fcn = @(pos) [min(pos(:,1)) 0; min(pos(:,1)) caxis(4)];  %k k x1 k
api.setDragConstraintFcn(fcn);  
 wait(line);
 puntosn=getPosition(line)
 E=puntosn(1,1);
 delete(line)
end