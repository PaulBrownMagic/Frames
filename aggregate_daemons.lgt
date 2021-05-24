:- category(aggregate_daemons).

	:- info([
		version is 1:0:0,
		author is 'Paul Brown',
		date is 2021-05-24,
		comment is 'Aggregates all loaded daemons'
	]).

	% util ignore/2 is ignore but falls back to a default
	:- meta_predicate(ignore(*, *)).
	ignore(Call, Default) :-
		once((Call ; Default)).

	% Daemons

	:- public([
		calculate/3,
		after_add/3,
		after_add/5,
		after_update/3,
		after_update/6,
		after_delete_frame/3,
		after_delete_slots/3,
		after_delete_slot/5
		]).

	% find
	daemons_for(Daemons, Protocol) :-
		findall(Daemon, daemon_for(Daemon, Protocol), Daemons).
	daemon_for(Daemon, Protocol) :-
		conforms_to_protocol(Daemon, Protocol),
		current_object(Daemon).

	% read
	calculate(Collection, Subject, Key-Value) :-
		daemon_for(Calc, calculate_protocol),
		Calc::calculate(Collection, Subject, Key, Value).

	% add
	after_add(OldFrames, Subject, NewFrames) :-
		daemons_for(Daemons, frames_on_add),
		daemon_after_add_(Daemons, OldFrames, Subject, NewFrames).
	daemon_after_add_([], OldFrames, _Subject, OldFrames).
	daemon_after_add_([Daemon|Daemons], OldFrames, Subject, NewFrames) :-
		ignore(Daemon::after_add(OldFrames, Subject, AccFrames), OldFrames = AccFrames),
		daemon_after_add_(Daemons, AccFrames, Subject, NewFrames).

	after_add(OldFrames, Subject, Slot, Value, NewFrames) :-
		daemons_for(Daemons, frames_on_add),
		daemon_after_add_(Daemons, OldFrames, Subject, Slot, Value, NewFrames).
	daemon_after_add_([], OldFrames, _Subject, _Slot, _Value, OldFrames).
	daemon_after_add_([Daemon|Daemons], OldFrames, Subject, Slot, Value, NewFrames) :-
		ignore(Daemon::after_add(OldFrames, Subject, Slot, Value, AccFrames), OldFrames = AccFrames),
		daemon_after_add_(Daemons, AccFrames, Subject, Slot, Value, NewFrames).

	% update
	after_update(OldFrames, Subject, NewFrames) :-
		daemons_for(Daemons, frames_on_update),
		daemon_after_update_(Daemons, OldFrames, Subject, NewFrames).
	daemon_after_update_([], OldFrames, _Subject, OldFrames).
	daemon_after_update_([Daemon|Daemons], OldFrames, Subject, NewFrames) :-
		ignore(Daemon::after_update(OldFrames, Subject, AccFrames), OldFrames = AccFrames),
		daemon_after_update_(Daemons, AccFrames, Subject, NewFrames).

	after_update(OldFrames, Subject, Slot, OldValue, NewValue, NewFrames) :-
		daemons_for(Daemons, frames_on_update),
		daemon_after_update_(Daemons, OldFrames, Subject, Slot, OldValue, NewValue, NewFrames).
	daemon_after_update_([], OldFrames, _Subject, _Slot, _OldValue, _NewValue, OldFrames).
	daemon_after_update_([Daemon|Daemons], OldFrames, Subject, Slot, OldValue, NewValue, NewFrames) :-
		ignore(Daemon::after_update(OldFrames, Subject, Slot, OldValue, NewValue, AccFrames), OldFrames = AccFrames),
		daemon_after_update_(Daemons, AccFrames, Subject, Slot, OldValue, NewValue, NewFrames).

	% delete
	after_delete_frame(OldFrames, Subject, NewFrames) :-
		daemons_for(Daemons, frames_on_delete),
		daemon_after_delete_frame_(Daemons, OldFrames, Subject, NewFrames).
	daemon_after_delete_frame_([], OldFrames, _Subject, OldFrames).
	daemon_after_delete_frame_([Daemon|Daemons], OldFrames, Subject, NewFrames) :-
		ignore(Daemon::after_delete_frame(OldFrames, Subject, AccFrames), OldFrames = AccFrames),
		daemon_after_delete_frame_(Daemons, AccFrames, Subject, NewFrames).

	after_delete_slots(OldFrames, Subject, NewFrames) :-
		daemons_for(Daemons, frames_on_delete),
		daemon_after_delete_slots_(Daemons, OldFrames, Subject, NewFrames).
	daemon_after_delete_slots_([], OldFrames, _Subject, OldFrames).
	daemon_after_delete_slots_([Daemon|Daemons], OldFrames, Subject, NewFrames) :-
		ignore(Daemon::after_delete_slots(OldFrames, Subject, AccFrames), OldFrames = AccFrames),
		daemon_after_delete_slots_(Daemons, AccFrames, Subject, NewFrames).

	after_delete_slot(OldFrames, Subject, Slot, Value, NewFrames) :-
		daemons_for(Daemons, frames_on_delete),
		daemon_after_delete_slot_(Daemons, OldFrames, Subject, Slot, Value, NewFrames).
	daemon_after_delete_slot_([], OldFrames, _Subject, _Slot, _Value, OldFrames).
	daemon_after_delete_slot_([Daemon|Daemons], OldFrames, Subject, Slot, Value, NewFrames) :-
		ignore(Daemon::after_delete_slot(OldFrames, Subject, Slot, Value, AccFrames), OldFrames = AccFrames),
		daemon_after_delete_slot_(Daemons, AccFrames, Subject, Slot, Value, NewFrames).

:- end_category.
