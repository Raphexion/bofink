%%%-------------------------------------------------------------------
%% @doc bofink public API
%% @end
%%%-------------------------------------------------------------------

-module(bofink_app).

-behaviour(application).

%% Application callbacks
-export([start/2, stop/1]).

%%====================================================================
%% API
%%====================================================================

start(_StartType, _StartArgs) ->
    Dispatch = cowboy_router:compile([
				      {'_', [
					     {"/v1", v1_handler, []},
					     {"/", cowboy_static, {priv_file, bofink, "static/index.html"}},
					     {"/assets/[...]", cowboy_static, {priv_dir, bofink, "static/assets"}}
					    ]}
				     ]),

    {ok, _} = cowboy:start_clear(http, [{port, 8443}], #{
					 env => #{dispatch => Dispatch}
					}),

    bofink_sup:start_link().

%%--------------------------------------------------------------------
stop(_State) ->
    ok.

%%====================================================================
%% Internal functions
%%====================================================================
