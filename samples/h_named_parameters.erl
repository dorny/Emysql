% ------------------------------------------------------------------------
% Emysql: Statement with named parameters - minimal sample
% M. Dorner <dorner.michal@gmail.com>
% 7 July 2013
% ------------------------------------------------------------------------
%
% Create local mysql database (or re-use the one made for a_hello):
%
% $ mysql ...
% mysql> create database hello_database;
% mysql> use hello_database;
% mysql> create table hello_table (hello_text char(20));
% mysql> grant all privileges on hello_database.* to hello_username@localhost identified by 'hello_password';
% mysql> quit
%
% On *nix build and run using the batch a_hello in folder samples/:
%
% $ ./d_prepared_statement
%
% - or -
%
% Make emysql and start this sample directly, along these lines:
%
% $ cd Emysql
% $ make
% $ cd samples
% $ erlc d_prepared_statement.erl
% $ erl -pa ../ebin -s d_prepared_statement run -s init stop -noshell
%
% ------------------------------------------------------------------------
%
% Expected Output:
%
% ...
% ... many PROGRESS REPORT lines ...
% ...
%
% Result: {result_packet,32,
%                      [{field,2,<<"def">>,<<"hello_database">>,
%                               <<"hello_table">>,<<"hello_table">>,
%                               <<"hello_text">>,<<"hello_text">>,254,<<>>,33,
%                               60,0,0}],
%                       [[<<"Hello World!">>]],
%                       <<>>}
%
% ------------------------------------------------------------------------

-module(h_named_parameters).
-export([run/0]).

run() ->

	% application:start(sasl),
	crypto:start(),
	application:start(emysql),

	emysql:add_pool(hello_pool, 1,
		"hello_username", "hello_password", "localhost", 3306,
		"hello_database", utf8),


	% Clean Database
	emysql:execute(hello_pool,<<"DELETE FROM hello_table">>),

	%% -------------------------------------------------------------------
	%% Prepare Query with named parameters
	%% - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

	{ok, Stmt, Map} = emysql_util:named_parameters("INSERT INTO hello_table SET hello_text = :hello_text"),


	%% -------------------------------------------------------------------
	%% Execute Query
	%% - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

	Parameters = [{"hello_text",<<"'Hello World!'">>}],
	Args = emysql_util:map_parameters(Parameters, Map),
	emysql:execute(hello_pool, Stmt, Args),


	%% -------------------------------------------------------------------
	%% Check
	%% - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

	Result = emysql:execute(hello_pool, "SELECT * from hello_table"),
	io:format("~n~s~n", [string:chars($-,72)]),
	io:format("~n~p~n", [Result]),

    ok.


