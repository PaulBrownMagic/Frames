:- object(frames_monitor,
	implements(monitoring)).

	:- info([
		version is 1:0:0,
		author is 'Paul Brown',
		date is 2021-05-12,
		comment is 'Monitors Frames to run mutation facets'
	]).

	after(frames, add_frame(_OldFrames, Subject, Slots, Frames), _Sender) :-
		forall(
			(	conforms_to_protocol(Daemon, frames_on_add),
				current_object(Daemon)
			),
			(
			findall(Subject, Daemon::after_add(Frames, Subject), _),
			forall(
				list::member(Slot-Value, Slots),
				findall(Subject, Daemon::after_add(Frames, Subject, Slot, Value), _)
				)
			)).

	after(frames, update_frame(_OldFrames, Subject, Slots, Frames), _Sender) :-
		forall(
			(	conforms_to_protocol(Daemon, frames_on_update),
				current_object(Daemon)
			),
			(
			findall(Subject, Daemon::after_update(Frames, Subject), _),
			forall(
				list::member(Slot-Value, Slots),
				findall(Subject, Daemon::after_update(Frames, Subject, Slot, Value), _)
				)
			)).

	after(frames, delete_frame(_OldFrames, Subject, Slots, Frames), _Sender) :-
		forall(
			(	conforms_to_protocol(Daemon, frames_on_delete),
				current_object(Daemon)
			),
			(
			findall(Subject, Daemon::after_delete_slots(Frames, Subject), _),
			forall(
				list::member(Slot-Value, Slots),
				findall(Subject, Daemon::after_delete_slot(Frames, Subject, Slot, Value), _)
				)
			)).

	after(frames, delete_frame(_OldFrames, Subject, Frames), _Sender) :-
		forall(
			(	conforms_to_protocol(Daemon, frames_on_delete),
				current_object(Daemon)
			),
			findall(Subject, Daemon::after_delete_frame(Frames, Subject), _)
			).

:- end_object.
