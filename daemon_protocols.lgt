:- protocol(frames_on_add).

	:- info([
		version is 1:0:0,
		author is 'Paul Brown',
		date is 2021-05-13,
		comment is 'Daemon called when an ``add_frame/4`` is called'
	]).

	:- public(after_add/2).
	:- mode(after_add(++nested_dictionary, +atomic), zero_or_more).
	:- info(after_add/2, [
		comment is 'After a frame is added',
		argnames is ['Frames', 'Subject']
	]).
	:- public(after_add/4).
	:- mode(after_add(++nested_dictionary, +atomic, +atomic, +term), zero_or_more).
	:- info(after_add/4, [
		comment is 'After a frame is added',
		argnames is ['Frames', 'Subject', 'Slot', 'Value']
	]).

:- end_protocol.

:- protocol(frames_on_update).

	:- info([
		version is 1:0:0,
		author is 'Paul Brown',
		date is 2021-05-13,
		comment is 'Daemon called when an ``update_frame/4`` is called'
	]).

	:- public(after_update/2).
	:- mode(after_update(++nested_dictionary, +atomic), zero_or_more).
	:- info(after_update/2, [
		comment is 'After a frame is updated',
		argnames is ['Frames', 'Subject']
	]).
	:- public(after_update/4).
	:- mode(after_update(++nested_dictionary, +atomic, +atomic, +term), zero_or_more).
	:- info(after_update/4, [
		comment is 'After a frame is updated',
		argnames is ['Frames', 'Subject', 'Slot', 'Value']
	]).

:- end_protocol.

:- protocol(frames_on_delete).

	:- info([
		version is 1:0:0,
		author is 'Paul Brown',
		date is 2021-05-13,
		comment is 'Daemon called when an ``delete_frame/3-4`` is called'
	]).

	:- public(after_delete_frame/2).
	:- mode(after_delete_frame(++nested_dictionary, +atomic), zero_or_more).
	:- info(after_delete_frame/2, [
		comment is 'After a whole frame is deleted',
		argnames is ['Frames', 'Subject']
	]).

	:- public(after_delete_slots/2).
	:- mode(after_delete_slots(++nested_dictionary, +atomic), zero_or_more).
	:- info(after_delete_slots/2, [
		comment is 'After a frame has some slots deleted',
		argnames is ['Frames', 'Subject']
	]).
	:- public(after_delete_slot/4).
	:- mode(after_delete_slot(++nested_dictionary, +atomic, +atomic, +term), zero_or_more).
	:- info(after_delete_slot/4, [
		comment is 'After a frame has some slot deleted',
		argnames is ['Frames', 'Subject', 'Slot', 'Value']
	]).

:- end_protocol.
