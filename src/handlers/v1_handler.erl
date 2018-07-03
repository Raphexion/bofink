-module(v1_handler).

-export([init/2]).

init(Req0, Opts) ->
    lager:info("v1"),
    Method = cowboy_req:method(Req0),
    HasBody = cowboy_req:has_body(Req0),
    Req = handle(Method, HasBody, Req0),
    {ok, Req, Opts}.

handle(<<"POST">>, true , Req0) ->
    inner(cowboy_req:read_urlencoded_body(Req0));

handle(<<"POST">>, false, Req) ->
    lager:error("POST (no body)", []),
    cowboy_req:reply(200, Req);

handle(<<"GET">>, true, Req0) ->
    {ok, Body, Req} = read_body(Req0),
    lager:error("GET ~p", [Body]),
    cowboy_req:reply(200, Req);

handle(<<"GET">>, false, Req) ->
    lager:error("GET (no body)", []),
    cowboy_req:reply(200, Req);

handle(_, _, Req) ->
    cowboy_req:reply(400, Req).

%%%
%%
%%%

inner({ok, KeyValues, Req0}) ->
    inner(maps:from_list(KeyValues), Req0).

inner(D = #{<<"user_name">> := UserName0, <<"channel_name">> := ChannelName0, <<"text">> := Text0}, Req0) ->
    UserName = binary:bin_to_list(UserName0),
    ChannelName = binary:bin_to_list(ChannelName0),
    Text = binary:bin_to_list(Text0),

    RespText = resp_text(UserName, ChannelName, string:tokens(Text, " ")),

    lager:error("User: ~p", [UserName]),
    lager:error("D: ~p", [D]),
    cowboy_req:reply(200,
		     #{<<"content-type">> => <<"text/plain">>},
		     RespText,
		     Req0).

resp_text(UserName, _ChannelName, ["I", "work", "in", Office]) ->
    UserName ++ " works in " ++ Office;

resp_text(UserName, _ChannelName, ["I", "know", Subject]) ->
    UserName ++ " knows " ++ Subject;

resp_text(UserName, ChannelName, Text) ->
    "Hey, " ++ UserName ++ " in channel " ++ ChannelName.

%%%
%%
%%%

read_body(Req0, Acc) ->
    case cowboy_req:read_body(Req0) of
	{ok, Data, Req} -> {ok, << Acc/binary, Data/binary >>, Req};
	{more, Data, Req} -> read_body(Req, << Acc/binary, Data/binary >>)
    end.

read_body(Req0) ->
    read_body(Req0, <<"">>).
