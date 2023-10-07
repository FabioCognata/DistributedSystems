-module(notification_listener).

%%API
-export([init/2, websocket_handle/2, websocket_info/2, terminate/3]).

% called when cowboy receives a request
init(Req, _State)->
  io:format("[notification_listener] -> initializing new websocket at pid: ~p~n", [self()]),
  % handing the websocket to cowboy_websocket module passing it the request and setting the idle_timeout
  {cowboy_websocket, Req, none, #{idle_timeout => infinity}}.

% called when cowboy receives a text, binary, ping or pong frame from the client
% override of the cowboy_websocket websocket_handle/2 method
websocket_handle(Frame, State) -> 
  io:format("[notification listener] -> Received frame: ~p, along with state: ~p~n",[Frame, State]),
  {ok, State}.

% called when cowboy receives an Erlang message  
% (=> from another Erlang process).
websocket_info(Info, State) ->
  io:format("[notification listener] -> Received info: ~p, along with state: ~p ~n",[Info, State]),
  {ok, State}.

% called when connection terminate
terminate(Reason, _Req, State) ->
  io:format("[notification listener] Terminate => logout request received from Pid: ~p, Reason: ~p ~n", [self(), Reason]),
  {ok, State}.