


nvars=2;

fitnessfcn=@EP_fitness
[x,fval,exitflag,output,population,scores] = gamultiobj(fitnessfcn,nvars,[],[],[],[],[19;24],[21,26],[],options)
