-module(cliente).
-export([solicitar/2, cancela/0, mandar_ok/0]).

matrizServidor() -> 'servidor@jorges-mbp-3'.

registra(PID) ->
	register(taxista, PID).

% Funciones de interface

% Funcion para solicitar un taxi se envia el nombre 
% de la persona junto con una tupla de coordenadas.
solicitar(Nombre, {X, Y}) ->
	server({solicita, Nombre, {X, Y}}).

% Funcion para cancelar el viaje taxi
cancela() ->
	case whereis(taxi) of
		undefined -> no_has_pedido_taxi;
		_ -> taxi ! {cancelar}
	end.

% Funcion para terminar un viaje de taxi
mandar_ok() ->
	case whereis(taxi) of 
		undefined -> no_has_pedido_taxi;
		_ -> taxi ! ok
	end.

server(Solicitud) ->
	Matriz = matrizServidor(),
	monitor_node(Matriz, true),
	{servidor_taxi, Matriz} ! {self(), Solicitud},
	receive
		{_, {PID, _, _}} ->
			%monitor_node(Matriz, false),
			registra(PID);
		{llegar} ->
			monitor_node(Matriz, false),
			mandar_ok();
		{no} ->
			io:format("No hay centrales disponibles~n",[]);
		{_, no_hay_taxis} ->
			io:format("No hay taxis disponibles~n",[]);
		{nodedown, Matriz} ->
			adios
	end.
