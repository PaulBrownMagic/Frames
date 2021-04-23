:- category(classic_inheritance,
	implements(calculator_protocol)).

	:- info([
		version is 1:0:0,
		author is 'Paul Brown',
		date is 2021-04-23,
		comment is 'Uses classic terms to manage inheritance (isa, ako)'
	]).

	:- uses(navltree, [
		lookup_in/3
		]).

	% instance inheritance
	calculate(Frames, Subject, Key, Value) :-
		lookup_in([Subject, isa], Values, Frames),  % find its class(es)
		frames::slot_value(Values, Class),
		frames::get_slot(Frames, Class, Key-Value). % inherit

	% class inheritance: dfs, also consider bfs and fish-hook
	calculate(Frames, Subject, Key, Value) :-
		lookup_in([Subject, ako], Values, Frames), % find its parents
		frames::slot_value(Values, Parent),
		frames::get_slot(Frames, Parent, Key-Value).  % inherit

:- end_category.
