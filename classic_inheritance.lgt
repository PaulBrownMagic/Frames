:- object(classic_inheritance,
	implements(calculate_protocol)).

	:- info([
		version is 1:0:0,
		author is 'Paul Brown',
		date is 2021-04-23,
		comment is 'Uses classic terms to manage inheritance (isa, ako)'
	]).

	% instance inheritance
	calculate(Frames, Subject, Key, Value) :-
		frames::get_data(Frames, Subject, isa-Class),  % find its class(es)
		frames::get_slot(Frames, Class, Key-Value). % inherit

	% class inheritance: dfs, also consider bfs and fish-hook
	calculate(Frames, Subject, Key, Value) :-
		frames::get_data(Frames, Subject, ako-Parent), % find its parents
		frames::get_slot(Frames, Parent, Key-Value).  % inherit

	% reflexive
	calculate(Frames, Subject, ako, Subject) :-
		frames::get_data(Frames, Subject, ako-_).

:- end_object.
