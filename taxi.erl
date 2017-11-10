-module(taxi).
-export([central/0, reportar/2, llegar/0, datos_cliente/2, llama_central/1]).

% nombre largo del servidor (nombre@máquina)
central() -> 'central@MiguelBanda'.

% funciones de interfase
reportar(Modelo, Placas) ->
	llama_central({registrar, Modelo, Placas}).

receive
	{cliente, Cancelar} ->
	llama_central({cancelar, Modelo, Placas})
end.

datos_cliente (Pid, {_,_}) ->
	register(cliente, Pid).

llegar() ->
	cliente ! llegar.

% cliente taxi
llama_central(Registro) ->
	Central = central(),
	monitor_node(Central, true),
	{central_taxi, Central} ! {self(), Registro},
	receive
	{central_taxi, Respuesta} ->
		% monitor_node(Central, false),
		datos_cliente(Respuesta);
	{nodedown, Central} ->
		no
	end.
