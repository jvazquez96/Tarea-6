-module(central_taxi).
-import(lists, [append/2]).
-export([inicio/0, registro/2, central/4, para/0, listar/0]).

inicio() ->
	register(central_taxi,
		spawn(central_taxi, central_taxi, [[]])).

matriz() -> 'servidor@Kinedus-MacBook-Pro-2'.

registro(Quien, {X, Y}) -> 
	llama_servidor({registro, Quien, {X, Y}}).

central(Disponibles, Completados, Cancelados, Servicios) ->
	receive
		{De, {registrar, Modelo, Placas}} ->
			De ! {central_taxi, ok},
			central(registro(De, Modelo, Placas, Disponibles), Completados, Cancelados, Servicios);
		{De, {cancelar, Modelo, Placas, Cliente}} ->
			cancelado(De, Modelo, Placas, Cliente, Disponibles, Completados, Cancelados, Servicios);
		{De, {completar, Modelo, Placas, Cliente}} ->
			completado(De, Modelo, Placas, Cliente, Disponibles, Completados, Cancelados, Servicios);
		{De, {necesito_taxi, Cliente, X, Y}} ->
			asigna_taxi(De, Cliente, Disponibles, Completados, Cancelados, Servicios, X, Y);
		lista ->
			io:format("Disponibles:~n"),
			disponibles(Disponibles),
			io:format("En servicio:~n"),
			servicios(Servicios),
			central(Disponibles, Completados, Cancelados, Servicios);
		para -> void
	end.

% Sirve para parar la ejecución
para() ->
	central_taxi ! para.

% Sirve para listar los datos
listar() ->
	central_taxi ! lista.

disponibles([]) ->
	io:format("----------~n");

disponibles([{_, Modelo, Placas}|Y]) ->
	io:format("Placas: ~p Modelo: ~p~n", Placas, Modelo),
	disponibles(Y).

servicios([]) ->
	io:format("----------~n");

servicios([{Taxi, Cliente}|Y]) ->
	io:format("Taxi: ~p Cliente: ~p~n", Taxi, Cliente),
	servicios(Y).

% llama al servidor para registro
llama_servidor(Mensaje) ->
	Matriz =  matriz(),
	monitor_node(Matriz, true),
	{servidor_taxi, Matriz} ! {self(), Mensaje},
	receive
		{servidor_taxi, Respuesta} ->
			monitor_node(Matriz, false),
			Respuesta;
		{nodedown, Matriz} ->
			no
	end.

% funcion que registra un taxi
registro(De, Modelo, Placas, Disponibles) ->
	lists:append(Disponibles, [{De, Modelo, Placas}]).

% funcion que registra los viajes cancelados
cancelado(De, Modelo, Placas, Cliente, Disponibles, Completados, Cancelados, Servicios) ->
	central(lists:append(Disponibles, [{De, Modelo, Placas}]), Completados, list:append(Cancelados, [{De, Cliente}]), quita_servicio(De, Servicios)).

% funcion que registra los viajes completados
completado(De, Modelo, Placas, Cliente, Disponibles, Completados, Cancelados, Servicios) ->
	central(lists:append(Disponibles, [{De, Modelo, Placas}]), lists:append(Completados, [{De, Cliente}]), Cancelados, quita_servicio(De, Servicios)).

% funcion que asigna el taxi a un cliente solicitado por el servidor
asigna_taxi(De, Cliente, [], Completados, Cancelados, Servicios, _, _) ->
	De ! {self(), {sin_taxis, Cliente}},
	central([], Completados, Cancelados, Servicios);

asigna_taxi(De, Cliente, [{Taxi, Modelo, Placas}|Y], Completados, Cancelados, Servicios, X, Y) ->
	De ! {self(), Cliente, {Taxi, Modelo, Placas}},
	Taxi ! {self(), {Cliente, {X, Y}}},
	central(Y, Completados, Cancelados, lists:append(Servicios, [{Taxi, Cliente}])).

% funcion que quita el servicio una lista
quita_servicio(De, [{De, _}|Y]) ->
	Y;

quita_servicio(De, [X|Y]) ->
	list:append(X, quita_servicio(De, Y)).