-module(complex).
-compile(export_all).

-define(COUNT, 500).
yield(Name,Ctx)->
  Header = maps:get(header,Ctx),
  <<Name/binary," is ",Header/binary>>.

context()->
    A = maps:from_list([{name, "red"}, {current, true}, {url, "#Red"}]),
    B = maps:from_list([{name, "green"}, {current, true}, {url, "#Green"}]),
    C = maps:from_list([{name, "blue"}, {current, false}, {url, "#Blue"}]),
    #{
      items => [A,B,C],
      header => <<"Colors">>,
      list => true,
      empty => false,
      user => #{ name => <<"David Gao">>},
      level => #{ name => <<"VIP User">> },
      yield => [fun yield/2,<<"Test">>]
    }.



%%---------------------------------------------------------------------------

start() ->
  code:add_patha("../ebin"),
  code:add_patha("../deps/ailib/ebin"),
  application:start(ailib),
  application:start(aihtml),

  {ok,CWD} = file:get_cwd(),
  ai_mustache:bootstrap(#{views => CWD}),

  Output = ai_mustache:render("complex",context()),
  io:format("~ts~n",[Output]),
  T0 = os:timestamp(),
  render(context(), ?COUNT),
  T1 = os:timestamp(),
  Diff = timer:now_diff(T1, T0),
  Mean = Diff / ?COUNT,
  io:format("~nTotal time: ~.2fs~n", [Diff / 1000000]),
  io:format("Mean render time: ~.2fms~n", [Mean / 1000]).


  render(_Ctx,0) ->
    ok;
  render(Ctx,N) ->
    ai_mustache:render("complex",Ctx),
    render(Ctx,N - 1).
