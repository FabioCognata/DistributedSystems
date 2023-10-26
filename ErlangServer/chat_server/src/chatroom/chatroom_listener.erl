-module(chatroom_listener).

%%API
-export([init/2, websocket_handle/2, websocket_info/2, terminate/3]).

% called when cowboy receives a request
init(Req, _State)->
  % retrieve username query string
  #{username:=CurrentUsername} = cowboy_req:match_qs([{username, nonempty}], Req),
  io:format("[chatroom_listener] -> initializing new websocket at pid: ~p for user ~p~n",[self(),CurrentUsername]),
  
  % save currentUsername and Pid in a map
  RegisterPid = whereis(registry),
  RegisterPid ! {register, CurrentUsername, self()},
  InitialState = #{username => CurrentUsername, register_pid => RegisterPid},
  
  % handing the websocket to cowboy_websocket module passing it the request using infinite idle timeout option
  {cowboy_websocket, Req, InitialState, #{idle_timeout => infinity}}.

% override of the cowboy_websocket websocket_handle/2 method
websocket_handle(Frame={text, Message}, State) -> 
  #{username := Username, register_pid := RegisterPid} = State,
  io:format("[chatroom listener] -> Received frame: ~p, along with state: ~p~n",[Frame, State]),
  DecodedMsg = jsone:try_decode(Message),
  case element(1, DecodedMsg) of
    ok -> 
      Json = element(2, DecodedMsg),
      io:format("[chatroom_listener] -> jsone:try_decode: correctly received json: ~p~n",[Json]),
      {ok, UserToSend} = maps:find(<<"username">>, Json),
      RegisterPid ! {lookup, UserToSend, self(), Json};
    error ->
      io:format("[chatroom_listener] -> jsone:try_decode: error: ~p~n",[element(2, DecodedMsg)]),
      {ok, State}
    end,
  {ok, State}.

% called when cowboy receives an Erlang message  
% (=> from another Erlang process).
websocket_info(Info, State) ->
  #{username := _Username, register_pid := RegisterPid} = State,
  io:format("[chatroom listener] -> Received info: ~p, along with state: ~p ~n",[Info, State]),
  case Info of
    % receive userToSendPid from register
    {username_pid, undefined} -> 
      io:format("[chatroom_listener] -> UserToSend not online~n");
    % receive userToSendPid from register
    {username_pid, {ok,Pid}, Json} -> 
      io:format("[chatroom_listener] -> UserToSendPid: ~p, Json:~p~n",[Pid, Json]),
      case is_pid(Pid) of
        true ->
          io:format("[chatroom_listener] -> send message:~p to Pid:~p~n",[Json, Pid]),
          Pid ! {send_message, Json, self()};
        false -> 
          io:format("[chatroom_listener] -> Pid is not valid: ~p~n",[Pid])
      end;
    % receive message from another process
    {send_message, Json, ReceivedFromPid} ->
      io:format("[chatroom_listener] -> received message:~p from:~p~n",[Json, ReceivedFromPid]);
    _ -> 
      io:format("[chatroom_listener] -> received unknown message~n")
  end,
  {ok, State}.

% called when connection terminate
terminate(Reason, _Req, State) ->
  io:format("[chatroom listener] -> Closed websocket connection on host: ~p, Reason: ~p ~n", [self(), Reason]),
  if 
    State == [] ->
      io:format("[chatroom listener] -> Empty state~n");
    true ->
      #{username := Username, register_pid := RegisterPid} = State,
      RegisterPid ! {unregister, Username}
    end,
  {ok, State}.