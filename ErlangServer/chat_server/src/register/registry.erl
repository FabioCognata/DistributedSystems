-module(registry).

-export([start_registry/0]).

start_registry()->
  Pid = spawn(fun() -> registry_loop(#{}) end),
  io:format("[Register] -> Starting register at pid ~p~n",[Pid]),
  register(registry, Pid).

registry_loop(Mappings) ->
  receive 
    {register, Username, Pid} ->
      io:format("[Register] -> adding user ~p with pid ~p~n",[Username, Pid]),
      NewMappings = maps:put(Username, Pid, Mappings),
      registry_loop(NewMappings);
    {lookup, Username, Caller, Json} ->
      case maps:find(Username, Mappings) of 
        Pid when Pid =/= undefined, Pid =/= error -> Caller ! {username_pid, Pid, Json};
        _ -> Caller ! {username_pid, undefined}
      end;
    {unregister, Username} ->
      io:format("[Register] -> removing user ~p from registry~n", [Username]),
      NewMappings = maps:remove(Username, Mappings),
      registry_loop(NewMappings)
    end.