:- object(frames).

	:- info([
		version is 1:0:0,
		author is 'Paul Brown',
		date is 2021-04-23,
		comment is 'A Frame Collection is a dataset consisting of frames'
	]).

	:- dynamic(facet_/2).
	:- private(facet_/2).
	:- mode(facet_(+atom, -object), zero_or_one).
	:- info(facet_/2, [
		comment is 'The object to query for a particular facet',
		argnames is ['Facet', 'Object']
	]).

	:- uses(navltree, [
		lookup_in/3
		]).

	:- public(set_facet/2).
	:- mode(set_facet(+atom, +object), zero_or_one).
	:- info(set_facet/2, [
		comment is 'Set an object used to resolve particular facets',
		argnames is ['Facet', 'Handler'],
		exceptions is ['Handler doesn\'t conform to the required protocol'-error(domain_error(protocol_relation, 'Handler'), logtalk('Msg'), 'Call')]
	]).
	set_facet(calculate, Object) :-
		(	conforms_to_protocol(Object, calculator_protocol)
		->	retractall(facet_(calculate, _)),
			assertz(facet_(calculate, Object))
		;	domain_error(protocol_relation, Object)
		).

	:- public(get_frame/3).
	:- mode(get_frame(?nested_dictionary, ?atomic, +list), zero_or_more).
	:- info(get_frame/3, [
		comment is 'Read the value of the slots in the frame',
		argnames is ['FrameCollection', 'Subject', 'Slots'],
		exceptions is [
			'``Slots`` is a variable'-error(instantiation_error, logtalk(get_frame('FrameCollection', 'Subject', 'Slots'), 'Call')),
			'``FrameCollection`` is a variable'-error(instantiation_error, logtalk(get_frame('FrameCollection', 'Subject', 'Slots'), 'Call'))
			]
	]).
	get_frame(Collection, Subject, Slots) :-
		(	once((var(Slots) ; var(Collection)))
		->  instantiation_error
		;	meta::map(get_slot(Collection, Subject), Slots)
		).

	:- public(get_slot/3).
	:- mode(get_slot(?nested_dictionary, ?atomic, ?pair), zero_or_more).
	:- info(get_slot/3, [
		comment is 'Read the value of a slot in the frame',
		argnames is ['FrameCollection', 'Subject', 'Key-Value'],
		exceptions is [
			'``FrameCollection`` is a variable'-error(instantiation_error, logtalk(get_slot('FrameCollection', 'Subject', 'Key-Value'), 'Call'))
			]
	]).
	get_slot(Collection, _, _) :-
		var(Collection),
		instantiation_error.
	% Direct from frame
	get_slot(Collection, Subject, Key-Value) :-
		lookup_in([Subject, Key], Values, Collection),
		slot_value(Values, Value).
	% Calculated
	get_slot(Collection, Subject, Key-Value) :-
		facet_(calculate, Calculator),
		Calculator::calculate(Collection, Subject, Key, Value).

	% Extract the value from a slot
	:- public(slot_value/2).
	:- mode(slot_value(+term, ?value), zero_or_more).
	:- info(slot_value/2, [
		comment is 'Extract the value from the leaf of a slot',
		argnames is ['SlotValue', 'Value']
	]).
	slot_value(Values, Value) :-
		(	list::valid(Values) % If it's a list
		->  list::member(Value, Values)  % yield from it
		;	Value = Values  % otherwise we've got it
		).

:- end_object.
