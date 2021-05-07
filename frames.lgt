:- op(50, xfy, to).

:- object(frames).

	:- info([
		version is 1:0:0,
		author is 'Paul Brown',
		date is 2021-04-23,
		comment is 'A Frame Collection is a dataset consisting of frames'
	]).

	:- uses(navltree, [
		insert_in/4,
		lookup_in/3,
		update_in/5,
		delete_in/4
		]).
	:- uses(avltree, [
		keys/2,
		lookup/3
		]).

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
		;	var(Slots)
		->	findall(Key-Value, get_slot(Collection, Subject, Key-Value), Slots)
		;	meta::map(get_slot(Collection, Subject), Slots)
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
		get_data(Collection, Subject, Key-Value).
	get_slot(Collection, Subject, Key-Value) :-
		conforms_to_protocol(Calc, calculate_protocol),
		current_object(Calc),
		Calc::calculate(Collection, Subject, Key, Value).

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
	delete_frame(OldFrames, Subject, NewFrames) :-
		delete_in(OldFrames, [Subject], _Slots, NewFrames).

	:- public(delete_frame/4).
	:- mode(delete_frame(++nested_dictionary, +atomic, +list(pair), -nested_dictionary), one).
	:- info(delete_frame/4, [
		comment is 'Delete the pairs associated with ``Subject`` from the frames. Keys must be ground, values will unify.',
		argnames is ['OldFrames', 'Subject', 'Pairs', 'NewFrames']
	]).
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

	:- public(add_frame/4).
	:- mode(add_frame(++nested_dictionary, +atomic, ++list(pair), -nested_dictionary), zero_or_one).
	:- info(add_frame/4, [
		comment is 'Add to the ``FrameCollection`` so that the slots described by ``Subject`` are as described by the key-value pairs',
		argnames is ['OldFrames', 'Subject', 'UpdatePairs', 'NewFrames']
	]).
	add_frame(OldFrames, _Subject, [], OldFrames).
	add_frame(OldFrames, Subject, [Key-NewValue|UpdatePairs], NewFrames) :-
		ground([Subject, Key, NewValue]),
		add_frame_(OldFrames, Subject, Key, NewValue, AccFrames),
		add_frame(AccFrames, Subject, UpdatePairs, NewFrames).

	add_frame_(OldFrames, Subject, Key, NewValue, AccFrames) :-
		(	lookup_in([Subject, Key], Values, OldFrames), is_list(Values)
		->	insert_in(OldFrames, [Subject, Key], [NewValue|Values], AccFrames)
		;	insert_in(OldFrames, [Subject, Key], NewValue, AccFrames)
		).

:- end_object.
