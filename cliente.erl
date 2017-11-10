-module(cliente).
-export([solicitar/2, cancela/0, mandar_ok/0]).

matrizServidor() -> 'servidor@Jorges-Macbook-Pro-3'.

solicitar(Nombre, {X, Y}) ->
	server({solicita, Nombre, {X, Y}}).

registra(_, PID) ->
	register(taxi, PID).

cancela() ->
	case whereis(taxi) of
		undefined -> no_has_pedido_taxi;
		_ -> taxi ! {cancelar}
	end.


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
		{Quien, {PID, _, _}} ->
			monitor_node(Matriz, false),
			registra(Quien, PID);
		{llegar} ->
			monitor_node(Matriz, false),
			mandar_ok();
		{nodedown, Matriz} ->
			no
	end.