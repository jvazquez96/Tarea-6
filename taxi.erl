-module(taxi).
-export(central/0, reportar/).

% nombre largo del servidor (nombre@máquina)
central() -> 'central@MiguelBanda'.

% funciones de interfase
reportar(Quien, Placas, Modelo) ->
	llama_central(regisrar, {Quien, Placas, Modelo}).

% cliente taxi
llama_central(Registro) ->
	Central = central(),
	monitor_node(Central, true),
	{central_taxi, Central} ! {self(), Registro},
	receive
	{central_taxi, Respuesta} ->
		monitor_node(Central, false),
		Respuesta;
	{nodedown, Central} ->
	no
	end.
