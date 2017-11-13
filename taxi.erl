-module(taxi).
-export([central/0, reportar/2, llegar/0, datos_cliente/2, llama_central/1, cancelar/2, completar/2]).

% nombre largo del servidor (nombre@máquina)
central() -> 'central@MacBook-Pro-de-Miguel'.

% funciones de interfase
reportar(Modelo, Placas) ->
	llama_central({registrar, Modelo, Placas}).

cancelar(Modelo, Placas) ->
	llama_central({cancelar, Modelo, Placas, whereis(cliente)}).

completar(Modelo, Placas) ->
	llama_central({completar, Modelo, Placas, whereis(cliente)}).

% Obtiene datos del cliente
datos_cliente (_, {Pid_Cliente, {_, _}}) ->
	register(cliente, Pid_Cliente).

% Funcion para avisar que ya llego al destino el taxi
llegar() ->
	cliente ! llegar.

% cliente taxi
llama_central(Registro) ->
	Central = central(),
	monitor_node(Central, true),
	{central_taxi, Central} ! {self(), Registro},
	receive
		{Central, Respuesta} ->
			datos_cliente(Central, Respuesta);
			%llama_central(response);
		{_, cancelar} ->
			cancelado;
			%llama_central(response);
		{_, ok} ->
			completado;
			%llama_central(response);
		{nodedown, Central} ->
			no
			%llama_central(response)
	end.



