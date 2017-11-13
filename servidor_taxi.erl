-module(servidor_taxi).
-export([inicio/0, servidor/1, calcula_distancia/2]).
-import(math, [pow/2, sqrt/1]).
-import(lists, [append/2]).
%-------------------------------------------------------------------------------


servidor(TablaCentrales) ->
	receive

	% Un cliente solicita un taxi
	{PID, {solicita, NombreCliente, {X,Y}}} ->
		io:format("Recibida SOLICITUD del cliente: ~p, ubicado en ~p~n", [NombreCliente,{X,Y}]),
		% register(NombreCliente, PID),
		io:format("Tamano de la lista: ~p~n", [length(TablaCentrales)]),
		solicitaTaxi(TablaCentrales, PID, {X,Y}),
		servidor(TablaCentrales);

	% Se para el servidor
	para ->
		io:format("Servidor recibe PARA, finalizando ejecucion~n",[]);

	% Una central se quieresdar de alta
	{PIDcentral, {registra_central, NombreCentral , {X,Y}}} ->
		io:format("Servidor recibe REGISTRO DE CENTRAL: ~p, ubicada en: 
			~p~n", [NombreCentral, {X,Y}]),
		% register(NombreCentral, PIDcentral),
		PIDcentral ! {self(), registrado},
		io:format("Process id: ~p~n", [PIDcentral]),
		servidor(lists:append(TablaCentrales, [{PIDcentral, NombreCentral, {X,Y}}]));

	% Respuesta del cliente indicando que llegó al destino
	{_, {_, ok}} ->
		io:format("El cliente llego al destino~n",[]),
		servidor(TablaCentrales);

	% Respuesta de la central de taxis con un taxi para el cliente
	{_, PIDcliente, {PIDtaxi, TipoAuto, PlacaAuto}} ->
		io:format("Respuesta con TAXI recibida de CENTRAL~n",[]),
		PIDcliente ! {self(), {PIDtaxi, TipoAuto, PlacaAuto}},
		servidor(TablaCentrales);

	% Respuesta de la central de taxis indicando que no hay taxis disponibles
	{_, {sin_taxis, PIDcliente}} ->
		io:format("Respuesta recibida de central, NO HAY TAXIS~n",[]),
		PIDcliente ! {self(), no_hay_taxis},
		servidor(TablaCentrales)
	end.

inicio() ->
	register(servidor_taxi, spawn(servidor_taxi, servidor, [[]])).

%-------------------------------------------------------------------------------
solicitaTaxi([], PID, _) ->
	PID ! {no},
	io:format("No hay centrales disponibles~n",[]);

solicitaTaxi(TablaCentrales, PIDcliente, {A,B}) ->
	TaxiPID = buscaCentralCercana(TablaCentrales,{A,B}),
	io:format("Process id: ~p~n", [TaxiPID]),
	TaxiPID ! {self(), {necesito_taxi, PIDcliente, {A,B}}}.

%-------------------------------------------------------------------------------
calcula_distancia({Xcli,Ycli}, {Xtax,Ytax}) ->
	sqrt(pow(Xcli-Xtax, 2) + pow(Ycli-Ytax, 2)).


%-------------------------------------------------------------------------------
buscaCentralCercana(DatosDeCentral, {A,B}) ->
	PID = self(),
	buscaCentralCercanaAux(DatosDeCentral, {A,B}, 1000000.00, PID).

%-------------------------------------------------------------------------------
buscaCentralCercanaAux([], _, _, PID) ->
	PID;

buscaCentralCercanaAux([{PIDcentral, _, {X,Y}}|T], {A, B}, DistMenor, PID) ->
	DistanciaCliente = calcula_distancia({A,B},{X,Y}),
	io:format("Distancia entre cliente y servidor: ~p~n",[DistanciaCliente]),
	if
		DistanciaCliente < DistMenor -> buscaCentralCercanaAux(T, {A,B}, DistanciaCliente, PIDcentral);
		true -> buscaCentralCercanaAux(T, {A,B}, DistMenor, PID)
	end.
