:- category(slimowl_inheritance,
	implements(calculator_protocol)).

	:- info([
		version is 1:0:0,
		author is 'Paul Brown',
		date is 2021-04-23,
		comment is 'Uses OWL terms without the IRI to manage inheritance (type, subClassOf)'
	]).

	:- uses(navltree, [
		lookup_in/3
		]).

	% instance inheritance
	calculate(Frames, Subject, Key, Value) :-
		Key \== type,  % type isn't transitive, guard from redundant reasoning
		lookup_in([Subject, type], Values, Frames),  % check for individual
		frames::slot_value(Values, 'NamedIndividual'),
		lookup_in([Subject, type], Values, Frames),  % find its class(es)
		frames::slot_value(Values, Class),
		Class \== 'NamedIndividual',  % skip this one, nothing to inherit
		frames::get_slot(Frames, Class, Key-Value), % inherit
		Key \== type, Key \== subClassOf.  % Individuals don't inherit these

	% class inheritance
	calculate(Frames, Subject, Key, Value) :-
		Key \== type,  % type isn't transitive, guard from redundant reasoning
		lookup_in([Subject, subClassOf], Values, Frames), % only class has subClassOf
		frames::slot_value(Values, Parent),
		frames::get_slot(Frames, Parent, Key-Value),  % inherit
		Key \== type.  % type isn't inherited

:- end_category.
