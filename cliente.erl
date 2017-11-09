-module(cliente).
-export([solicitar/2, cancela/0, ok/0]).

matrizServidor() -> 'servidor@Jorges-Macbook-Pro-3'.

% El cliente se debe comunicar con el servidor de taxis para solicitar un
% servicio. El cliente debe incluir su nombre (un átomo) y su localización en la
% solicitud (una tupla de números {X,Y}), y esperar a que el servidor le
% conteste. El servidor le confirma el servicio al cliente con un número de
% servicio, el PID del taxi que lo llevará, el tipo de auto (un átomo) y la placa
% de la unidad (otro átomo), o bien, con un átomo que establece que no hay
% taxis disponibles. Si el cliente recibe una asignación de servicio, este puede
% cancelarla mediante un mensaje directo al taxi. El proceso del cliente fca
% termina cuando el taxi le avisa que ya llegó por él (después de contestarle
% ok), cuando él le avisa al taxi que cancela su servicio, o cuando el servidor le
% avisa que no hay taxis disponibles. El proceso del cliente debe terminar
% automáticamente si el nodo o proceso del servidor no existen o terminan.


solicitar(Nombre, {X, Y}) ->
	server({solicita, Nombre, {X, Y}}).

registra({_, PID, _, _}) ->
	register(taxi, PID).

cancela() ->
	taxi ! {cancelar}.

ok() ->
	server({terminar, taxi}).

server(Solicitud) ->
	Matriz = matrizServidor(),
	monitor_node(Matriz, true),
	{servidor_taxi, Matriz} ! {self(), Solicitud},
	receive
		{servidor_taxi, Respuesta} ->
			monitor_node(Matriz, false),
			registra(Respuesta);
		{nodedown, Matriz} ->
			no
	end.