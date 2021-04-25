:- category(classic_inheritance,
	implements(reader_protocol)).

	:- info([
		version is 1:0:0,
		author is 'Paul Brown',
		date is 2021-04-23,
		comment is 'Uses classic terms to manage inheritance (isa, ako)'
	]).

	% instance inheritance
	calculate(Frames, Facets, Subject, Key, Value) :-
		frames(Facets)::get_data(Frames, Subject, isa-Class),  % find its class(es)
		frames(Facets)::get_slot(Frames, Class, Key-Value). % inherit

	% class inheritance: dfs, also consider bfs and fish-hook
	calculate(Frames, Facets, Subject, Key, Value) :-
		frames(Facets)::get_data(Frames, Subject, ako-Parent), % find its parents
		frames(Facets)::get_slot(Frames, Parent, Key-Value).  % inherit

:- end_category.
