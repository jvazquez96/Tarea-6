-module(servidor_taxi)
-export()

%-------------------------------------------------------------------------------
inicia_servidor() ->
	receive

	% Un cliente solicita un taxi
	{PID, {solicita, NombreCliente, {X,Y}}} ->
		io:format("Recibida SOLICITUD del cliente: ~p, ubicado en ~p~n", [NombreCliente,{X,Y}]),
		register(NombreCliente, PID),
		solicitaTaxi(PID, {X,Y}),
		inicia_servidor();

	% Se para el servidor
	para ->
		io:format("Servidor recibe PARA, finalizando ejecucion~n",[]);

	% Una central se quiere dar de alta
	{PIDcentral, {registra_central, NombreCentral, {X,Y}}} ->
		io:format("Servidor recibe REGISTRO DE CENTRAL: ~p, ubicada en: 
			~p~n", [NombreCentral, {X,Y}]),
		register(NombreCentral, PIDcentral),
		NombreCentral ! {self(), registrado},
		inicia_servidor();

	% Respuesta del cliente indicando que llegó al destino
	{PIDcliente, {PIDtaxi, ok}} ->
		io:format("El cliente llego al destino~n",[]),
		inicia_servidor();

	% Respuesta de la central de taxis con un taxi para el cliente
	{PIDcentral, PIDcliente, {PIDtaxi, TipoAuto, PlacaAuto}} ->
		io:format("Respuesta con TAXI recibida de CENTRAL~n",[]),
		PIDcliente ! {self(), {PIDtaxi, TipoAuto, PlacaAuto}},
		inicia_servidor();

	% Respuesta de la central de taxis indicando que no hay taxis disponibles
	{PIDcentral, {sin_taxis, PIDcliente}} ->
		io:format("Respuesta recibida de central, NO HAY TAXIS~n",[]),
		PIDcliente ! {self(), no_hay_taxis},
		inicia_servidor();
	end.

%-------------------------------------------------------------------------------
solicitaTaxi(PIDcliente, {A,B}) ->
	buscaCentralCercana(TablaCentrales,{A,B}) ! {self(), {necesito_taxi, PIDcliente, {A,B}}}.

%-------------------------------------------------------------------------------
calcula_distancia({Xcli,Ycli}, {Xtax,Ytax}) ->
	sqrt(pow(Xcli-Xtax, 2) + pow(Ycli-Ytax, 2)).


%-------------------------------------------------------------------------------
buscaCentralCercana([],_) -> 
	io:format("No hay centrales disponibles~n",[]);

buscaCentralCercana(DatosDeCentral, {A,B}) ->
	buscaCentralCercanaAux(DatosDeCentral, {A,B}, 1000000.00, self()),
	PID.

%-------------------------------------------------------------------------------
buscaCentralCercanaAux([{PIDcentral, NombreCentral, {X,Y}}|T], {A,B}, DistMenor, PID) ->

	DistanciaCliente = calcula_distancia({A,B},{X,Y}),

	if
		DistanciaCliente < DistMenor -> (T, {A,B}, DistanciaCliente, PIDcentral),
		true -> buscaCentralCercana(T, {A,B}, DistMenor, PID)
	end

