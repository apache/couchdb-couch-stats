-module(couch_stats_tests).

-include_lib("eunit/include/eunit.hrl").
         
run_test_() ->
    {setup,
     fun setup/0,
     fun teardown/1,
     [{"checking the metric bulk_reads",
        fun check_metric_bulk_reads/0}]}.

setup() ->
    test_util:load_applications_with_stats(),
    test_util:start_applications([couch_stats]).

teardown(_) ->
    test_util:stop_applications([couch_stats]).

check_metric_bulk_reads() ->
    NumberOfDocsMin = 10,
    NumberOfDocsMax = 100,
    ?assertEqual(ok, couch_stats:update_histogram([couchdb, httpd, bulk_reads], NumberOfDocsMin)),
    ?assertEqual(ok, couch_stats:update_histogram([couchdb, httpd, bulk_reads], NumberOfDocsMax)),
    couch_stats_aggregator:flush(),
    Props = proplists:get_value([couchdb, httpd, bulk_reads], couch_stats:fetch()),
    ?assertNotEqual(Props, undefined),
    Type = proplists:get_value(type, Props),
    ?assertEqual(histogram, Type).
