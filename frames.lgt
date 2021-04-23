:- object(frames).

	:- info([
		version is 1:0:0,
		author is 'Paul Brown',
		date is 2021-04-23,
		comment is 'A Frame Collection is a dataset consisting of frames'
	]).

	:- dynamic(facet_/2).

	:- uses(navltree, [
		lookup_in/3
		]).
	:- uses(avltree, [
		lookup/3,
		keys/2,
		empty/1,
		delete/4,
		as_list/2
		]).

	:- public(set_facet/2).
	:- mode(set_facet(+atom, +object), zero_or_one).
	:- info(set_facet/2, [
		comment is 'Set an object used to resolve particular facets',
		argnames is ['Facet', 'Delegator']
	]).
	set_facet(calculate, Object) :-
		implements_protocol(Object, calculator_protocol),
		retractall(facet_(calculate, _)),
		assertz(facet_(calculate, Object)).

	:- public(get_frame/3).
	:- mode(get_frame(?nested_dictionary, ?atomic, +list), zero_or_more).
	:- info(get_frame/3, [
		comment is 'Read the value of the slots in the frame',
		argnames is ['FrameCollection', 'Subject', 'Slots']
	]).
	get_frame(Collection, Subject, Slots) :-
		meta::map(get_slot(Collection, Subject), Slots).

	:- public(get_slot/3).
	:- mode(get_slot(?nested_dictionary, ?atomic, ?pair), zero_or_more).
	:- info(get_slot/3, [
		comment is 'Read the value of a slot in the frame',
		argnames is ['FrameCollection', 'Subject', 'Key-Value']
	]).
	% Direct from frame
	get_slot(Collection, Subject, Key-Value) :-
		lookup_in([Subject, Key], Values, Collection),
		slot_value(Values, Value).
	% Calculated
	get_slot(Collection, Subject, Key-Value) :-
		facet_(calculate, Calculator),
		Calculator::calculate(Collection, Subject, Key, Value).
	% Frame is NamedIndividual, inherit from class
	get_slot(Collection, Subject, Key-Value) :-
		Key \== type,  % type isn't transitive, guard from redundant reasoning
		lookup_in([Subject, type], Values, Collection),  % check for individual
		slot_value(Values, 'NamedIndividual'),
		lookup_in([Subject, type], Values, Collection),  % find its class(es)
		slot_value(Values, Class),
		Class \== 'NamedIndividual',  % skip this one, nothing to inherit
		get_slot(Collection, Class, Key-Value), % inherit
		Key \== type, Key \== subClassOf.  % Individuals don't inherit these
	% Frame is a Class, inheret from parents
	get_slot(Collection, Subject, Key-Value) :-
		Key \== type,  % type isn't transitive, guard from redundant reasoning
		lookup_in([Subject, subClassOf], Values, Collection), % only class has subClassOf
		slot_value(Values, Parent),
		get_slot(Collection, Parent, Key-Value),  % inherit
		Key \== type.  % type isn't inherited

	% Extract the value from a slot
	slot_value(Values, Value) :-
		(	list::valid(Values) % If it's a list
		->  list::member(Value, Values)  % yield from it
		;	Value = Values  % otherwise we've got it
		).

:- end_object.
