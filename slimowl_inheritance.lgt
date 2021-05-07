:- category(slimowl_inheritance,
	implements(calculate_protocol)).

	:- info([
		version is 1:0:0,
		author is 'Paul Brown',
		date is 2021-04-23,
		comment is 'Uses OWL terms without the IRI to manage inheritance (type, subClassOf)'
	]).

	% instance inheritance
	calculate(Frames, Subject, Key, Value) :-
		Key \== type,  % type isn't transitive, guard from redundant reasoning
		frames::get_data(Frames, Subject, type-'NamedIndividual'), % check for individual
		frames::get_data(Frames, Subject, type-Class),  % find its class(es)
		Class \== 'NamedIndividual',  % skip this one, nothing to inherit
		frames::get_slot(Frames, Class, Key-Value), % inherit
		Key \== type, Key \== subClassOf.  % Individuals don't inherit these

	% class inheritance
	calculate(Frames, Subject, Key, Value) :-
		Key \== type,  % type isn't transitive, guard from redundant reasoning
		frames::get_data(Frames, Subject, subClassOf-Parent), % only class has subClassOf
		frames::get_slot(Frames, Parent, Key-Value),  % inherit
		Key \== type.  % type isn't inherited

:- end_category.
