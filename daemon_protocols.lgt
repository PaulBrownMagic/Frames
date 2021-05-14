:- protocol(calculate_protocol).

	:- info([
		version is 1:0:0,
		author is 'Paul Brown',
		date is 2021-04-23,
		comment is 'Protocol for objects that implement the calculate facet on read'
	]).

	:- public(calculate/4).
	:- mode(calculate(++nested_dictionary, ?atomic, ?atomic, ?term), zero_or_more).
	:- info(calculate/4, [
		comment is 'For the given ``Frames``, and ``Subject``, calculate the ``Value`` of the ``Slot``',
		arguments is [
			'Frames'-'A Nested Dictionary of Frames',
			'Subject'-'The Frame subject',
			'Slot'-'The name of the slot to calculate',
			'Value'-'The value to calculate'
		]
	]).

:- end_protocol.

:- protocol(frames_on_add).

	:- info([
		version is 1:0:1,
		author is 'Paul Brown',
		date is 2021-05-13,
		comment is 'Daemon called when an ``add_frame/4`` is called'
	]).

	:- public(after_add/3).
	:- mode(after_add(++nested_dictionary, +atomic, --nested_dictionary), zero_or_more).
	:- info(after_add/3, [
		comment is 'After a frame is added',
		argnames is ['Frames', 'Subject', 'UpdatedFrames']
	]).
	:- public(after_add/5).
	:- mode(after_add(++nested_dictionary, +atomic, +atomic, +term, --nested_dictionary), zero_or_more).
	:- info(after_add/5, [
		comment is 'After a frame is added',
		argnames is ['Frames', 'Subject', 'Slot', 'Value', 'UpdatedFrames']
	]).

:- end_protocol.

:- protocol(frames_on_update).

	:- info([
		version is 1:0:1,
		author is 'Paul Brown',
		date is 2021-05-13,
		comment is 'Daemon called when an ``update_frame/4`` is called'
	]).

	:- public(after_update/3).
	:- mode(after_update(++nested_dictionary, +atomic, --nested_dictionary), zero_or_more).
	:- info(after_update/3, [
		comment is 'After a frame is updated',
		argnames is ['Frames', 'Subject', 'UpdatedFrames']
	]).
	:- public(after_update/6).
	:- mode(after_update(++nested_dictionary, +atomic, +atomic, +term, +term, --nested_dictionary), zero_or_more).
	:- info(after_update/6, [
		comment is 'After a frame is updated',
		argnames is ['Frames', 'Subject', 'Slot', 'OldValue', 'NewValue', 'UpdatedFrames']
	]).

:- end_protocol.

:- protocol(frames_on_delete).

	:- info([
		version is 1:0:1,
		author is 'Paul Brown',
		date is 2021-05-13,
		comment is 'Daemon called when an ``delete_frame/3-4`` is called'
	]).

	:- public(after_delete_frame/3).
	:- mode(after_delete_frame(++nested_dictionary, +atomic, --nested_dictionary), zero_or_more).
	:- info(after_delete_frame/3, [
		comment is 'After a whole frame is deleted',
		argnames is ['Frames', 'Subject', 'UpdatedFrames']
	]).

	:- public(after_delete_slots/3).
	:- mode(after_delete_slots(++nested_dictionary, +atomic, --nested_dictionary), zero_or_more).
	:- info(after_delete_slots/3, [
		comment is 'After a frame has some slots deleted',
		argnames is ['Frames', 'Subject', 'UpdatedFrames']
	]).
	:- public(after_delete_slot/5).
	:- mode(after_delete_slot(++nested_dictionary, +atomic, +atomic, +term, --nested_dictionary), zero_or_more).
	:- info(after_delete_slot/5, [
		comment is 'After a frame has some slot deleted',
		argnames is ['Frames', 'Subject', 'Slot', 'Value', 'UpdatedFrames']
	]).

:- end_protocol.
