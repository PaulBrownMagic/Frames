:- op(50, xfy, to).

:- object(frames(_Facets_)).

	:- info([
		version is 1:0:0,
		author is 'Paul Brown',
		date is 2021-04-23,
		comment is 'A Frame Collection is a dataset consisting of frames',
		parameters is ['Facets'-'A dictionary of facet objects']
	]).

	:- uses(navltree, [
		lookup_in/3,
		update_in/5,
		delete_in/4
		]).
	:- uses(avltree, [
		keys/2,
		lookup/3
		]).

	:- public(get_facet/2).
	:- mode(get_facet(+atom, +object), zero_or_one).
	:- info(get_facet/2, [
		comment is 'Get the object used to resolve particular facets from the parameters',
		argnames is ['Facet', 'Handler'],
		exceptions is ['Handler doesn\'t conform to the required protocol'-error(domain_error(protocol_relation, 'Handler'), logtalk('Msg'), 'Call')]
	]).
	get_facet(Facet, Object) :-
		nonvar(_Facets_),
		lookup(Facet, Object, _Facets_),
		facet_protocol(Facet, Protocol),
		once((	conforms_to_protocol(Object, Protocol)
			;	domain_error(protocol_relation, Object)
			)).

	facet_protocol(reader, reader_protocol).

	:- public(subjects/2).
	:- mode(subjects(++nested_dictionary, -list), one).
	:- info(subjects/2, [
		comment is 'The subjects in the frame collection',
		argnames is ['FrameCollection', 'Subjects']
	]).
	subjects(Frames, Subjects) :-
		keys(Frames, Subjects).

	:- public(get_frame/3).
	:- mode(get_frame(?nested_dictionary, ?atomic, +list), zero_or_more).
	:- info(get_frame/3, [
		comment is 'Read the value of the slots in the frame',
		argnames is ['FrameCollection', 'Subject', 'Slots'],
		exceptions is [
			'``FrameCollection`` is a variable'-error(instantiation_error, logtalk(get_frame('FrameCollection', 'Subject', 'Slots'), 'Call'))
			]
	]).
	get_frame(Collection, Subject, Slots) :-
		(	var(Collection)
		->  instantiation_error
		;   get_facet(reader, Reader)
		->	get_frame(Collection, Reader, Subject, Slots)
		;	var(Slots)
		->	findall(Key-Value, get_data(Collection, Subject, Key-Value), Slots)
		;	meta::map(get_data(Collection, Subject), Slots)
		).
	get_frame(Collection, Reader, Subject, Slots) :-
		(	var(Slots)
		->	findall(Key-Value, get_slot(Collection, Reader, Subject, Key-Value), Slots)
		;	meta::map(get_slot(Collection, Reader, Subject), Slots)
		).


	:- public(get_data/3).
	:- mode(get_data(?nested_dictionary, ?atomic, ?pair), zero_or_more).
	:- info(get_data/3, [
		comment is 'Read the value of a slot in the frame with no reasoning',
		argnames is ['FrameCollection', 'Subject', 'Key-Value'],
		exceptions is [
			'``FrameCollection`` is a variable'-error(instantiation_error, logtalk(get_data('FrameCollection', 'Subject', 'Key-Value'), 'Call'))
			]
	]).
	get_data(Collection, _, _) :-
		var(Collection),
		instantiation_error.
	% Direct from frame
	get_data(Collection, Subject, Key-Value) :-
		lookup_in([Subject, Key], Values, Collection),
		slot_value(Values, Value).

	:- public(get_slot/3).
	:- mode(get_slot(?nested_dictionary, ?atomic, ?pair), zero_or_more).
	:- info(get_slot/3, [
		comment is 'Get the value of a slot in the frame, includes read facet',
		argnames is ['FrameCollection', 'Subject', 'Key-Value'],
		exceptions is [
			'``FrameCollection`` is a variable'-error(instantiation_error, logtalk(get_data('FrameCollection', 'Subject', 'Key-Value'), 'Call'))
			]
	]).
	get_slot(Collection, _, _) :-
		var(Collection),
		instantiation_error.
	get_slot(Collection, Subject, Key-Value) :-
		(	get_facet(reader, Reader)
		->	get_slot(Collection, Reader, Subject, Key-Value)
		;	get_data(Collection, Subject, Key-Value)
		).
	get_slot(Collection, _Reader, Subject, Key-Value) :-
		get_data(Collection, Subject, Key-Value).
	get_slot(Collection, Reader, Subject, Key-Value) :-
		Reader::calculate(Collection, _Facets_, Subject, Key, Value).

	:- public(slot_value/2).
	:- mode(slot_value(+term, ?value), zero_or_more).
	:- info(slot_value/2, [
		comment is 'Extract the value from the slot',
		argnames is ['SlotValue', 'Value']
	]).
	slot_value(Values, Value) :-
		(	is_list(Values) % If it's a list
		->  list::member(Value, Values)  % yield from it
		;	Value = Values  % otherwise we've got it
		).

	:- public(update_frame/4).
	:- mode(update_frame(++nested_dictionary, +atomic, ++list(pair), -nested_dictionary), zero_or_one).
	:- info(update_frame/4, [
		comment is 'Update the ``FrameCollection`` so that the slots described by ``Subject`` are as described by the key-value pairs',
		argnames is ['OldFrames', 'Subject', 'UpdatePairs', 'NewFrames']
	]).
	% facets:
	%	- before_update_call (eg. validation, permission),
	%	- before_update_alter_pair (eg. string/unit manipulation),
	%	- after_update_call (eg. logging)
	% Should handle list slots
	update_frame(OldFrames, _Subject, [], OldFrames).
	update_frame(OldFrames, Subject, [Pair|UpdatePairs], NewFrames) :-
		once((	Pair = Key-OldValue to NewValue
			;	Pair = Key-NewValue
			)),
		update_frame_(OldFrames, Subject, Key, OldValue, NewValue, AccFrames),
		update_frame(AccFrames, Subject, UpdatePairs, NewFrames).

	update_frame_(OldFrames, Subject, Key, OldValue, NewValue, AccFrames) :-
		lookup_in([Subject, Key], Values, OldFrames),
		(	is_list(Values)
		->  nonvar(OldValue),
			list::select(OldValue, Values, NewValue, NewValues),
			update_in(OldFrames, [Subject, Key], _, NewValues, AccFrames)
		;	update_in(OldFrames, [Subject, Key], OldValue, NewValue, AccFrames)
		).

	:- public(delete_frame/3).
	:- mode(delete_frame(++nested_dictionary, +atomic, -nested_dictionary), one).
	:- info(delete_frame/3, [
		comment is 'Delete the frame associated with ``Subject`` from the frames',
		argnames is ['OldFrames', 'Subject', 'NewFrames']
	]).
	% facets:
	%	- before_delete_call (eg. permission),
	%	- after_delete_call (eg. logging)
	delete_frame(OldFrames, Subject, NewFrames) :-
		delete_in(OldFrames, [Subject], _Slots, NewFrames).

	:- public(delete_frame/4).
	:- mode(delete_frame(++nested_dictionary, +atomic, +list(pair), -nested_dictionary), one).
	:- info(delete_frame/4, [
		comment is 'Delete the pairs associated with ``Subject`` from the frames. Keys must be ground, values will unify.',
		argnames is ['OldFrames', 'Subject', 'Pairs', 'NewFrames']
	]).
	% facets:
	%	- before_delete_call (eg. permission),
	%	- after_delete_call (eg. logging)
	% Should handle list slots
	delete_frame(OldFrames, _Subject, [], OldFrames).
	delete_frame(OldFrames, Subject, [Key-Value|DeletePairs], NewFrames) :-
		delete_frame_(OldFrames, Subject, Key, Value, AccFrames),
		delete_frame(AccFrames, Subject, DeletePairs, NewFrames).

	delete_frame_(OldFrames, Subject, Key, Value, AccFrames):-
		lookup_in([Subject, Key], Values, OldFrames),
		(	is_list(Values)
		->	(	Values = [Value]
			->	delete_in(OldFrames, [Subject, Key], Values, AccFrames)
			;	list::select(Value, Values, Deleted),
				update_in(OldFrames, [Subject, Key], Values, Deleted, AccFrames)
			)
		;	delete_in(OldFrames, [Subject, Key], Value, AccFrames)
		).

:- end_object.
