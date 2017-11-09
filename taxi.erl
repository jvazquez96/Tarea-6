-module(taxi).
-export(central/0, reportar/).

% nombre largo del servidor (nombre@máquina)
central() -> 'central@MiguelBanda'.

% funciones de interfase
reportar(Quien, Placas, Modelo) ->
	llama_central({Quien, Placas, Modelo}).

% cliente taxi
llama_central(Registro) ->
	Central = central(),
	monitor_node(Central, true),
	{servidor_central, Central} ! {self(), Registro},
	receive
	{servidor_central, Respuesta} ->
		monitor_node(Central, false),
		Respuesta;
	{nodedown, Central} ->
	no
	end.
